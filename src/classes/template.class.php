<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Template extends Base{
    private $code;
    private $fields_list;
    
    function __construct($code) {
        parent::__construct();
        
        $this->code = $code;
        
        $db = getDB();
        $sql = "SELECT * FROM MetaTemplates WHERE template_code=?";
        $rs = $db->Execute($sql, array($code));
        $this->_fields = $rs->GetRow();

        $sql = "SELECT * FROM MetaFields WHERE template_code=? order by sorting";
        $rs = $db->Execute($sql, array($code));
        while(!$rs->EOF) {
            $dbfield = $rs->Fields("dbfield");
            $this->fields_list[$dbfield] = new Field($rs->GetRow());
        }
    }
    
    public function serialize() {
        return serialize([
            'fields_list' => serialize($this->fields_list),
            'base' => parent::serialize()
        ]);
    }
    public function unserialize($data) {
        $data = unserialize($data);
        $this->fields_list = unserialize($data['fields_list']);
        parent::unserialize($data['base']);
    }
    
    
    
    public function getFields() {
        return $this->fields_list;
    }
    
    public function code() {
        return $this->get("template_code");
    }
    
    public function dbtable() {
        return $this->get("dbtable");
    }
    
    public function dbview() {
        return $this->get("dbview");
    }
    
    public function dbkey() {
        return $this->get("dbkey");
    }
    
    public function dblabel() {
        if (strlen($this->get("dblabel")))
            return $this->get("dblabel");
        return "label0";
    }
    
    public function icon() {
        return $this->get("icon");
    }
    
    public function relations() {
        $db = getDB();
        $session = getSession();
        $sql = "Select relation_code, label0 from metarelations where master_code=? order by sorting";
        $rs = $db->Execute($sql, array($this->code()));
        return $rs->GetArray();
    }
    
    public function check($record, $action='I', $ignore_warnings=false) {
        $manager = TableManager::load($this->dbtable());  
        $this->checkFields($record, $action); 
        $this->checkRules($record, $ignore_warnings); 
        #$manager->check($record);
    }
    
    public function checkFields($record, $action) {
        $db = getDB();
        $session = getSession();
        $session->log("Template {$this->code()} checkFields");
        $errors = [];
        
        $fields = $this->getFields();
        foreach($fields as $metafield) {
            $valore = $record->get($metafield->dbfield());
            if (strlen($valore) == 0 && $metafield->mandatory($action))
                $errors[] = "Il campo '{$metafield->label()}' è obbligatorio.";
        }

        if (count($errors)) {
            if (count($errors) == 1)
                $messaggio = $errors[0];
            else {
                $messaggio = "";
                foreach($errors as $item) {
                    $messaggio .= "<li>".$item."</li>";
                }
                $messaggio = "<ul>{$messaggio}</ul>";
            }
            throw new Result(false, "KO", $messaggio, Result::ERROR);
        }
        
        return true;
    }
    
    public function checkRules($record, $ignore_warnings=false) {
        $db = getDB();
        $session = getSession();
        $session->log("Template {$this->code()} checkRules");
        
        $sql = "SELECT * FROM RuleDetails WHERE flag_prepost='PRE' AND template_code=?";
        $session->log($sql);
        $rs = $db->Execute($sql, array($this->code()));
        $segnaposto = [];
        $warnings = [];
        $errors = [];
        
        if ($rs == false)
            throw new Result(false, "KO", "Impossibile leggere le regole sull'oggetto.", Result::ERROR);

        while (!$rs->EOF) {
            $session->log("=============================================================================================");
            $pseudocode = $rs->get("pseudocode");
            $severity = $rs->get("severity");
            
            $session->log("********************************************************************************");
            $session->log($severity." | ".$pseudocode);
            
            preg_match_all('/%.*?%/', $pseudocode, $matches);
            $session->log($matches[0]);
            foreach($matches[0] as $item)
                $segnaposto[$item] = str_replace("%", "", $item);
            $session->log($segnaposto);
            
            foreach($segnaposto as $key => $field) 
                $pseudocode = str_replace($key, $record->get($field), $pseudocode);
                
            $session->log("********************************************************************************");
            $session->log($pseudocode);
            $session->log("********************************************************************************");
            
            $rscheck = $db->Execute($pseudocode);
            $row = $rscheck->GetRow();
            $session->log($row);
            if ($row['esito'] == "1" && $severity == 'E')
                #throw new Result(false, "KO", $row["messaggio"], Result::ERROR);
                $errors[] = $row["messaggio"];
            elseif ($row['esito'] == "1" && $severity == 'W')
                $warnings[] = $row["messaggio"];

            $rs->MoveNext();
        }
        
        if (count($errors)) {
            if (count($errors) == 1)
                $messaggio = $errors[0];
            else {
                $messaggio = "";
                foreach($errors as $item) {
                    $messaggio .= "<li>".$item."</li>";
                }
                $messaggio = "<ul>{$messaggio}</ul>";
            }
            throw new Result(false, "KO", $messaggio, Result::ERROR);
        }
        elseif (count($warnings)) {
            if ($ignore_warnings === false) {
                if (count($warnings) == 1)
                    $messaggio = $warnings[0];
                else {
                    $messaggio = "";
                    foreach($warnings as $item) {
                        $messaggio .= "<li>".$item."</li>";
                    }
                    $messaggio = "<ul>{$messaggio}</ul>";
                }
                throw new Result(false, "KO", $messaggio, Result::WARNING);
            }
        }
        #throw new Result(false, "KO", "Attenzione! Ma a cosa?", Result::WARNING);
        #throw new Exception("Non ho voglia! Arrangiati!");
        return true;
    }
    
    public function store($record, $keyvalue=null) {
        $manager = TableManager::load($this->dbtable());   
        if ($record->id() > 0) {
            $manager->update($record, $this->dbkey(), $keyvalue);
            return $record->id();
        }
        else {
            $last_id = $manager->insert($record, $this->dbkey());
            return $last_id;
        }
    }
        
    public function delete($record, $keyvalue=null) {
        $manager = TableManager::load($this->dbtable());   
        if ($record->id() > 0) {
            $manager->delete($record, $this->dbkey(), $keyvalue);
            return $record->id();
        }
        return false;
    }
    
    public function import($source=null) {
        $record = new Base($this);
        
        if (is_null($source))
            $source = $_POST;
        
        $fields = $this->getFields();
        foreach($fields as $metafield) {
            $value = get($metafield->dbfield(), "", $source);
            $record->set($metafield->dbfield(), $value);
        }
        return $record;
    }
    
    
    
    public function displayNavigazione($record, $recordset=null) {
        $session = getSession();
        $code = $record[$this->dbkey()];
        $session->smarty()->assign("record", $record);
        $session->smarty()->assign("recordset", $recordset);
        $session->smarty()->assign("record_code", $code);
        $session->smarty()->assign("template", $this);
        $session->smarty()->assign("X", new X());
        $session->smarty()->display('navigazione-class-base.tpl');
    }
    
    
    
    
    
    static function load($code) {
        if (isset($_SESSION['TEMPLATES'][$code]))
            $template = unserialize($_SESSION['TEMPLATES'][$code]);
        else {
            $template = new Template($code);
        }
        return $template;
    }

    public function save() {
        $_SESSION['TEMPLATES'][$code] = serialize($this);
    }
    
    
    
}