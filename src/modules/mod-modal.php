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
    $session = getSession();

    // $MODULO_CODE = "ADMIN";
    // #$applicazione->setModulo($MODULO_CODE);
    // $APP = [
        // "title" => "Amministratori",
        // "url" => "/admin",
        // "code" => $MODULO_CODE
    // ];
    // $session->smarty()->assign("APP", $APP);
    // $session->save();
    
    
    $session->smarty()->assign("REQUEST", $request);
    $session->smarty()->assign("NOW", date('c'));
    $session->save();
});

#
# RELAZIONE USERPROFILE in WIZARD UPDATE
#
$this->respond('GET', '/relation/[USERPROFILE:relation_code]/[new:action]/[master|slave:side]/[:id]', function ($request, $response, $service, $app) {
    $session = getSession();
    
    $relation_code = $request->relation_code;
    $action = $request->action;
    $side = $request->side;
    $side_id = $request->id;
    
    $metarelazione = Relation::load($relation_code);
    
    # Prendo il template della "side" opposta
    # Se l'ID che passiamo è il master
    if ($side == "master") {
        $template = $metarelazione->templateSlave();
    }
    else {
        $template = $metarelazione->templateMaster();
    }
    
    // $session->log($template_code);
    
    // $template = Template::load($template_code);
    
    #echo $template->dbkey();
    
    
    # Cerco tutti i record che non sono già associati al template della side
    
    # Se l'ID che passiamo è il master
    if ($side == "master") {
        $side_dbfield = $metarelazione->dbfieldMaster();
        $other_dbfield = $metarelazione->dbfieldSlave();
    }
    else {
        $side_dbfield = $metarelazione->dbfieldSlave();
        $other_dbfield = $metarelazione->dbfieldMaster();
    }
    $vista = $metarelazione->dbview(); #dbtable();
    
    $sql = "SELECT * _FROM_ {$template->dbview()} WHERE {$template->dbkey()} NOT IN (
                SELECT {$other_dbfield} FROM {$vista} WHERE {$side_dbfield}=?
            )";
    $params = array($side_id); 
    
    
    $tabulator_users = new Tabulator();
    $sql = "SELECT username _FROM_ users";
    $tabulator_users->setSource($sql, array(), $relation_code."USER".$side_id, array(), $metarelazione->get("recordset_code"), "_FROM_");
    
    $tabulator_visibility = new Tabulator();
    $sql = "SELECT visibility_code, label0 _FROM_ Visibilities";
    $tabulator_visibility->setSource($sql, array(), $relation_code."VISIB".$side_id, array(), $metarelazione->get("recordset_code"), "_FROM_");
    
    $session->smarty()->assign("tabulator_users", $tabulator_users);
    $session->smarty()->assign("tabulator_visibility", $tabulator_visibility);
    $session->smarty()->assign("hashing", md5(microtime()));
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("template", $template);
    $session->smarty()->display("modal-relation-user-profile.tpl");
    exit();
});

#
# RELAZIONE in WIZARD UPDATE - POST
#
$this->respond('POST', '/relation/[USERPROFILE:relation_code]/[new:action]/[master|slave:side]/[:id]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    
    $params = $request->params();
    $action = $request->action;
    $side = $request->side;
    $side_id = $request->id;
    
    $selected_rows_users = json_decode($params['users'], true);
    array_change_key_case($selected_rows_users, CASE_LOWER);
    $selected_rows_visib = json_decode($params['visib'], true);
    array_change_key_case($selected_rows_visib, CASE_LOWER);

    $result = new Result();
        
    # Qui creo i nuovi record
    
    try {
        foreach($selected_rows_users as $user) {
            #$session->log($item[$dbkey]);
            $session->log($table);
            $session->log($side_dbfield);
            $session->log($other_dbfield);
            
            $username = $user["username"];
            
            
            $sql = "INSERT INTO RelUserProfile(code,user_code,profile_code)
                    VALUES(?, ?, ?)";
            $res = $db->Execute($sql, array($username.$side_id, $username, $side_id));
            
            foreach($selected_rows_visib as $visib) {
                $visib_code = $visib["visibility_code"];
                $sql = "INSERT INTO RelUserProfileVisibility(code,userprofile_code, visibility_code)
                        VALUES(?, ?, ?)";
                $res = $db->Execute($sql, array($username.$side_id.$visib_code, $username.$side_id, $visib_code));
            }
        }
        
        $result->setResult(true);
        $result->setCode("OK");
        if ($action == 'new')
            $result->setDescription("Inserimento effettuato.");
        else
            $result->setDescription("Eliminazione effettuata.");
        $result->setLevel(Result::INFO);
        echo $result->toJson();
    }
    catch(Result $ex) {
        if ($ex->getLevel() == Result::ERROR)
            echo $ex->toJson();
        elseif (!$ignore_warning)
            echo $ex->toJson();
    }
    exit();
});





