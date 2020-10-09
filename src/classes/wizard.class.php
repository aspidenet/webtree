<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Wizard extends Base {
    
    function __construct($code) {
        parent::__construct();
        
        $this->_customdata["code"] = $code;
        
        $db = getDB();
        $sql = "SELECT * FROM MetaWizards WHERE wizard_code=?";
        $rs = $db->Execute($sql, array($code));
        $this->_fields = $rs->GetRow();

        $main_template = $this->get("template_code");
        
        $this->_customdata["index"] = array(
            0 => array(
                'list' => false,
                'pass' => false,
                'template' => $main_template,
                'records' => [],
                'relation' => null
            ),
        );
        
        #Select * from metatemplates where template_code='{$main_template}'
        #Select * from metafields where template_code='{$main_template}'
        $sql = "Select * from metarelations where master_code=? order by sorting";
        $rs = $db->Execute($sql, array($main_template));
        $relations = $rs->GetArray();
        foreach($relations as $rel) {
            $this->_customdata["index"][] = array(
                'list' => true, #($rel["cardinality_max"] > 1) ? true : false,
                'pass' => false,
                'template' => $rel["slave_code"],
                'records' => [],
                'linkeds' => [],
                'relation' => $rel
            );
        }
        
    }
    
    #
    # RETURN URL
    #
    public function getReturnUrl() {
        return $this->_customdata["return_url"];
    }
    public function setReturnUrl($url) {
        $this->_customdata["return_url"] = $url;
    }
    
    #
    # INDEX
    #
    public function getIndex() {
        return $this->_customdata["index"];
    }
    public function setIndexPass($key, $val) {
        if ($val === true)
            $this->_customdata["index"][$key]["pass"] = true;
        else
            $this->_customdata["index"][$key]["pass"] = false;
    }
    public function setIndexRecord($key, $key2, $record) {
        if (isset($this->_customdata["index"][$key]["records"]))
            $this->_customdata["index"][$key]["records"][$key2] = $record;
    }
    public function setIndexLinked($key, $code, $label) {
        if (isset($this->_customdata["index"][$key]["linkeds"]))
            $this->_customdata["index"][$key]["linkeds"][$code] = $label;
    }
    public function saveIndex() {
        $db = getDB();
        $session = getSession();
        //$session->log("//////////////////////////////////////////////////////////////// saveIndex()");
        $db->StartTrans();
        
        #$session->log($this->_customdata["index"]);
        
        try {
            $main_template_code = $this->get("template_code");
            $main_template = Template::load($main_template_code);
            $master_record = $this->_customdata["index"][0]['records'][0];
            $master_code = $master_record->get($main_template->dbkey());
            $session->log("MASTER KEY ({$main_template_code}, {$main_template->dbkey()}): {$master_code}");
            
            foreach($this->_customdata["index"] as $key => $item) {
                
                # Ignoriamo se la relazione esiste ed è in sola lettura
                if (isset($item["relation"])) {
                    if ($item["relation"]["readonly"] == 'S')
                        continue;
                    if ($item["relation"]["nosave"] == 1)
                        continue;
                }
                
                $template_code = $item["template"];
                $session->log("SAVE template {$template_code}");
                $template = Template::load($template_code);
                #$manager = TableManager::load($template->dbtable());   
                
                # Nuovi oggetti e relazioni
                if (isset($item['records'])) {
                    foreach($item['records'] as $record) {
                        
                        # Gli oggetti collegati direttamente mi assicuro che il campo chiave sia valorizzato
                        if ($key > 0) {
                            
                            if ($item['relation']['dbtable'] == $template->dbtable()) {
                                $chiave = $record->get($item['relation']['master_dbfield']);
                                $session->log($chiave);
                                if (strlen($chiave) == 0) {
                                    $record->set($item['relation']['master_dbfield'], $master_code);
                                    $session->log("Imposto il campo {$item['relation']['master_dbfield']} = {$master_code}");
                                }
                            }
                        }
                        
                        if (isset($item['relation']) && strlen($item['relation']['class']) > 0) {
                            $classe = strtolower($item['relation']['class']);
                            require_once "../src/classes/{$classe}.class.php";
                            $classe = $item['relation']['class'];
                            $obj = new $classe();
                            $obj->setParent($master_code);
                            $obj->setWizard($this);
                            $last_id = $obj->store($record);
                        }
                        else
                            $last_id = $template->store($record);
                        
                        if ($key == 0) {
                            $master_code = $last_id;
                        }
                        
                        # se c'è la relazione, creo anche quella (ma non è indicata una classe o la tabella dell'oggetto collegato ha già la FK)
                        // [master_code] => USER
                        // [slave_code] => REGISTRY
                        // [dbtable] => RelUserRegistry
                        if (isset($item['relation']) && strlen($item['relation']['class']) == 0) {
                            $table = $item['relation']['dbtable'];
                            if ($table != $template->dbtable()) {
                                $master_dbfield = $item['relation']['master_dbfield'];
                                $slave_dbfield = $item['relation']['slave_dbfield'];
                                $slave_key = $template->dbkey();
                                $slave_code = $record->get($slave_key);
                                $sql = "INSERT INTO {$table}({$master_dbfield}, {$slave_dbfield}) VALUES(?, ?)";
                                $session->log("RELATION-NEW: {$sql}");
                                $db->Execute($sql, array($master_code, $slave_code));
                            }
                        }
                    }
                }
                
                # Relazioni ad oggetti esistenti
                if (isset($item['linkeds'])) {
                    foreach($item['linkeds'] as $key => $label) {

                        $table = $item['relation']['dbtable'];
                        $master_dbfield = $item['relation']['master_dbfield'];
                        $slave_dbfield = $item['relation']['slave_dbfield'];
                        $slave_code = $key;
                        $sql = "INSERT INTO {$table}({$master_dbfield}, {$slave_dbfield}) VALUES(?, ?)";
                        $session->log("RELATION-LINKED: {$sql} - ({$master_code}, {$slave_code})");
                        $db->Execute($sql, array($master_code, $slave_code));

                    }
                }
                
                /*
                    'list' => true, #($rel["cardinality_max"] > 1) ? true : false,
                    'pass' => false,
                    'template' => $rel["slave_code"],
                    'records' => [],
                    'linkeds' => [],
                    'relation' => $rel
                );*/
                
            }
            // $db->FailTrans();
            
            $db->CompleteTrans();
            // throw new Result(false, "KO", "TEST: salvataggio fallito.", Result::ERROR);
            
            # Se non ci sono errori, tutto ok. Elimino il wizard dalla memoria:
            $this->cancel();
            return $master_code;
        }
        catch(Result $ex) {
            $session->log($ex);
            $db->FailAllTrans();
            $db->CompleteTrans();
            throw $ex;
        }
        // finally {
            // $db->CompleteTrans();
        // }
        //$session->log("\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ ");
    }
    
    public function dbview() {
        return $this->get("dbview");
    }
    
    static function load($code) {
        if (isset($_SESSION['WIZARDS'][$code])) {
            $wizard = unserialize($_SESSION['WIZARDS'][$code]);
        }
        else {
            $wizard = new Wizard($code);
        }
        return $wizard;
    }

    public function save() {
        $code = $this->_customdata["code"];
        $_SESSION['WIZARDS'][$code] = serialize($this);
    }

    public function cancel() {
        $code = $this->_customdata["code"];
        unset($_SESSION['WIZARDS'][$code]);
        error_log("--- WIZARD::cancel():".$code);
    }
}