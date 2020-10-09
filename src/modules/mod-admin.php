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

    $MODULO_CODE = "ADMIN";
    #$applicazione->setModulo($MODULO_CODE);
    $APP = [
        "title" => "Amministratori",
        "url" => "/admin",
        "code" => $MODULO_CODE
    ];
    $session->smarty()->assign("APP", $APP);
    $session->save();
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
    #$configurazione[$i]["link"] = APP_BASE_URL."/wizard/users/list";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/users/list";
    
    // $i++;
    // $configurazione[$i]["nome"] = "Templates";
    // $configurazione[$i]["icona"] = "project diagram";
    // $configurazione[$i]["link"] = APP_BASE_URL."/wizard/systemplates/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Templates";
    $configurazione[$i]["icona"] = "project diagram";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/systemplates/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Recordsets";
    $configurazione[$i]["icona"] = "table";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/sysrecordsets/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Analisi";
    $configurazione[$i]["icona"] = "database";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/procedures/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Alberi e liste";
    $configurazione[$i]["icona"] = "tree";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/classtype/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Ruoli";
    $configurazione[$i]["icona"] = "user tag";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/role/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Moduli";
    $configurazione[$i]["icona"] = "sitemap";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/module/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Profili";
    $configurazione[$i]["icona"] = "tasks";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/profile/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Azioni";
    $configurazione[$i]["icona"] = "award";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/action/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Menu";
    $configurazione[$i]["icona"] = "sidebar";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/menu/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Visibilità";
    $configurazione[$i]["icona"] = "eye";
    $configurazione[$i]["link"] = APP_BASE_URL."/admin/config/visibility/list";
    
    $i++;
    $configurazione[$i]["nome"] = "Sync";
    $configurazione[$i]["icona"] = "sync alternate";
    $configurazione[$i]["link"] = APP_BASE_URL."/sys/sync/objects";
    
    
    // $i++;
    // $configurazione[$i]["nome"] = "Procedure (via template wizard)";
    // $configurazione[$i]["icona"] = "database";
    // $configurazione[$i]["link"] = APP_BASE_URL."/wizard/list/METAPROCEDURES";
    
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
// $this->respond('GET', '/wizard/[:wizard]/[new|update|list:action]/[a:code]?', function ($request, $response, $service, $app) {
    // $db = getDB();
    // $session = getSession();
    // $action = $request->action;
    // $wizard_code = $request->wizard;
    // $code = $request->code;
    
    // $wizard = Wizard::load($wizard_code);
    // $wizard->save();
    
    // $session->smarty()->assign("wizard_code", $wizard_code);
        
    // if ($action == "list") {
        // if (isset($_SESSION['WIZARDS']))
            // unset($_SESSION['WIZARDS']);
        // $sql = "SELECT TOP 1 * FROM {$wizard->dbview()}";
        // $rs = $db->Execute($sql);
        // $records = $rs->GetArray();
        // $session->smarty()->assign("record", $records[0]);
        // $session->smarty()->display("admin-elenco.tpl");
        // exit();
    // }
    // elseif ($action == "new") {
        // $index = $wizard->getIndex();
        // #var_dump($index);
        // #print_r($index);
        
        // foreach($index as $key => $item) {
            // # per ora andiamo oltre se lo step è completato
            // if ($item["pass"] == true)
                // continue;
            
            // $template_code = $item["template"];
            // $template = Template::load($template_code);
            // $session->smarty()->assign("template", $template);
                
            // if ($item["list"] == false) {
                // $session->smarty()->assign("fields", $template->getFields());
                // $session->smarty()->display("admin-wizard-template.tpl");
                // exit();
            // }
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
        // }
        
        // $session->smarty()->assign("template", $template);
        // $session->smarty()->display("admin-wizard-save.tpl");
        // exit();
    // }
    
    
    // echo "DA FARE";
    // exit();
// });
#----------------------------------------------------------------------------------------------------------------------------------------------
# Salviamo i dati del template principale e salviamo il wizard
$this->respond('POST', '/wizard/[:wizard]/[new|update|save:action]/[a:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $action = $request->action;
    $wizard_code = $request->wizard;
    $code = $request->code;
    $result = new Result();
    $ignore_warning = toBool($request->ignore_warning);
    $session->log("Ignore Warning: {$ignore_warning}");
    
    $wizard = Wizard::load($wizard_code);
    $wizard->save();
    $index = $wizard->getIndex();
    
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
                $key2 = 0; # perché $item["list"] == false
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
    elseif ($action == "save") {
    
        try {
            $wizard->saveIndex();
            
        }
        catch(Result $ex) {
            return $ex->toJson();
        }
    
    
    
    
        $result->setResult(true);
        $result->setCode("OK");
        $result->setDescription("Wizard {$wizard_code} completato.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
    }
    
    $result->setResult(false);
    $result->setCode("KO");
    $result->setDescription("Azione non supportata.");
    $result->setLevel(Result::ERROR);
    return $result->toJson();
});

