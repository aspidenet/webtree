<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//



#
# ALL
#
$this->respond(array('GET', 'POST'), '*', function ($request, $response, $service, $app) {
    /*$session = getSession();

    $MODULO_CODE = "ADMIN";
    #$applicazione->setModulo($MODULO_CODE);
    $APP = [
        "title" => "Amministratori",
        "url" => "/admin",
        "code" => $MODULO_CODE
    ];
    $session->smarty()->assign("APP", $APP);
    $session->save();*/
    $session = getSession();
    
    $i = 0;
    $configurazione[$i]["nome"] = "Utenti REF";
    $configurazione[$i]["icona"] = "user";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/MAGICUSERS";
    
    $i++;
    $configurazione[$i]["nome"] = "Profili";
    $configurazione[$i]["icona"] = "address card";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/DEPROLS";
    
    $i++;
    $configurazione[$i]["nome"] = "Aree visibilità";
    $configurazione[$i]["icona"] = "eye";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/AREVISS";
    
    $i++;
    $configurazione[$i]["nome"] = "Gruppi";
    $configurazione[$i]["icona"] = "sitemap";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/GROUPS";
    
    $i++;
    $configurazione[$i]["nome"] = "Azioni";
    $configurazione[$i]["icona"] = "tasks";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/ACTIONS";

    $session->smarty()->assign("configurazione", $configurazione);
    $session->save();
});


#
# UPDATE
#
$this->respond('GET', '/update/[:wizard_code]/[:record_code]/[i:tab_index]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard_code;
    $record_code = $request->record_code;
    $tab_index = $request->tab_index;
    $tab = $request->param("tab", "") ;
    
    $wizard = Wizard::load($wizard_code);
    $wizard->save();
    
    $session->smarty()->assign("wizard_code", $wizard_code);
    $session->smarty()->assign("wizard", $wizard);
    $session->smarty()->assign("record_code", $record_code);
    
    $wizard_index = $wizard->getIndex();
    
    #
    # Contenitore
    #
    if (strlen($tab_index) == 0) {
        $tabs = array();
        
        foreach($wizard_index as $key => $item) {
            if ($key == 0) {
                $template_code = $item["template"];
                $template = Template::load($template_code);
                $tabs[$key] = $template->label();
            }
            else {
                
                $tabs[$key] = $item["relation"]["label0"];
            }
            
        }
        $session->smarty()->assign("tabs", $tabs);
        $session->smarty()->assign("tab", $tab);
        $session->smarty()->display("wizard-update.tpl");
        exit();
    }
    #
    # Template
    #
    elseif ($tab_index == 0) {
        // echo "<pre>";
        // print_r($wizard->getIndex());
        // echo "</pre>";
        
        $template_code = $wizard_index[0]["template"];
        $template = Template::load($template_code);
    
        $sql = "SELECT * FROM {$template->dbtable()} WHERE {$template->dbkey()}=?";
        $rs = $db->Execute($sql, array($record_code));
        $row = $rs->GetRow();
        $session->log($sql);
        $session->log($row);
        $session->smarty()->assign("template", $template);
        $session->smarty()->assign("record", $row);
        $session->smarty()->display("wizard-update-template.tpl");
        exit();
    }
    #
    # Relazione
    #
    elseif ($tab_index > 0) {
        $list = $wizard_index[$tab_index]["list"];
        $relation = $wizard_index[$tab_index]["relation"];
        // echo date('c');
        if ($list && is_array($relation)) {
            $vista = $relation["dbview"];
            $master_dbfield = $relation["master_dbfield"];
            $relation_code = $relation["relation_code"];
            
            // if (strlen($relation["recordset_code"]) > 0) {
                // $tabulator = new Tabulator();
                // $tabulator->setRecordset($relation["recordset_code"], " AND {$master_dbfield}=?", array($master_dbfield));
            // }
            // else {
                // $sql = "SELECT * FROM {$vista} WHERE {$master_dbfield}=?";
                // $params = array($record_code);
                // $tabulator = new Tabulator();
                // $tabulator->setSource($sql, $params, $relation_code.$record_code, array($master_dbfield));
                // #$tabulator->setTitle("Elenco SIM");
            // }
            
            $sql = "SELECT * FROM {$vista} WHERE {$master_dbfield}=?";
            $params = array($record_code);
            $tabulator = new Tabulator();
            $tabulator->setSource($sql, $params, $relation_code.$record_code, array($master_dbfield), $relation["recordset_code"]);
            #$tabulator->setTitle("Elenco SIM");
            
            $session->smarty()->assign("hashing", md5($relation_code.$record_code));
            $session->smarty()->assign("tabulator", $tabulator);
            $session->smarty()->assign("relation", $relation);
            $session->smarty()->assign("record_code", $record_code);
            $session->smarty()->assign("id", "modal".md5($relation_code.$record_code));
            $session->smarty()->assign("REQUEST", $request);
            $session->smarty()->assign("tab_index", $tab_index);
            $session->smarty()->assign("refresh_uri", "/wizard/update/{$wizard_code}/{$record_code}?tab={$tab_index}");
            $session->smarty()->display("wizard-update-relation.tpl");
        }
        echo "<pre>";
        print_r($relation);
        echo "</pre>";
        
        exit();
    }
    
    // $session->smarty()->assign("configurazione", $configurazione);
    
});