#
# RELAZIONE in WIZARD UPDATE
#
$this->respond('GET', '/relation/[:relation_code]/[new:action]/[master|slave:side]/[:id]', function ($request, $response, $service, $app) {
    $session = getSession();
    
    $relation_code = $request->relation_code;
    $action = $request->action;
    $side = $request->side;
    $side_id = $request->id;
    
    $metarelazione = Relation::load($relation_code);
    
    # Prendo il template della "side" opposta
    # Se l'ID che passiamo è il master
    if ($side == "master") {
        $template = $metarelazione->templateSlave();
    }
    else {
        $template = $metarelazione->templateMaster();
    }
    
    // $session->log($template_code);
    
    // $template = Template::load($template_code);
    
    #echo $template->dbkey();
    
    
    # Cerco tutti i record che non sono già associati al template della side
    
    # Se l'ID che passiamo è il master
    if ($side == "master") {
        $side_dbfield = $metarelazione->dbfieldMaster();
        $other_dbfield = $metarelazione->dbfieldSlave();
    }
    else {
        $side_dbfield = $metarelazione->dbfieldSlave();
        $other_dbfield = $metarelazione->dbfieldMaster();
    }
    $vista = $metarelazione->dbview(); #dbtable();
    
    $sql = "SELECT * _FROM_ {$template->dbview()} WHERE {$template->dbkey()} NOT IN (
                SELECT {$other_dbfield} FROM {$vista} WHERE {$side_dbfield}=?
            )";
    $params = array($side_id); 
    
    $tabulator = new Tabulator();
    $tabulator->setSource($sql, $params, $relation_code.$side_id, array(), $metarelazione->get("recordset_code"), "_FROM_");
    
    $session->smarty()->assign("tabulator", $tabulator);
    $session->smarty()->assign("hashing", md5(microtime()));
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("template", $template);
    
    $session->smarty()->display("modal-relation.tpl");
});
#
# RELAZIONE in WIZARD UPDATE - POST
#
$this->respond('POST', '/relation/[:relation_code]/[new|delete:action]/[master|slave:side]/[:id]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $session->log("POST <-----------------------------------");
    
    $params = $request->params();
    #$session->log($params);
    
    $selected_rows = json_decode($params['dati'], true);
    array_change_key_case($selected_rows, CASE_LOWER);
    #$session->log($selected_rows);
    
    
    $relation_code = $request->relation_code;
    $action = $request->action;
    $side = $request->side;
    $side_id = $request->id;
    
    $metarelazione = Relation::load($relation_code);
    
    # Prendo il template della "side" opposta
    # Se l'ID che passiamo è il master
    if ($side == "master") {
        $template = $metarelazione->templateSlave();
    }
    else {
        $template = $metarelazione->templateMaster();
    }
    
    # Se l'ID che passiamo è il master
    if ($side == "master") {
        $side_dbfield = $metarelazione->dbfieldMaster();
        $other_dbfield = $metarelazione->dbfieldSlave();
    }
    else {
        $side_dbfield = $metarelazione->dbfieldSlave();
        $other_dbfield = $metarelazione->dbfieldMaster();
    }
    $code_dbfield = $metarelazione->dbfieldCode();
    
    $table = $metarelazione->dbtable();
    if ($action == 'new') 
        $dbkey = strtolower($template->dbkey());
    else
        $dbkey = $other_dbfield;
    $result = new Result();
        
    # Qui creo i nuovi record
    
    try {
        foreach($selected_rows as $item) {
            #$session->log($item[$dbkey]);
            $session->log($table);
            $session->log($side_dbfield);
            $session->log($other_dbfield);
            
            if ($action == 'new' && strlen($code_dbfield) == 0) 
                $sql = "INSERT INTO {$table} ({$side_dbfield}, {$other_dbfield})
                        VALUES (?, ?)";
            elseif ($action == 'new' && strlen($code_dbfield) > 0) {
                $value_code_dbfield = $side_id.$item[$dbkey];
                $sql = "INSERT INTO {$table} ({$side_dbfield}, {$other_dbfield}, {$code_dbfield})
                        VALUES (?, ?, '{$value_code_dbfield}')";
            }
            else
                $sql = "DELETE FROM {$table} WHERE {$side_dbfield}=? AND {$other_dbfield}=?";
            $session->log($sql);
            $session->log(array($side_id, $item[$dbkey], $item[$code_dbfield]));
            $res = $db->Execute($sql, array($side_id, $item[$dbkey]));
        }
        
        $result->setResult(true);
        $result->setCode("OK");
        if ($action == 'new')
            $result->setDescription("Inserimento effettuato.");
        else
            $result->setDescription("Eliminazione effettuata.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
    }
    catch(Result $ex) {
        if ($ex->getLevel() == Result::ERROR)
            return $ex->toJson();
        elseif (!$ignore_warning)
            return $ex->toJson();
    }
    
    
    
    
    $result->setResult(false);
    $result->setCode("KO");
    if ($action == 'new')
        $result->setDescription("Inserimento fallito.");
    else
        $result->setDescription("Eliminazione fallita.");
    $result->setLevel(Result::ERROR);
    return $result->toJson();
    exit();
});