#----------------------------------------------------------------------------------------------------------------------------------------------
# Salviamo i dati di un template (escluso il template principale)
$this->respond('POST', '/wizard/[:wizard]/new/[i:index]/[:template]', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    $wizard_code = $request->wizard;
    $template_code = $request->template;
    $index_pos = $request->index;
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
    $rules_ok = true;
    
    if (!$rules_ok) {
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription("Template: {$template_code}.");
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }
    else {
        # memorizziamo l'oggetto in memoria
        $key2 = count($index[$index_pos]["records"]);
        $wizard->setIndexRecord($index_pos, $key2, $record);
        $wizard->save();
    
        $result->setResult(true);
        $result->setCode("OK");
        $result->setDescription("Template {$template_code} memorizzato.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
    }
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
$this->respond('POST', '/wizard/[:wizard]/new/pass/[i:index]', function ($request, $response, $service, $app) {
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
        # memorizziamo l'oggetto in memoria
        $wizard->setIndexPass($index_pos, true);
        $wizard->save();
    
        $result->setResult(true);
        $result->setCode("OK");
        $result->setDescription("Relazione completata.");
        $result->setLevel(Result::INFO);
        return $result->toJson();
    }
});







#
# Disegnamo il FORM del TEMPLATE dinamicamente
#
$this->respond(array('GET', 'POST'), '/template/[:template_code]/[new|update:action]/[a:code]?', function ($request, $response, $service, $app) {
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

    json_tabulator_recordset($sql);
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
                WHERE master_code='{$master_code}'
            )  ";
    $session->log($sql);
    json_tabulator_recordset($sql, "_FROM_");
});



function pagina_elenco2($request, $response, $service, $app) {
    GLOBAL $session, $MODULO_CODE;
    $classe_padre = $request->classe_padre;
    $chiave = $request->chiave;
    $relazione = $request->relazione;
    $db = getDB();
    $breadcrumbs = $_SESSION[$MODULO_CODE]["breadcrumbs"];
    
    #$code = getVar("GET", "code", null);
    #$chiave = get("chiave", null);
    #$relazione = get("relazione", null);
    #$classe_padre = get("classe", null);

    ###################################################################
    # RELAZIONE
    ###################################################################
    if (strlen($relazione)) {
        $sql = "SELECT * FROM MetaRelazioni WHERE code='{$relazione}'";
        #echo $sql."<br>";
        $rs = $db->Execute($sql);

        if ($rs !== false) {
            $vista = $rs->Fields("vista");
            $classe_padre = $rs->Fields("code_padre");
            $classe_figlio = $rs->Fields("code_figlio");
            
            if (strlen($vista))
                $query = $vista;
        }
        
        $oggetto_figlio = new MetaOggetto();
        $oggetto_figlio->loadFromCode($classe_figlio);
        $campo_chiave_figlio = $oggetto_figlio->campoChiave();
    }
    #echo "campo_chiave_figlio: {$campo_chiave_figlio}<br>";
        
    ###################################################################
    if (strlen($classe_padre) == 0) {
        die("Classe non dichiarata. Impossibile continuare.");
    }

    ###################################################################
    # OGGETTO
    ###################################################################
    $oggetto_padre = new MetaOggetto();
    $oggetto_padre->loadFromCode($classe_padre);
    if (strlen($query) == 0)
        $query = $oggetto_padre->query();
    $campo_chiave_padre = $oggetto_padre->campoChiave();

    if (strlen($query) == 0) {
        die("Elenco non disponibile. Impossibile continuare.");
    }

    ###################################################################
    # FILTRO
    ###################################################################
    $filtro = " WHERE 1=1 ";
    if (strlen($chiave)) {
        $filtro .= " AND [{$campo_chiave_padre}]='{$chiave}' ";
    }
    #print_r($_POST);

    ###################################################################
    # Elenco
    ###################################################################
    error_log("NAVIGA elenco: ".$query.$filtro);
    $_SESSION[$MODULO_CODE]["query"] = $query.$filtro;
    $rs = $db->Execute($query.$filtro);
    $elenco = array();
    if ($rs != FALSE) {
        $elenco = $rs->GetArray();
    }
    #DEBUG($campi);
    #DEBUG($elenco[0]);
    $numfields = $rs->FieldCount();
    $tipi_campi = array();
    for ($f=0; $f<$numfields; $f++) {
        $field = $rs->FetchField($f);
        #print_r($field);
        $nomecampo = strtolower($field->name);

        switch($field->type) {
                case "int4":
                case "int":
                case "real":
                case "numeric":
                case "money":
                    $tipi_campi[$nomecampo] = "numero";
                    break;

                case "timestamptz":
                case "datetime":
                case "datetime2":
                    $tipi_campi[$nomecampo] = "data";
                    break;

                case "char":
                case "varchar":
                    $tipi_campi[$nomecampo] = "stringa";
                    break;

                default:
                    $tipi_campi[$nomecampo] = $field->type;
                    break;
        }
        $session->log($field->type." -> ".$nomecampo."=".$tipi_campi[$nomecampo]);
    }
    #-----------------------------------------------------------------------------

    $_SESSION[$MODULO_CODE]["tipi_campi"] = $tipi_campi;
          
    ###################################################################
    # ASSEGNAZIONI
    ###################################################################
    #$ignora_history = true;
    #require_once("include/common_footer.inc");
    $session->smarty()->assign("breadcrumbs", $breadcrumbs);
    $session->smarty()->assign("oggetto_padre", $oggetto_padre);
    $session->smarty()->assign("chiave", $chiave);
    $session->smarty()->assign("records", $elenco);
    $session->smarty()->assign("record", $elenco[0]);
    $session->smarty()->display("admin-elenco.tpl");
    exit();
}