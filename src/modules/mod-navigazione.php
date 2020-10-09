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

    $MODULO_CODE = "NAVIGAZIONE";
    #$applicazione->setModulo($MODULO_CODE);
    $APP = [
        "title" => "Navigazione",
        "url" => APP_BASE_URL."/navigazione",
        "code" => $MODULO_CODE
    ];
    $session->smarty()->assign("APP", $APP);
    $session->save();
    $session->log("Navigazione PARENT");
});



#
# INDEX
#
$this->respond('GET', '/?', function ($request, $response, $service, $app) {
    $MODULO_CODE = "NAVIGAZIONE";
    if (isset($_SESSION[$MODULO_CODE]["breadcrumbs"]))
        unset($_SESSION[$MODULO_CODE]["breadcrumbs"]);
    $session = getSession();
    $session->log("navigazione index");
    $session->smarty()->display("navigazione-index.tpl");
});


#
# ELENCO
#
$this->respond('GET', '/elenco/[:classe_padre]', function ($request, $response, $service, $app) { return pagina_elenco($request, $response, $service, $app); });
$this->respond('GET', '/relazione/[:relazione]/[:chiave]', function ($request, $response, $service, $app) { return pagina_elenco($request, $response, $service, $app); });


#
# OGGETTO
#
$this->respond('GET', '/oggetto/[:classe]/[:code]', function ($request, $response, $service, $app) {
    $session = getSession();
    $MODULO_CODE = "NAVIGAZIONE";
    $db = getDB();
    $classe = $request->classe;
    $code = $request->code;
    $session->log("MODULO_CODE = ".$MODULO_CODE);
    $breadcrumbs = $_SESSION[$MODULO_CODE]["breadcrumbs"];
    
    #$campo_chiave = getVar("GET", "campo_chiave", null);
    #$relazione = getVar("GET", "relazione", null);

    ###################################################################
    if (strlen($classe) == 0) {
        die("Classe non dichiarata. Impossibile continuare.");
    }

    #***************************************************************
    # OGGETTO e CAMPI
    #***************************************************************
    #$oggetto = new MetaOggetto();
    $template = Template::load($classe);
    $query = "SELECT * FROM {$template->dbview()}";
    $campo_chiave_padre = $template->dbkey();
    $recordset_code = $template->get("recordset_code");

    if (strlen($query) == 0) {
        die("Elenco non disponibile. Impossibile continuare.");
    }

    ###################################################################
    # BREADCRUMBS
    ###################################################################
    $current_item = $breadcrumbs["current"];
    $label = $template->label()." ".$code;
    if ($breadcrumbs["list"][$current_item] != $label) {
        $current_item++;
        $breadcrumbs["current"] = $current_item;
        $breadcrumbs["list"][$current_item] = $label; #$oggetto_padre->label();
        $breadcrumbs["url"][$current_item] = $_SERVER["REQUEST_URI"];
        $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    }
    $trovato = false;
    // foreach($breadcrumbs["list"] as $key => $item) {
        // if ($trovato)
            // unset($breadcrumbs["list"][$key]);
        // if ($item == $label) {
            // $trovato = true;
        // }
    // }
    if ($trovato)
        $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    
    ###################################################################
    # FILTRO
    ###################################################################
    $filtro = "";
    if (strlen($campo_chiave)) {
        $filtro = " WHERE [{$campo_chiave}]='{$code}' ";
    }
    elseif (strlen($campo_chiave_padre)) {
        $filtro = " WHERE [{$campo_chiave_padre}]='{$code}' ";
    }
    
    $recordset = array();
    # Se c'è una configurazione del RECORDSET, la uso:
    if (strlen($recordset_code)) {
        # Prendo la configurazione del recordset
        $sql3 = "SELECT * FROM RecordsetColumns WHERE recordset_code=? ORDER BY sorting";
        $rs = $db->Execute($sql3, array($recordset_code));
        
        while(!$rs->EOF) {
            $dbcolumn = $rs->Fields("dbcolumn");
            $label = $rs->Fields("label0");
            $visible = $rs->Fields("flag_visible");
            if ($visible == 'S')
            $recordset[$dbcolumn] = $label;
            $rs->MoveNext();
        }
    }

    ###################################################################
    # RECORD
    ###################################################################
    $session->log("Navigazione Oggetto: ".$query.$filtro);
    $rs = $db->Execute($query.$filtro);
    #echo $query.$filtro;
    $record = array();
    if ($rs != FALSE) {
        $record = $rs->FetchRow();
    }

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
        #error_log($nomecampo."=".$tipi_campi[$nomecampo]);
        
        if (strlen($recordset_code) == 0) {
            $recordset[$nomecampo] = $nomecampo;
        }
    }
    $_SESSION[$MODULO_CODE]["tipi_campi"] = $tipi_campi;
    #-----------------------------------------------------------------------------
        
        
    ###################################################################
    # RELAZIONI - PADRE (cerco i figli)
    ###################################################################
    $sql = "SELECT * FROM MetaRelations WHERE master_code=? ORDER BY sorting";
    $rs = $db->Execute($sql, array($template->code()));

    $relazioni_padre = [];
    if ($rs !== false) {
        while(!$rs->EOF) {
            $code_figlio = $rs->Fields("slave_code");
            $row = $rs->FetchRow(); 
            #$template_figlio = Template::load($code_figlio);
            $row["label_figlio"] = $row["label0"]; #$template_figlio->label();
            $relazioni_padre[] = $row;
        }

    }
    
    if (strlen($template->get("class"))) {
        $phpclasse = $template->get("class");
        #require_once("../src/classes/".strtolower($phpclasse).".class.php");
        $classe_template = new $phpclasse($classe);
        $session->smarty()->assign("classe_template", $classe_template);
    }

    ###################################################################
    # ASSEGNAZIONI
    ###################################################################
    $session->smarty()->assign("oggetto", $template);
    $session->smarty()->assign("campo_chiave", $campo_chiave);
    $session->smarty()->assign("chiave", $code);
    $session->smarty()->assign("relazioni_padre", $relazioni_padre);
    $session->smarty()->assign("relazioni_figlio", $relazioni_figlio);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("recordset", $recordset);
    $session->smarty()->assign("breadcrumbs", $_SESSION[$MODULO_CODE]["breadcrumbs"]);
    $session->smarty()->assign("X", new X("NAVIGAZIONE"));

    $session->smarty()->display('navigazione-oggetto.tpl');
});