#
# TEMPLATE new - NUOVA VERSIONE!!!!
#
$this->respond('GET', '/[a:modal_id]/template/[:template_code_x]/[new|update|list:action]/?[:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $record_code = $request->code;
    $modal_id = $request->modal_id;
    $template_code = $request->template_code_x;
    
    $template = Template::load($template_code);
    
    if (strlen($record_code) == 0) {
        $values = $request->params();
        $return_url = $request->param("return_url", "");
    }
    else {
        $record = new Base($template);
        $record->read($record_code);
        $values = $record->fields();
    }
    
    
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("fields", $template->getFields());
    $session->smarty()->assign("values", $values);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("return_url", $return_url);
    $session->smarty()->assign("modal_id", $modal_id);
    $session->smarty()->display("modal-template.tpl");
    exit();
});



#
# TEMPLATE new
#
$this->respond('GET', '/template/[:template_code_x]/[new|update|list:action]/?[:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $record_code = $request->code;
    $template_code = $request->template_code_x;
    
    $params = $request->params();
    $return_url = $request->param("return_url", "");
    
    $template = Template::load($template_code);
    $session->smarty()->assign("template", $template);
    
    $session->smarty()->assign("fields", $template->getFields());
    $session->smarty()->assign("values", $params);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("return_url", $return_url);
    $session->smarty()->display("modal-template.tpl");
    exit();
});