#
# LIST
#
$this->respond('GET', '/list/[:wizard_code]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard_code;
    
    if (isset($_SESSION['WIZARDS']))
        unset($_SESSION['WIZARDS']);
    
    $wizard = Wizard::load($wizard_code);
    #$wizard->save();
    $template_code = $wizard->get("template_code");
    $template = Template::load($template_code);
    
    if (strlen($template->get("recordset_code")) > 0) {
        $tabulator = new Tabulator();
        $tabulator->setRecordset($template->get("recordset_code"));
    }
    else {
        $sql = "SELECT * FROM {$template->dbtable()} WHERE 1=1 ";
        $params = array();
        $tabulator = new Tabulator();
        $tabulator->setSource($sql, $params, $wizard_code.$template_code, array());
    }
    #$tabulator->setTitle("Elenco SIM");
    
    $session->smarty()->assign("wizard_code", $wizard_code);
    $session->smarty()->assign("wizard", $wizard);
    $session->smarty()->assign("template_dbkey", $template->dbkey());
    $session->smarty()->assign("hashing", md5($wizard_code.$template_code));
    $session->smarty()->assign("tabulator", $tabulator);
    $session->smarty()->display("wizard-list.tpl");
});





#
# CONFIG
#
$this->respond('GET', '/config', function ($request, $response, $service, $app) {
    $session = getSession();
    
    /*if (isset($_SESSION['WIZARDS']))
        unset($_SESSION['WIZARDS']);
    
    $i = 0;
    $configurazione[$i]["nome"] = "Utenti REF";
    $configurazione[$i]["icona"] = "user";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/MAGICUSERS";
    
    $i++;
    $configurazione[$i]["nome"] = "Profili";
    $configurazione[$i]["icona"] = "address card";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/DEPROLS";
    
    $i++;
    $configurazione[$i]["nome"] = "Aree visibilità";
    $configurazione[$i]["icona"] = "eye";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/AREVISS";
    
    $i++;
    $configurazione[$i]["nome"] = "Gruppi";
    $configurazione[$i]["icona"] = "sitemap";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/GROUPS";
    
    $i++;
    $configurazione[$i]["nome"] = "Azioni";
    $configurazione[$i]["icona"] = "tasks";
    $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/ACTIONS";

    $session->smarty()->assign("configurazione", $configurazione);*/
    $session->smarty()->display("wizard-config.tpl");
});






































