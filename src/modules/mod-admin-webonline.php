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

    $MODULO_CODE = "WOL";

    $session->smarty()->assign("WOLPATH", ROOT_DIR.APP_BASE_URL."/admin/webonline");
    $session->save();
});


#
# INDEX
#
$this->respond('GET', '/?', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    GLOBAL $DBWM;
    $session = getSession();
    $db = getDB();
    
    $tipo = "all";
    
    $sql = "SELECT v.label0 as categoria,
            p.code, p.sp, p.label0, p.tipo, p.help_lungo0
            FROM Procedures p
            LEFT JOIN MetaVoci v ON p.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
            --WHERE (p.tipo='{$tipo}' OR '{$tipo}'='all')";
    $rs = $db->Execute($sql); 
    $record = $rs->GetRow();
    
    $tabulator_procedure = new Tabulator();
    $tabulator_procedure->setSource($sql, null, "ProceduresSLIST");
    #$tabulator_procedure->setTitle("Colonne configurate");

    #$session->smarty()->assign("template", $template);
    $session->smarty()->assign("tabulator_procedure", $tabulator_procedure);
    $session->smarty()->display("admin-webonline-index.tpl");
    exit();
});


#
# PROCEDURE
#
$this->respond('GET', '/procedure/?[:categoria]?/?[a:tipo]?', function ($request, $response, $service, $app) {
    GLOBAL $DBWM;
    $session = getSession();
    $MODULO_CODE = $session->get("MODULO_CODE");
    $tipo = $request->tipo;
    $categoria = $request->categoria;
    $db = getDB();
    
    // if (isset($_SESSION[$MODULO_CODE]))
		// unset($_SESSION[$MODULO_CODE]);

    if (strlen($tipo) > 0) {
        $_SESSION[$MODULO_CODE]['tipo'] = $tipo;
    }
    elseif (isset($_SESSION[$MODULO_CODE]['tipo'])) {
        $tipo = $_SESSION[$MODULO_CODE]['tipo'];
    }
    else
        $tipo = 'all';

    if (strlen($categoria) > 0) {
        $_SESSION[$MODULO_CODE]['categoria'] = $categoria;
    }
    elseif (isset($_SESSION[$MODULO_CODE]['categoria'])) {
        $categoria = $_SESSION[$MODULO_CODE]['categoria'];
    }
    else
        $categoria = 'all';
    
    
    $return_url = "/admin/webonline/procedure/{$categoria}/{$tipo}";
    
    
    
	// if ($operatore->superuser()) {
		$sql = "SELECT s.*, v.label0 as label_categoria, v2.label0 as path_icona
                FROM Procedures s
                LEFT JOIN MetaVoci v ON s.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
                LEFT JOIN MetaVoci v2 ON s.icona=v2.code_voce AND v2.code_tipologia='ICONE'
                WHERE (s.tipo=? OR ?='all') AND (s.categoria=? OR ?='all')
                ORDER BY s.categoria, s.label0";
	// }
	// else {
		// $sql = "SELECT p.*, v.label0 as label_categoria, v2.label0 as path_icona
				// FROM Procedures p 
				// JOIN Sys_Relazioni rel ON rel.code_figlio=p.code
				// LEFT JOIN MetaVoci v ON p.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
				// LEFT JOIN MetaVoci v2 ON p.icona=v2.code_voce AND v2.code_tipologia='ICONE'
                // WHERE (p.tipo='{$tipo}' OR '{$tipo}'='%')  AND rel.code_padre IN({$operatore->listGruppi()}) AND p.categoria='{$categoria}'
				// ORDER BY p.categoria, p.label0";
	// }
	#print_r($sql);
	$rs = $db->Execute($sql, array($tipo, $tipo, $categoria, $categoria));

	$procedure = array();

	if ($rs != FALSE) {
		$i=0;
		while (!$rs->EOF) {
			#$i = $rs->Fields("ident").$rs->Fields("categoria");
            $id = $rs->Fields("ident");
            $trovato = false;
            foreach($procedure as $item)
                if ($item["id"] == $id) {
                    $trovato = true;
                    break;
                }
            if (!$trovato) {
                $procedure[$i]["id"] = $rs->Fields("ident");
                $procedure[$i]["code"] = $rs->Fields("code");
                $procedure[$i]["tipo"] = $rs->Fields("tipo");
                $procedure[$i]["codice"] = str_replace("VM_REFBUILDING_DB", "REFBUILDING_DB", $rs->Fields("sp"));
                $procedure[$i]["path_icona"] = $rs->Fields("path_icona");
                $procedure[$i]["descrizione"] = $rs->Fields("label0");
                $procedure[$i]["categoria"] = $rs->Fields("label_categoria");
                $procedure[$i]["help"] = $rs->Fields("help_lungo0");
                $procedure[$i]["serverdb"] = $rs->Fields("serverdb");
                $procedure[$i]["pagesize"] = $rs->Fields("pagesize");
                $procedure[$i]["pageorient"] = $rs->Fields("pageorientation");
                $procedure[$i]["code_server"] = $rs->Fields("code_server");
                $procedure[$i]["funzione"] = toBool($rs->Fields("funzione"));
                $i++;
            }
			$rs->MoveNext();
		}
	}
    
    $breadcrumbs = $_SESSION[$MODULO_CODE]["breadcrumbs"];
    $breadcrumbs["current"] = 0;
    $breadcrumbs["list"][$current_item] = $procedure[0]["categoria"];
    $breadcrumbs["url"][$current_item] = $_SERVER["REQUEST_URI"];
    $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    $session->smarty()->assign("breadcrumbs", $breadcrumbs);
    $session->smarty()->assign("tipo", $tipo);

	$_SESSION[$MODULO_CODE]["procedure"] = $procedure;
	$session->smarty()->assign("procedure", $procedure);
	$session->smarty()->assign("categoria", $categoria);
    $session->smarty()->assign("return_url", $return_url);
    $session->smarty()->assign("return_url_encoded", base64_encode($return_url));
    $session->smarty()->display("admin-webonline-procedure.tpl");
	exit();
});