#
# TEMPLATE new - POST
#
$this->respond('POST', '/template/[:code_template]/[new|update|list:action]/?[:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $code = $request->code;
    $template_code = $request->code_template;
    $result = new Result();
    
    $session->log("Template code: ".$template_code);
    
    $params = $request->params();
    $return_url = $request->param("return_url", "");
    $ignore_warnings = ($request->param("ignore_warning", false) == 'S') ? true : false;
    if ($params["custom_action"] == "delete")
        $action = "delete";
    $template = Template::load($template_code);
    $session->log($params);

    # leggiamo i dati da post
    $record = new Base($template);
    if (strlen($code))
        $record->read($code);
    
    #$record->table($template->dbtable());
    $fields = $template->getFields();
    foreach($fields as $metafield) {
        $dbfield = $metafield->dbfield();
        #$session->log("dbfield = ".$dbfield);
        $value = $request->param($dbfield, ""); #get($metafield->dbfield(), "", $_POST);
        $record->set($dbfield, $value);
    }
    
    $session->log($record);
    
    # lanciamo le rules
    try {
        $template->checkRules($record, $ignore_warnings);
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
        elseif (!$ignore_warnings)
            return $ex->toJson();
    }
    
    try {
        if (strlen($code) && $action == 'update') {
            error_log("*** UPDATE RECORD ***");
            $template->store($record, $code);
        }
        elseif (strlen($code) && $action == 'delete') {
            error_log("*** DELETE RECORD ***");
            $template->delete($record, $code);
        }
        else
            $template->store($record);
                
        $result->setResult(true);
        $result->setCode("OK");
        if ($action == 'new')
            $result->setDescription("Inserimento effettuato.");
        elseif ($action == 'update')
            $result->setDescription("Aggiornamento effettuato.");
        elseif ($action == 'delete')
            $result->setDescription("Eliminazione effettuata.");
        else
            $result->setDescription("Azione indefinita.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
    }
    catch(Result $ex) {
        return $ex->toJson();
    }
    
    $result->setResult(false);
    $result->setCode("KO");
    if ($action == 'new')
        $result->setDescription("Inserimento fallito.");
    else
        $result->setDescription("Eliminazione fallita.");
    $result->setLevel(Result::ERROR);
    return $result->toJson();
    exit();
});




















#
# WIZARD new
#
/*$this->respond('GET', '/wizard/[:wizard_code]/[new|update|list:action]/?[:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $wizard_code = $request->wizard_code;
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
        
    if ($action == "new") {
        $index = $wizard->getIndex();
        #var_dump($index);
        #print_r($index);
        
        foreach($index as $key => $item) {
            # per ora andiamo oltre se lo step � completato
            if ($item["pass"] == true)
                continue;
            
            $template_code = $item["template"];
            $template = Template::load($template_code);
            $session->smarty()->assign("template", $template);
                
            if ($item["list"] == false) {
                $session->smarty()->assign("fields", $template->getFields());
                $session->smarty()->assign("values", $params);
                $session->smarty()->display("modal-wizard-template.tpl");
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
    
    echo "DA FARE";
    exit();
});*/