#
# INDEX
#
$this->respond('GET', '/?', function ($request, $response, $service, $app) {
    $session = getSession();
    
    if (isset($_SESSION['WIZARDS']))
        unset($_SESSION['WIZARDS']);
    
    $i = 0;
    $configurazione[$i]["nome"] = "Utenti";
    $configurazione[$i]["icona"] = "user";
    $configurazione[$i]["link"] = "/wizard/users/list";
    
    // $configurazione[$i]["nome"] = "Utenti";
    // $configurazione[$i]["icona"] = "user";
    // $configurazione[$i]["link"] = "utenti.php";

    // $i++;
    // $configurazione[$i]["nome"] = "Gruppi";
    // $configurazione[$i]["icona"] = "users";
    // $configurazione[$i]["link"] = "gruppi.php";

    // $i++;
    // $configurazione[$i]["nome"] = "Moduli";
    // $configurazione[$i]["icona"] = "sitemap";
    // $configurazione[$i]["link"] = "moduli.php";

    // $i++;
    // $configurazione[$i]["nome"] = "Web Online";
    // $configurazione[$i]["icona"] = "globe";
    // $configurazione[$i]["link"] = "procedure.php";

    // $i++;
    // $configurazione[$i]["nome"] = "Oggetti di sistema";
    // $configurazione[$i]["icona"] = "cubes";
    // $configurazione[$i]["link"] = "oggetti.php?tab=S";

    // $i++;
    // $configurazione[$i]["nome"] = "Classificazioni";
    // $configurazione[$i]["icona"] = "wizard";
    // $configurazione[$i]["link"] = "oggetti.php?tab=C";

    $session->smarty()->assign("configurazione", $configurazione);
    $session->smarty()->display("admin-index.tpl");
});