#
# PROCEDURA
#
$this->respond('GET', '/procedura/[:code]/?[procedura|parametri|auths:tab2]?', function ($request, $response, $service, $app) {
    GLOBAL $DBWM;
    $session = getSession();
    $MODULO_CODE = $session->get("MODULO_CODE");
    $code = $request->code;
    $db = getDB();

    
    $sql = "SELECT s.*, v.label0 as label_categoria, v2.label0 as path_icona
            FROM Procedures s
            LEFT JOIN MetaVoci v ON s.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
            LEFT JOIN MetaVoci v2 ON s.icona=v2.code_voce AND v2.code_tipologia='ICONE'
            WHERE s.code=?";
	$rs = $db->Execute($sql, array($code));

	$procedure = $rs->GetRow();

	// $session->smarty()->assign("procedura", $procedura);
    // $session->smarty()->display("admin-webonline-procedura.tpl");

    
    
    $template_code = "ProceduresS";
    $record_code = $request->code;
    $tab2 = $request->tab2;
    $tab = $request->param("tab", "procedura") ;
    $action = "update";
    $template = Template::load($template_code);
    
  
    
    
    #
    $sql = "SELECT *
            FROM {$template->dbtable()}
            WHERE code=?";
    $rs = $db->Execute($sql, array($record_code));
    $record = $rs->GetRow();
    
    $session->smarty()->assign("template_code", $template_code);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("template", $template);
    #$session->smarty()->assign("campi_record", $campi_record);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("tab", $tab);
    
    switch($tab2) {
        case "procedura":
            $session->smarty()->display("admin-webonline-procedura-procedura.tpl");
            break;
        case "parametri":
            // $sql = "SELECT 
                     // sorting 
                    // ,column_code
                    // ,dbcolumn 
                    // ,label0 
                    // ,format_code 
                    // ,flag_visible 
                    // ,note
                    // FROM RecordsetColumns
                    // WHERE recordset_code=?";
            // $rs = $db->Execute($sql, array($record_code));
            // $columns = array();
            // while(!$rs->EOF) {
                // $row = $rs->GetRow();
                // $key = strtolower($row["dbcolumn"]);
                // $columns[$key] = $row;
            // }
            // $tabulator_rscolumns = new Tabulator();
            // $tabulator_rscolumns->setSource($sql, array($record_code), "SYSCOLUMNS".$record_code);
            // #$tabulator_rscolumns->setTitle("Colonne configurate");
    
            // $source = $record["source"];
            // $sql = str_ireplace("SELECT", "SELECT TOP 1", $source);
            // $rs = $db->Execute($sql);
            // $source_colums = $rs->GetRow();
            // foreach($source_colums as $key => $item) {
                // if (isset($columns[strtolower($key)])) 
                    // unset($source_colums[$key]);
            // }
            
            // $session->smarty()->assign("tabulator_rscolumns", $tabulator_rscolumns);
            // $session->smarty()->assign("columns", $columns);
            // $session->smarty()->assign("source_colums", $source_colums);
            // $session->smarty()->display("admin-config-sysrecordsets-columns.tpl");
            break;
        case "auths":
            $session->smarty()->display("admin-config-sysrecordsets-auths.tpl");
            break;
        default:
            $session->smarty()->display("admin-webonline-procedura.tpl");
            break;
    }
});