#
# WIZARD NEW
#
$this->respond('GET', '/wizard/new/[:wizard_code]/[i:step_index]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard_code;
    $tab_index = $request->step_index;
    
    $wizard = Wizard::load($wizard_code);
    $wizard->save();
    
    $session->smarty()->assign("wizard_code", $wizard_code);
    $session->smarty()->assign("wizard", $wizard);
    $session->smarty()->assign("id", md5($wizard_code));
    $session->smarty()->assign("step", $tab_index);
    
    $wizard_index = $wizard->getIndex();
    echo __FILE__."(".__LINE__.") WIZARD NEW: /wizard/new/{$wizard_code}/{$tab_index}<br>";
    
    $session->log("TAB index: ".$tab_index);
    
    #
    # Contenitore
    #
    if (strlen($tab_index) == 0) {
        $tabs = array();
        // echo "<pre>";
        // print_r($wizard->getIndex());
        // echo "</pre>";
        foreach($wizard_index as $key => $item) {
            if ($key == 0) {
                $template_code = $item["template"];
                $template = Template::load($template_code);
                $tabs[$key] = $template->label();
            }
            else {
                if ($item["relation"]["readonly"] == 'N')
                    $tabs[$key] = $item["relation"]["label0"];
            }
            
        }
        $session->smarty()->assign("tabs", $tabs);
        $session->smarty()->assign("tab", $tab_index);
        $session->smarty()->display("modal-wizard-new.tpl");
        exit();
    }
    #
    # Template
    #
    elseif ($tab_index == 0) {
        
        $template_code = $wizard_index[0]["template"];
        $template = Template::load($template_code);
        
        $values = array();
        if (isset($wizard_index[0]["records"][0])) {
            $record = $wizard_index[0]["records"][0];
            if ($record) {
                $values = $record->fields();
            }
        }
    
        $session->smarty()->assign("template", $template);
        $session->smarty()->assign("values", $values);
        $session->smarty()->assign("step", $tab_index);
        $session->smarty()->display("modal-wizard-new-template.tpl");
        
        echo "<pre>";
        print_r($wizard_index[0]);
        echo "</pre>";
        exit();
    }
    #
    # Relazione
    #
    elseif ($tab_index > 0) {
        $list = $wizard_index[$tab_index]["list"];
        $relation = $wizard_index[$tab_index]["relation"];
        $record_code = "";
        
        // echo date('c');
        if ($list && is_array($relation)) {
            $vista = $relation["dbview"];
            $master_dbfield = $relation["master_dbfield"];
            $relation_code = $relation["relation_code"];
            
            
            # La relazione è gestita da una CLASSE PHP
            if (strlen($relation["class"]) > 0) {
                $classe = strtolower($relation["class"]);
                require_once "../src/classes/{$classe}.class.php";
                $classe = $relation["class"];
                $obj = new $classe();
                $obj->setParent(0);
                $obj->setWizard($wizard);
                
                #$session->smarty()->display("modal-wizard-add-relation.tpl");
                
                $session->smarty()->assign("relation", $relation);
                $session->smarty()->assign("object", $obj);
                $session->smarty()->assign("id", md5(microtime()));
                $session->smarty()->display("modal-wizard-new-object.tpl");
                
                echo "<pre>";
                print_r($wizard_index[$tab_index]["records"]);
                echo "</pre>";
            }
            # la relazione è generica
            else {
            
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
                $session->log($sql);
                $session->log($params);
                $tabulator = new Tabulator();
                $tabulator->setMemoryWizard($wizard_code, $tab_index, array($master_dbfield), $relation["recordset_code"]);
                #$tabulator->setSource($sql, $params, $relation_code.$record_code, array($master_dbfield), $relation["recordset_code"]);
                #$tabulator->setTitle("Elenco SIM");
                
                $session->smarty()->assign("hashing", md5($relation_code.$record_code));
                $session->smarty()->assign("tabulator", $tabulator);
                $session->smarty()->assign("relation", $relation);
                $session->smarty()->assign("record_code", $record_code);
                $session->smarty()->assign("id", "modal".md5($relation_code.$record_code));
                $session->smarty()->assign("REQUEST", $request);
                $session->smarty()->assign("tab_index", $tab_index);
                $session->smarty()->assign("refresh_uri", "/wizard/update/{$wizard_code}/{$record_code}?tab={$tab_index}");
                
                $session->smarty()->display("modal-wizard-new-relation.tpl");
            }
        }
        echo "<pre>";
        print_r($relation);
        echo "</pre>";
        
        exit();
    }
    
    // $session->smarty()->assign("configurazione", $configurazione);
    
});
#
# WIZARD NEW - POST
#
$this->respond('POST', '/wizard/new/[:wizard_code]/[i:step_index]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard_code;
    $record_code = $request->record_code;
    $tab_index = $request->step_index;
    $tab = $request->param("tab", "") ;
    $result = new Result();
    
    $wizard = Wizard::load($wizard_code);
    $wizard->save();
    
    $index = $wizard->getIndex();
    
    $session->log("Wizard Modal: {$wizard_code}, action: new");
    $ignore_warnings = ($request->param("ignore_warning", false) == 'S') ? true : false;
    
    # Template
    if ($tab_index == 0) {
        $key = 0;
        $template_code = $index[$key]["template"];
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
            $template->check($record, 'I', $ignore_warnings);
        }
        catch(Result $result) {
            return $result->toJson();
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
    # Relazione
    else {
        
    }
    
    $result->setResult(false);
    $result->setCode("KO");
    $result->setDescription("Indice wizard non valido");
    $result->setLevel(Result::ERROR);
    return $result->toJson();
});





