#
# UTENTI
#
$this->respond('GET', '/[:wizard]/[new|update|list|debug|clear:action]/?[:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $wizard_code = $request->wizard;
    $code = $request->code;
    
    $params = $request->params();
    $return_url = $request->param("return_url", "");
    
    $wizard = Wizard::load($wizard_code);
    if (strlen($return_url))
        $wizard->setReturnUrl(base64_decode($return_url, true));
    $wizard->save();
    
    $session->smarty()->assign("wizard_code", $wizard_code);
    $session->smarty()->assign("wizard", $wizard);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("record_code", $code);
        
    if ($action == "debug") {
        $index = $wizard->getIndex();
        echo "<pre>";
        #var_dump($index);
        print_r($index);
        echo "</pre>";
        exit();
    }
    elseif ($action == "clear") {
        if (isset($_SESSION['WIZARDS']))
            unset($_SESSION['WIZARDS']);
        exit();
    }
    elseif ($action == "list") {
        if (isset($_SESSION['WIZARDS']))
            unset($_SESSION['WIZARDS']);
        $sql = "SELECT TOP 1 * FROM {$wizard->dbview()}";
        $rs = $db->Execute($sql);
        $records = $rs->GetArray();
        
        $template_code = $wizard->get("template_code");
        $template = Template::load($template_code);
        
        $session->smarty()->assign("classe", strtolower($template_code));
        $session->smarty()->assign("campo_chiave", $template->dbkey());
        $session->smarty()->assign("record", $records[0]);
        $session->smarty()->display("admin-elenco.tpl");
        exit();
    }
    elseif ($action == "new") {
        $index = $wizard->getIndex();
        #var_dump($index);
        #print_r($index);
        
        foreach($index as $key => $item) {
            # per ora andiamo oltre se lo step e' completato
            if ($item["pass"] == true)
                continue;
            
            $template_code = $item["template"];
            $template = Template::load($template_code);
            $session->smarty()->assign("template", $template);
                
            if ($item["list"] == false) {
                $session->smarty()->assign("fields", $template->getFields());
                $session->smarty()->assign("values", $params);
                $session->smarty()->display("admin-wizard-template.tpl");
                exit();
            }
            else {
                $relation = $item["relation"];
                $records = $item["records"];
                $linkeds = $item["linkeds"];
                
                $session->smarty()->assign("relation", $relation);
                $session->smarty()->assign("records", $records);
                $session->smarty()->assign("linkeds", $linkeds);
                $session->smarty()->assign("index_pos", $key);
                $session->smarty()->display("admin-wizard-relation.tpl");
                exit();
            }
        }
        
        $session->smarty()->assign("template", $template);
        $session->smarty()->display("admin-wizard-save.tpl");
        exit();
    }
    elseif ($action == "update") {
        $index = $wizard->getIndex();
        #var_dump($index);
        #print_r($index);
        
        foreach($index as $key => $item) {
            # per ora andiamo oltre se lo step è completato
            if ($item["pass"] == true)
                continue;
            
            $template_code = $item["template"];
            $template = Template::load($template_code);
            $session->smarty()->assign("template", $template);
            
            # TODO QUI
            $sql = "SELECT * FROM {$template->dbtable()} WHERE {$template->dbkey()}=?";
            $rs = $db->Execute($sql, array($code));
            $params = $rs->GetRow();
            $session->log("------------------------> di qui passiamo!");
            $session->log($params);
                
            if ($item["list"] == false) {
                $session->smarty()->assign("fields", $template->getFields());
                $session->smarty()->assign("values", $params);
                $session->smarty()->display("admin-wizard-template.tpl");
                exit();
            }
            // else {
                // $relation = $item["relation"];
                // $records = $item["records"];
                // $linkeds = $item["linkeds"];
                
                // $session->smarty()->assign("relation", $relation);
                // $session->smarty()->assign("records", $records);
                // $session->smarty()->assign("linkeds", $linkeds);
                // $session->smarty()->assign("index_pos", $key);
                // $session->smarty()->display("admin-wizard-relation.tpl");
                // exit();
            // }
        }
        
        $session->smarty()->assign("template", $template);
        $session->smarty()->display("admin-wizard-save.tpl");
        exit();
    }
    
    echo "DA FARE";
    exit();
});
#----------------------------------------------------------------------------------------------------------------------------------------------
# Salviamo i dati del template principale e salviamo il wizard
$this->respond('POST', '/[:wizard]/[new|update|save|cancel:action]/?[:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $wizard_code = $request->wizard;
    $code = $request->code;
    $result = new Result();
    $ignore_warning = toBool($request->ignore_warning);
    $session->log("Ignore Warning: {$request->ignore_warning}");
    
    try {
        $wizard = Wizard::load($wizard_code);
        $wizard->save();
        $index = $wizard->getIndex();
        
        $session->log("Wizard: {$wizard_code}, action: ".$action);
        if ($action == "new") {
            #$session->log($index);
            
            foreach($index as $key => $item) {
                # per ora andiamo oltre se lo step è completato
                if ($item["pass"] == true)
                    continue;
                    
                if ($item["list"] == false) {
                    $template_code = $item["template"];
                    $template = Template::load($template_code);
                    
                    # leggiamo i dati da post
                    $record = new Base($template);
                    
                    #$record->table($template->dbtable());
                    $fields = $template->getFields();
                    foreach($fields as $metafield) {
                        $value = get($metafield->dbfield(), "", $_POST);
                        $record->set($metafield->dbfield(), $value);
                    }
                    
                    # lanciamo le rules
                    try {
                        $template->checkRules($record);
                    }
                    // catch(Exception $ex) {
                        // $result->setResult(false);
                        // $result->setCode("KO");
                        // $result->setDescription($ex->getMessage());
                        // $result->setLevel(Result::ERROR);
                        // return $result->toJson();
                    // }
                    catch(Result $ex) {
                        if ($ex->getLevel() == Result::ERROR)
                            return $ex->toJson();
                        elseif (!$ignore_warning)
                            return $ex->toJson();
                    }
                    
                    # memorizziamo l'oggetto in memoria
                    $key2 = 0; # perchE' $item["list"] == false
                    $wizard->setIndexRecord($key, $key2, $record);
                    $wizard->setIndexPass($key, true);
                    $wizard->save();
                
                    $result->setResult(true);
                    $result->setCode("OK");
                    $result->setDescription("Template {$template_code} memorizzato.");
                    $result->setLevel(Result::INFO);
                    return $result->toJson();
                }
            
            }
            
            $result->setResult(false);
            $result->setCode("KO");
            $result->setDescription("Wizard: {$wizard_code}.");
            $result->setLevel(Result::ERROR);
            return $result->toJson();
        }
        elseif ($action == "update") {
            $session->log("Wizard template UPDATE");
            $session->log($index);
            
            /*
            array (
                0 => array (
                    'list' => false,
                    'pass' => false,
                    'template' => 'SYSCOLUMNS',
                    'records' => 
                        array (),
                    'relation' => NULL,
                ),
            )
            */
            
            foreach($index as $key => $item) {
                # per ora andiamo oltre se lo step � completato
                if ($item["pass"] == true)
                    continue;
                    
                if ($item["list"] == false) {
                    $template_code = $item["template"];
                    $template = Template::load($template_code);
                    
                    # leggiamo i dati da post
                    $record = new Base($template);
                    if (strlen($code))
                        $record->read($code);
                    
                    #$record->table($template->dbtable());
                    $fields = $template->getFields();
                    foreach($fields as $metafield) {
                        $value = get($metafield->dbfield(), "", $_POST);
                        $record->set($metafield->dbfield(), $value);
                    }
                    
                    # lanciamo le rules
                    try {
                        $template->checkRules($record);
                    }
                    // catch(Exception $ex) {
                        // $result->setResult(false);
                        // $result->setCode("KO");
                        // $result->setDescription($ex->getMessage());
                        // $result->setLevel(Result::ERROR);
                        // return $result->toJson();
                    // }
                    catch(Result $ex) {
                        if ($ex->getLevel() == Result::ERROR)
                            return $ex->toJson();
                        elseif (!$ignore_warning)
                            return $ex->toJson();
                    }
                    
                    # memorizziamo l'oggetto in memoria
                    $key2 = 0; # perché $item["list"] == false
                    $wizard->setIndexRecord($key, $key2, $record);
                    $wizard->setIndexPass($key, true);
                    #$wizard->save();
                    
                    try {
                        $session->log("PRE saveIndex()");
                        $wizard->saveIndex();
                        $session->log("POST saveIndex()");
                    }
                    catch(Exception $ex) {
                        $session->log($ex);
                        return "KO";
                    }
                    // catch(Result $ex) {
                        // return $ex->toJson();
                    // }
                
                    $result->setResult(true);
                    $result->setCode("OK");
                    $result->setDescription("Template {$template_code} aggiornato.");
                    $result->setLevel(Result::INFO);
                    #$result->setCustoms(['url' => "?tab=columns"]);
                    $result->setCustoms(['finish' => true]);
                    return $result->toJson();
                }
            
            }
            
            $result->setResult(false);
            $result->setCode("KO");
            $result->setDescription("Wizard: {$wizard_code}.");
            $result->setLevel(Result::ERROR);
            return $result->toJson();
        }
        elseif ($action == "save") {
            
            try {
                $master_code = $wizard->saveIndex();
            }
            catch(Result $ex) {
                return $ex->toJson();
            }
        
            $custom_url = APP_BASE_URL."/wizard/update/{$wizard_code}/{$master_code}";
            $custom_url = APP_BASE_URL."/admin/config/{$wizard_code}/update/{$master_code}";
        
        
            $result->setResult(true);
            $result->setCode("OK");
            $result->setDescription("Wizard {$wizard_code} completato.");
            $result->setLevel(Result::INFO);
            $result->setCustoms(array('url' => $custom_url));
            return $result->toJson();
        }
        elseif ($action == "cancel") {
            
            try {
                $wizard->cancel();
                
            }
            catch(Result $ex) {
                return $ex->toJson();
            }
        
            $result->setResult(true);
            $result->setCode("OK");
            $result->setDescription("Wizard {$wizard_code} annullato.");
            $result->setLevel(Result::INFO);
            return $result->toJson();
        }
        
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription("Azione non supportata.");
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }
    catch(Result $ex) {
        $session->log("Exception!");
        return $ex->toJson();
    }
});