#
# API
#
$this->respond('GET', '/api?', function ($request, $response, $service, $app) {
    $session = getSession();
    $MODULO_CODE = "NAVIGAZIONE";
    $db = getDB();

    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 100);
    $offset = ($page-1) * $size;

    $sql = $_SESSION[$MODULO_CODE]["query"];

    foreach($filters as $filter) {
        $name = "[{$filter['field']}]";
        $type = $filter["type"];
        $value = $filter["value"];
        
        $sql .= " AND {$name} {$type} '%{$value}%' ";
    }
    if (count($sorters)) {
        $sql .= " ORDER BY ";
        foreach($sorters as $sorter) {
            $name = "[{$sorter['field']}]";
            $dir = $sorter["dir"];
            
            $sql .= "{$name} {$dir},";
        }
        $sql = substr($sql, 0, -1);
    }
    else
        $sql .= " ORDER BY 1 ";

    $sql .= " OFFSET {$offset} ROWS FETCH NEXT {$size} ROWS ONLY";

    # aggiungiamo COUNT(*) OVER()
    $sql = str_ireplace("FROM", ",COUNT(*) OVER() as c FROM", $sql);

    $rs = $db->Execute($sql);
    $data = array();
    if ($rs != FALSE) {
        // while(!$rs->EOF) {
            // $data[] = $rs->FetchRow(); #$rs->fetchObj();
            // #$rs->MoveNext();
        // }
        $data = $rs->GetArray();
    }

    $result = [
        "last_page" => ceil($data[0]["c"] / $size),
        "data" => $data
    ];
    //return JSON formatted data
    echo(json_encode($result)); 
});



$this->respond('GET', '/info', function ($request, $response, $service, $app) {
    echo "MOD WEB ONLINE<br>";
    echo "URI: ".$request->uri()."<br>";
    echo "PATHNAME: ".$request->pathname()."<br>";
    echo "METHOD: ".$request->method()."<br>";
    echo "-----------------------------------------------------------<br>";
    
});

