#
# RELAZIONE in WIZARD NEW
#
$this->respond('GET', '/wizard/[:wizard_code]/relation/[:relation_code]/[new:action]/[master|slave:side]/[:step]', function ($request, $response, $service, $app) {
    $session = getSession();
    
    $wizard_code = $request->wizard_code;
    $relation_code = $request->relation_code;
    $action = $request->action;
    $side = $request->side;
    $step = $request->step;
    
    
    $wizard = Wizard::load($wizard_code);
    $wizard->save();
    
    $metarelazione = Relation::load($relation_code);
    
    # La relazione è gestita da una CLASSE PHP
    if (strlen($metarelazione->class()) > 0) {
        $classe = strtolower($metarelazione->class());
        require_once "../src/classes/{$classe}.class.php";
        $classe = $metarelazione->class();
        $obj = new $classe();
        $obj->setParent(0);
        $obj->setWizard($wizard);
        $session->smarty()->assign("action", $action);
        $session->smarty()->assign("object", $obj);
        $session->smarty()->assign("id", md5(microtime()));
        $session->smarty()->display("modal-wizard-add-object.tpl");
    }
    # la relazione è generica
    else {
        # Prendo il template della "side" opposta
        # Se l'ID che passiamo è master
        if ($side == "master") {
            $template = $metarelazione->templateSlave();
        }
        else {
            $template = $metarelazione->templateMaster();
        }
        
        // $session->log($template_code);
        
        // $template = Template::load($template_code);
        
        #echo $template->dbkey();
        
        
        # Cerco tutti i record che non sono già ssociati al template della side
        
        # Se l'ID che passiamo è master
        if ($side == "master") {
            $side_dbfield = $metarelazione->dbfieldMaster();
            $other_dbfield = $metarelazione->dbfieldSlave();
        }
        else {
            $side_dbfield = $metarelazione->dbfieldSlave();
            $other_dbfield = $metarelazione->dbfieldMaster();
        }
        $vista = $metarelazione->dbview(); #dbtable();
        
        $sql = "SELECT * _FROM_ {$template->dbview()} WHERE {$template->dbkey()} NOT IN (
                    SELECT {$other_dbfield} FROM {$vista} WHERE {$side_dbfield}=?
                )";
        $params = array($side_id); 
        
        $tabulator = new Tabulator();
        $tabulator->setSource($sql, $params, $relation_code.$side_id, array(), $metarelazione->get("recordset_code"), "_FROM_");
        
        $session->smarty()->assign("tabulator", $tabulator);
        $session->smarty()->assign("hashing", md5(microtime()));
        $session->smarty()->assign("action", $action);
        $session->smarty()->assign("template", $template);
        $session->smarty()->display("modal-wizard-add-relation.tpl");
    }
});