#----------------------------------------------------------------------------------------------------------------------------------------------
# Salviamo i dati di un template (escluso il template principale)
$this->respond('POST', '/[:wizard]/new/[i:index]/[:template]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard;
    $template_code = $request->template;
    $index_pos = $request->index;
    $ignore_warning = toBool($request->ignore_warning);
    $session->log("Ignore Warning: {$request->ignore_warning}");
    $result = new Result();
    
    $wizard = Wizard::load($wizard_code);
    $template = Template::load($template_code);
    $index = $wizard->getIndex();
    
    # leggiamo i dati da post
    $record = new Base($template);
    #$record->table($template->dbtable());
    $fields = $template->getFields();
    foreach($fields as $metafield) {
        $value = get($metafield->dbfield(), "", $_POST);
        $record->set($metafield->dbfield(), $value);
    }
    
    #$session->log($record);
    
    # lanciamo le rules
    try {
        $template->checkRules($record);
    }
    // catch(Exception $ex) {
        // $result->setResult(false);
        // $result->setCode("KO");
        // $result->setDescription($ex->getMessage());
        // $result->setLevel(Result::ERROR);
        // return $result->toJson();
    // }
    catch(Result $ex) {
        if ($ex->getLevel() == Result::ERROR)
            return $ex->toJson();
        elseif (!$ignore_warning)
            return $ex->toJson();
    }
    
    # memorizziamo l'oggetto in memoria
    $key2 = count($index[$index_pos]["records"]);
    $wizard->setIndexRecord($index_pos, $key2, $record);
    $wizard->save();

    $result->setResult(true);
    $result->setCode("OK");
    $result->setDescription("Template {$template_code} memorizzato.");
    $result->setLevel(Result::INFO);
    return $result->toJson();
});
#----------------------------------------------------------------------------------------------------------------------------------------------
# Salviamo un template linkato
$this->respond('POST', '/wizard-[:wizard]/new/[i:index]/[:template]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard;
    $template_code = $request->template;
    $index_pos = $request->index;
    $result = new Result();
    
    $wizard = Wizard::load($wizard_code);
    $template = Template::load($template_code);
    $index = $wizard->getIndex();
    
    #$session->log($_POST);
    
    # lanciamo le rules
    $rules_ok = true;
    
    if (!$rules_ok) {
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription("Relazione con template: {$template_code}.");
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }
    else {
        $field_key = $template->dbkey();
        $data = $_POST["data"];
        
        foreach($data as $linked_row) {
            # cerchiamo il campo chiave:
            foreach($linked_row as $key => $field) {
                if ($key == $field_key) {
                    # memorizziamo l'oggetto in memoria
                    $code = $field;
                    #$session->log(array($code => $linked_row[$template->dblabel()]));
                    #$session->log("Template::dblabel() = |".$template->dblabel()."|");
                    $wizard->setIndexLinked($index_pos, $code, $linked_row[$template->dblabel()]);
                    $wizard->save();
                }
                
            }
        }
        
        $result->setResult(true);
        $result->setCode("OK");
        $result->setDescription("Relazione con template {$template_code} memorizzata.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
    }
});