#$this->respond('GET', '/elenco/[a:classe_padre]', function ($request, $response, $service, $app) { return pagina_elenco($request, $response, $service, $app); });
#$this->respond('GET', '/relazione/[a:relazione]/[a:chiave]', function ($request, $response, $service, $app) { return pagina_elenco($request, $response, $service, $app); });



#/navigazione/elenco/EDIFICIO


function pagina_elenco($request, $response, $service, $app) {
    $session = getSession();
    $MODULO_CODE = "NAVIGAZIONE";
    
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
        $sql = "SELECT * FROM MetaRelations WHERE relation_code=?";
        #echo $sql."<br>";
        $rs = $db->Execute($sql, array($relazione));

        if ($rs !== false) {
            $vista = "SELECT * FROM {$rs->Fields("dbview")}";
            $classe_padre = $rs->Fields("master_code");
            $classe_figlio = $rs->Fields("slave_code");
            $campo_chiave_padre = $rs->Fields("master_dbfield");
            $recordset_code = $rs->Fields("recordset_code");
            
            if (strlen($vista))
                $query = $vista;
        }
        
        $oggetto_figlio = Template::load($classe_figlio);
        $campo_chiave_figlio = $oggetto_figlio->dbkey();
    
        #echo "campo_chiave_figlio: {$campo_chiave_figlio}<br>";
            
        ###################################################################
        if (strlen($classe_padre) == 0) {
            die("Classe '{$classe_padre}' non dichiarata. Impossibile continuare.");
        }
    }
    else {
        ###################################################################
        # OGGETTO
        ###################################################################
        $template = Template::load($classe_padre);
        #$oggetto_padre->loadFromCode($classe_padre);
        $query = "SELECT * FROM {$template->dbview()}";
        $campo_chiave_padre = $template->dbkey();

        if (strlen($query) == 0) {
            die("Elenco non disponibile. Impossibile continuare.");
        }
        $recordset_code = $template->get("recordset_code");
    }

    ###################################################################
    # BREADCRUMBS
    ###################################################################

    $current_item = $breadcrumbs["current"];

    if (strlen($relazione) == 0) 
        $label = $template->label();
    else
        $label = $oggetto_figlio->label();
    if ($breadcrumbs["list"][$current_item] != $label) {
        $current_item++;
        $breadcrumbs["current"] = $current_item;
        $breadcrumbs["list"][$current_item] = $label;
        $breadcrumbs["url"][$current_item] = $_SERVER["REQUEST_URI"];
        $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    }
    $trovato = false;
    // foreach($breadcrumbs["list"] as $key => $item) {
        // if ($trovato)
            // unset($breadcrumbs["list"][$key]);
        // if ($item == $label) {
            // $trovato = true;
        // }
    // }
    if ($trovato)
        $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
        

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
    $params = array();
    
    $tabulator = new Tabulator();
    $tabulator->setSource($query.$filtro, $params, $relazione.$classe_padre, array(), $recordset_code);
    $tabulator->setSourceConfigUrl("/admin/config/templates/update/".$classe_padre);
    
    ###################################################################
    # ASSEGNAZIONI
    ###################################################################
    #$ignora_history = true;
    #require_once("include/common_footer.inc");
    $session->smarty()->assign("breadcrumbs", $breadcrumbs);
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("chiave", $chiave);
    // $session->smarty()->assign("records", $elenco);
    // $session->smarty()->assign("record", $elenco[0]);
    $session->smarty()->assign("hashing", md5($relazione.$classe_padre));
    $session->smarty()->assign("tabulator", $tabulator);
    if (strlen($campo_chiave_figlio)) {
        $session->smarty()->assign("campo_chiave", $campo_chiave_figlio);
        $session->smarty()->assign("classe", $classe_figlio);
    }
    else {
        $session->smarty()->assign("campo_chiave", $campo_chiave_padre);
        $session->smarty()->assign("classe", $classe_padre);
    }
    $session->smarty()->display("navigazione-elenco.tpl");
    exit();
}