#
# RELAZIONE in WIZARD NEW - POST
#
$this->respond('POST', '/wizard/[:wizard_code]/relation/[:relation_code]/[new|create|delete:action]/[master|slave:side]/[:step]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $session->log("POST <-----------------------------------");
    
    $params = $request->params();
    #$session->log($params);
    
    
    $relation_code = $request->relation_code;
    $action = $request->action;
    $side = $request->side;
    //$side_id = $request->id;
    $step = $request->step;
    $ignore_warnings = ($request->param("ignore_warning", false) == 'S') ? true : false;
    
    $wizard_code = $request->wizard_code;
    $result = new Result();
    
    $wizard = Wizard::load($wizard_code);
    $wizard->save();
    
    $wizard_index = $wizard->getIndex();
    
    
    
    $metarelazione = Relation::load($relation_code);
    
    # La relazione è gestita da una CLASSE PHP
    if (strlen($metarelazione->class()) > 0) {
        $classe = strtolower($metarelazione->class());
        require_once "../src/classes/{$classe}.class.php";
        $classe = $metarelazione->class();
        $obj = new $classe();
        $obj->setParent(0);
        #$obj->setWizard($wizard);
        
        
        
        
        
        
        
        
        $key = $step;
        // $template_code = $wizard_index[$key]["template"];
        // $template = Template::load($template_code);
        
        // # leggiamo i dati da post
        // $record = $template->import($_POST);
        // $session->log($_POST);
        // $session->log($record);
        $record = $obj->import($_POST);
        
        # lanciamo le rules
        /*try {
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
        }*/
        
        # memorizziamo l'oggetto in memoria
        $key2 = count($wizard_index[$key]["records"]);
        $wizard->setIndexRecord($key, $key2, $record);
        #$wizard->setIndexPass($key, true);
        $wizard->save();
    
        $result->setResult(true);
        $result->setCode("OK");
        $result->setDescription("Oggetto {$template_code} memorizzato.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
        
        
        
        
        
        
        
        
    }
    # la relazione è generica
    else {
        # Prendo il template della "side" opposta
        # Se l'ID che passiamo è master
        if ($side == "master") {
            $template = $metarelazione->templateSlave();
        }
        else {
            $template = $metarelazione->templateMaster();
        }
        
        # Se l'ID che passiamo è master
        if ($side == "master") {
            $side_dbfield = $metarelazione->dbfieldMaster();
            $other_dbfield = $metarelazione->dbfieldSlave();
        }
        else {
            $side_dbfield = $metarelazione->dbfieldSlave();
            $other_dbfield = $metarelazione->dbfieldMaster();
        }
        
        if ($action == 'new') 
            $dbkey = strtolower($template->dbkey());
        else
            $dbkey = $other_dbfield;
        
        #
        # l'oggetto della relazione esiste già
        #
        if ($action == 'new') {
            $selected_rows = json_decode($params['dati'], true);
            array_change_key_case($selected_rows, CASE_LOWER);
            #$session->log($selected_rows);
        }
        #
        # l'oggetto non esiste e andrà creato
        #
        elseif ($action == 'create') {
            
            # leggiamo i dati da post
            $record = new Base($template);
            
            $session->log("*** POST +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
            $session->log($_POST);
            $session->log("----------------------------------------------------------------------");
            
            #$record->table($template->dbtable());
            $fields = $template->getFields();
            foreach($fields as $metafield) {
                $value = get($metafield->dbfield(), "", $_POST);
                $record->set($metafield->dbfield(), $value);
            }
        
            
        }
        
        # Verifichiamo campi obbligatori, regole, ecc.
        try {
            $template->check($record, 'I', $ignore_warnings);
        }
        catch(Result $result) {
            return $result->toJson();
        }
        
        
        
        
        # Qui creo i nuovi record
        try {
            $index = $wizard_index[$step];
            // $relation_model = $index["relation"];
            // $dbkeyfield = $relation_model["slave_code"];
            
            if ($action == 'new') {
                foreach($selected_rows as $item) {
                    #$session->log($item[$dbkey]);
                    $session->log($table);
                    $session->log($side_dbfield);
                    $session->log($other_dbfield);
                    $session->log($template->dbkey());
                    $session->log($item);
                    
                    
                    $wizard->setIndexLinked($step, $item[$template->dbkey()], $template->code()." ".$item[$template->dbkey()]);
                        

                    
                    // else
                        
                }
            }
            elseif ($action == 'create') {
                $step2 = count($index["records"]);
                $wizard->setIndexRecord($step, $step2, $record);
            }
            //else {
                // $sql = "DELETE FROM {$table} WHERE {$side_dbfield}=? AND {$other_dbfield}=?";
                    // $session->log($sql);
                    // $session->log(array($side_id, $item[$dbkey]));
                    // $res = $db->Execute($sql, array($side_id, $item[$dbkey]));
            //}
            $wizard->setIndexPass($step, true);
            $wizard->save();
            
            $result->setResult(true);
            $result->setCode("OK");
            if ($action == 'new' || $action == 'create')
                $result->setDescription("Inserimento effettuato.");
            else
                $result->setDescription("Eliminazione effettuata.");
            $result->setLevel(Result::INFO);
            return $result->toJson();
        }
        catch(Result $ex) {
            if ($ex->getLevel() == Result::ERROR)
                return $ex->toJson();
            elseif (!$ignore_warning)
                return $ex->toJson();
        }
    }
    
    
    
    $result->setResult(false);
    $result->setCode("KO");
    if ($action == 'new')
        $result->setDescription("Inserimento fallito.");
    else
        $result->setDescription("Eliminazione fallita.");
    $result->setLevel(Result::ERROR);
    return $result->toJson();
    exit();
});