#----------------------------------------------------------------------------------------------------------------------------------------------
# Convalidiamo l'indice
$this->respond('POST', '/[:wizard]/new/pass/[i:index]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard;
    $index_pos = $request->index;
    $result = new Result();
    
    $wizard = Wizard::load($wizard_code);
    
    # lanciamo le rules
    $rules_ok = true;
    
    if (!$rules_ok) {
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription("Template: {$template_code}.");
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }
    else {
        try {
            # memorizziamo l'oggetto in memoria
            $wizard->setIndexPass($index_pos, true);
            $wizard->save();
        
            $result->setResult(true);
            $result->setCode("OK");
            $result->setDescription("Relazione completata.");
            $result->setLevel(Result::INFO);
            return $result->toJson();
        }
        catch(Result $ex) {
            $db->FailAllTrans();
            $result->setResult(false);
            $result->setCode("KO");
            $result->setDescription($ex->getMessage());
            $result->setLevel(Result::ERROR);
            return $result->toJson();
        }
    }
});







#
# Disegnamo il FORM del TEMPLATE dinamicamente
#
$this->respond('POST', '/template/[:template_code]/[new|update:action]/[a:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $template_code = $request->template_code;
    $code = $request->code;
    
    $template = Template::load($template_code);
    $template->save();
    
    $session->smarty()->assign("template_code", $template_code);
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("fields", $template->getFields());
    $session->smarty()->display("form-template.tpl");
});




#
# Disegnamo il FORM della SELEZIONE per la relazione dinamicamente
#
$this->respond('POST', '/template/[:template_code]/[list:action]/[a:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $template_code = $request->template_code;
    #$code = $request->code;
    
    $template = Template::load($template_code);
    $template->save();
    
    $sql = "SELECT TOP 1 * FROM {$template->dbview()}";
    $rs = $db->Execute($sql);
    
    $record = $rs->GetRow();
    
    $session->smarty()->assign("template_code", $template_code);
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("wizard_code", "users");
    $session->smarty()->assign("relation_code", "user-group");
    $session->smarty()->display("form-select-from-records.tpl");
});











#
# REGOLE
#
$this->respond('GET', '/regole/[:wizard]/[new|update|read:action]/[a:code]', function ($request, $response, $service, $app) {
    $session = getSession();
    $session->smarty()->assign("configurazione", $configurazione);
    $session->smarty()->display("admin-elenco.tpl");
});




# /APP/WIZARD/AZIONE/codice?





/*$this->respond('GET', '/json/[:wizard]/[new|update|list:action]/[a:code]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $action = $request->action;
    $wizard_code = $request->wizard;
    $code = $request->code;
    $wizard = new Wizard($wizard_code);
    
    if ($action == "list") {
        
        
        exit();
    }
    
    throw new Exception("DA COMPLETARE");
    exit();
    $session->smarty()->assign("configurazione", $configurazione);
    $session->smarty()->display("admin-elenco.tpl");
});*/


















#
#
#
# JSON
#
#
#

$this->respond('GET', '/json/wizard-[a:wizard]/list', function ($request, $response, $service, $app) {
    $session = getSession();
    $wizard_code = $request->wizard;
    $wizard = Wizard::load($wizard_code);
    $sql = "SELECT * FROM {$wizard->dbview()} WHERE 1=1";

    json_tabulator_query($sql, array());
});


$this->respond('GET', '/json/wizard-[a:wizard]/relation-[:relation]/[a:master_code]/list', function ($request, $response, $service, $app) {
    $session = getSession();
    $relation_code = $request->relation;
    $master_code = $request->master_code;
    $relation = Relation::load($relation_code);
    
    $slave_template = $relation->templateSlave();
    
    
    $sql = "SELECT * _FROM_ {$slave_template->dbview()} 
            where {$slave_template->dbkey()}  NOT IN (
                select slave_code FROM {$relation->dbtable()}
                WHERE master_code=?
            )  ";
    $session->log($sql);
    json_tabulator_query($sql, array($master_code), "_FROM_");
});