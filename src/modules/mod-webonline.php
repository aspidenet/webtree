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

    $MODULO_CODE = "WEBONLINE";
    #$applicazione->setModulo($MODULO_CODE);
    $APP = [
        "title" => "Web Online",
        "url" => APP_BASE_URL."/webonline",
        "code" => $MODULO_CODE
    ];

    if (!isset($_SESSION[$MODULO_CODE]["breadcrumbs"])) {
        $breadcrumbs = array(
            "current" => -1,
            "list" => []
        );
        $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    }

    $session->smarty()->assign("APP", $APP);
    $session->set("MODULO_CODE", $MODULO_CODE, true);
    $session->save();
});





#
# INDEX / CATEGORIE
#
/*$this->respond('GET', '/?', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    GLOBAL $DBWM;
    
    header("Location:/webonline/procedure/all/all");
    exit();
    
    $session = getSession();
    $session->log("Webonline home");
    $MODULO_CODE = $session->get("MODULO_CODE");
    $tipo = "all";
    $db = getDB();
    unset($_SESSION[$MODULO_CODE]["breadcrumbs"]);
    
    $sql = "SELECT DISTINCT p.categoria as code, v.label0 as categoria
            FROM Procedures p
            LEFT JOIN MetaClassNodes v ON p.categoria=v.node_code AND v.classtype_code='WOLCATEG'
            WHERE (p.tipo=? OR ?='all') 
            ORDER BY v.sorting, v.label0";
	$rs = $db->Execute($sql, array($tipo, $tipo));

    $categorie = array();

    if ($rs != FALSE) {
        $categorie = $rs->GetArray();
    }
    $session->smarty()->assign("categorie", $categorie);
    $session->smarty()->assign("tipo", $tipo);
    $session->smarty()->display("webonline-index.tpl");
    exit();
});*/
$this->respond('GET', '/?[all|X|S|D|M:tipo]?', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    $session = getSession();
    $session->log("Webonline home");
    $MODULO_CODE = $session->get("MODULO_CODE");
    #$tipo = "all";
    $tipo = $request->param("tipo", "all");
    $db = getDB();
    unset($_SESSION[$MODULO_CODE]["breadcrumbs"]);
    
    $sql = "SELECT DISTINCT p.categoria as code, v.label0 as categoria, v.sorting, v.icon
            FROM Procedures p
            LEFT JOIN MetaClassNodes v ON p.categoria=v.node_code AND v.classtype_code='WOLCATEG'
            JOIN RelProfileProcedure pp ON pp.procedure_code=p.code
            JOIN RelUserProfile up ON up.profile_code=pp.profile_code AND up.user_code=?
            WHERE (p.tipo=? OR ?='all') 
            ORDER BY v.sorting, v.label0";
	$rs = $db->Execute($sql, array($session->user()->username(), $tipo, $tipo));

    $categorie = array();

    if ($rs != FALSE) {
        $categorie = $rs->GetArray();
    }
    $categorie[] = array(
        "code" => "all",
        "categoria" => "Tutte le categorie",
        "icon" => "asterisk"   # star
    );
    $session->smarty()->assign("categorie", $categorie);
    $session->smarty()->assign("tipo", $tipo);
    $session->smarty()->display("webonline-categorie.tpl");
    exit();
});

/*
$this->respond('GET', '/tipo-[a:tipo]?', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    $session = getSession();
    $session->log("Webonline home");
    $MODULO_CODE = $session->get("MODULO_CODE");
    $tipo = $request->tipo;
    $db = getDB();
    unset($_SESSION[$MODULO_CODE]["breadcrumbs"]);
    
    if (strlen($tipo) > 0) {
        $_SESSION[$MODULO_CODE]['tipo'] = $tipo;
    }
    elseif (isset($_SESSION[$MODULO_CODE]['tipo'])) {
        $tipo = $_SESSION[$MODULO_CODE]['tipo'];
    }
    else
        $tipo = 'all';
    
    // if ($operatore->amministratore()) {
        $sql = "SELECT DISTINCT p.categoria as code, v.label0 as categoria
                FROM dbo.Procedures p
                LEFT JOIN MetaVoci v ON p.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
                WHERE (p.tipo='{$tipo}' OR '{$tipo}'='all')
                ORDER BY categoria";
    // }
    // elseif ($operatore->superuser()) {
        // error_log("SUPERUSER");
        // $sql = "SELECT DISTINCT p.categoria as code, v.label0 as categoria
                // FROM dbo.Procedures p
                // LEFT JOIN MetaVoci v ON p.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
                // WHERE (p.tipo='{$tipo}' OR '{$tipo}'='%')
                // ORDER BY categoria";
    // }
    // else {
        // $sql = "SELECT DISTINCT p.categoria as code, v.label0 as categoria
                // FROM Procedures p 
                // JOIN SYS_Relazioni rel ON rel.code_figlio=p.code
                // JOIN MetaVoci v ON p.categoria=v.code_voce AND v.code_tipologia='PROCEDURE-CATEGORIE'
                // WHERE (p.tipo='{$tipo}' OR '{$tipo}'='%')
                // AND rel.code_padre IN({$operatore->listGruppi()})
                // ORDER BY categoria";
    // }
    #print_r($sql);
    $rs = $db->Execute($sql);

    $categorie = array();

    if ($rs != FALSE) {
        $categorie = $rs->GetArray();
    }
    $session->smarty()->assign("categorie", $categorie);
    $session->smarty()->assign("tipo", $tipo);
    $session->smarty()->display("webonline-categorie.tpl");
    exit();
});
*/

#
# PROCEDURE
#
$this->respond('GET', '/procedure/[:categoria]/?[a:tipo]?', function ($request, $response, $service, $app) {
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
    
    $sql = "SELECT s.*, v.label0 as label_categoria, v.icon
            FROM Procedures s
            LEFT JOIN MetaClassNodes v ON s.categoria=v.node_code AND v.classtype_code='WOLCATEG'
            JOIN RelProfileProcedure pp ON pp.procedure_code=s.code
            JOIN RelUserProfile up ON up.profile_code=pp.profile_code AND up.user_code=?
            WHERE (s.tipo=? OR ?='all') AND (s.categoria=? OR ?='all')
            ORDER BY v.sorting, s.label0";
	$rs = $db->Execute($sql, array($session->user()->username(), $tipo, $tipo, $categoria, $categoria));

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
                $procedure[$i]["codice"] = replace_dynamic_filters(str_replace("VM_REFBUILDING_DB", "REFBUILDING_DB", $rs->Fields("sp")));
                $procedure[$i]["path_icona"] = $rs->Fields("icon");
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
    $breadcrumbs["list"][$current_item] = ($categoria == 'all') ? "Tutte le categorie" : $procedure[0]["categoria"];
    $breadcrumbs["url"][$current_item] = $_SERVER["REQUEST_URI"];
    $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    $session->smarty()->assign("breadcrumbs", $breadcrumbs);
    $session->smarty()->assign("tipo", $tipo);

	$_SESSION[$MODULO_CODE]["procedure"] = $procedure;
	$session->smarty()->assign("procedure", $procedure);
	$session->smarty()->assign("categoria", $categoria);
	$session->smarty()->assign("show_indietro", false);
    $session->smarty()->display("webonline-procedure.tpl");
	exit();
});




#
# PROCEDURA - selezione parametri
#
$this->respond('GET', '/procedura/[i:numero]', function ($request, $response, $service, $app) {
    GLOBAL $DBWM;
    $session = getSession();
    $MODULO_CODE = $session->get("MODULO_CODE");
    $pnum = $request->numero;
    $db = getDB();
    
    if (!isset($_SESSION[$MODULO_CODE]["procedure"][$pnum])) {
        $session->redirect(APP_BASE_URL."/webonline");
        exit();
    }
    
	$_SESSION[$MODULO_CODE]["pnum"] = $pnum;
	$procedura = $_SESSION[$MODULO_CODE]["procedure"][$pnum];

	$sql = "SELECT *
            FROM Params
            WHERE code_procedure=?
            ORDER BY sorting";
	$rs = $db->Execute($sql, array($procedura["code"])) OR die($sql.$db->ErrorMsg());
  	
	$parametri = array();
    $ok_esegui = true;
    
    
	if ($rs != FALSE) {
        $i=0;
        while (!$rs->EOF) {
            $row = $rs->GetRow();
            $row["default_value"] = replace_dynamic_filters($row["default_value"]);
            $parametri[$i] = $row;
            
            
            if (strlen($parametri[$i]["code_list"]) > 0) {
                // $tip = Factory::crea("MetaTipologia", $parametri[$i]["code_list"], false);
                // $tip->loadVoci();
                // if ($parametri[$i]["mostratutti"])
                    // $parametri[$i]["select"]['%'] = "Tutti";
                // foreach($tip->arrayVoci() as $k => $v)
                    // $parametri[$i]["select"][$k] = $v;
                // $parametri[$i]["select_count"] = count($parametri[$i]["select"]);
            }
            elseif (strlen($row["source_code"]) > 1) {
                # Procedura
                # Vista/Tabella
                if ($row["source_code"] != 'C')
                    $sql = replace_dynamic_filters($row["source_code"]);
                # Classificazione
                else
                    $sql = $row["source_code"]; # TODO
                
                error_log("SQL: ".$sql);
                $rs_rif = $db->Execute($sql);
                if ($rs_rif == false) {
                    throw new Exception("Impossibile ottenere i valori dei parametri.");
                }

                $parametri[$i]["select"] = array();

                if ($rs_rif != FALSE) {
                    if (toBool($parametri[$i]["fl_showall"]))
                        $parametri[$i]["select"]['%'] = "Tutti";
                    while (!$rs_rif->EOF) {
                        $cod = $rs_rif->Fields($row["result_value"]);
                        $desc = $rs_rif->Fields($row["result_label"]);
                        $parametri[$i]["select"][$cod]["code"] = $cod;
                        if (toBool($row["fl_showvalues"]) == FALSE)
                            $parametri[$i]["select"][$cod]["label"] = $desc;
                        else
                            $parametri[$i]["select"][$cod]["label"] = $cod . ' - ' . $desc;
                        
                        if (toBool($row["fl_group"])) {
                            $parametri[$i]["select"][$cod]["group_code"] = $rs_rif->Fields($row["group_value"]);
                            $parametri[$i]["select"][$cod]["group_label"] = $rs_rif->Fields($row["group_label"]);
                        }
                        $rs_rif->MoveNext();
                    }
                    if (count($parametri[$i]["select"]) == 0) {
                        $ok_esegui = false;
                    }
                    $parametri[$i]["select_count"] = count($parametri[$i]["select"]);
                }
            }
            else {
                $parametri[$i]["select"] = false;
                $parametri[$i]["select_count"] = -1;
            }

            $i++;
        } // fine while.

            $breadcrumbs = $_SESSION[$MODULO_CODE]["breadcrumbs"];
            $current_item = $breadcrumbs["current"];
            $current_item++;
            $breadcrumbs["current"] = 1;
            $breadcrumbs["list"][$current_item] = $procedura["descrizione"];
            $breadcrumbs["url"][$current_item] = $_SERVER["REQUEST_URI"];
            $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs; 
            $session->smarty()->assign("breadcrumbs", $breadcrumbs);

          $_SESSION[$MODULO_CODE]["parametri"] = $parametri;

          $session->smarty()->assign("numero_parametri", count($parametri));
          $session->smarty()->assign("procedura", $procedura);
          $session->smarty()->assign("parametri", $parametri);
          $session->smarty()->assign("ok_esegui", $ok_esegui);
          $session->smarty()->assign("pnum", $pnum);
        #} 
        #else
        #  $fase = 2;
    }// fine if.
    else {
        throw new Exception("Impossibile leggere i parametri della procedura.");
    
	}

    $session->smarty()->display("webonline-procedura.tpl");
	exit();
});





#
# PROCEDURA - invio parametri ed esecuzione
#
$this->respond('POST', '/procedura/[i:numero]', function ($request, $response, $service, $app) {
    $session = getSession();
    $MODULO_CODE = $session->get("MODULO_CODE");
    $pnum = $request->numero;
    $db = getDB();
    
	$procedura = $_SESSION[$MODULO_CODE]["procedure"][$pnum];
	$parametri = $_SESSION[$MODULO_CODE]["parametri"];
    $numero_parametri = count($parametri);
    $record_per_pagina = 100;
    
    #-----------------------------------------------------------------------------
	# RECORDSET A VIDEO
	#-----------------------------------------------------------------------------
    if ($procedura["funzione"])
        $strSQL = "SELECT * FROM ".$procedura["codice"]."(";
    else
        $strSQL = $procedura["codice"]."  ";
        
	for ($i=0; $i<$numero_parametri; $i++) {
		$input = get("param".$i);
        if (is_array($input))
            $input = implode(",", $input);
		$tipo = get("param{$i}_tipo"); #$parametri[$i]["tipo"]
        
        if (toBool($parametri[$i]["fl_null"]))
            $ok_null = true;
        else
            $ok_null = false;
            
        switch($tipo) {
            case "integer":
            case "decimal":
                $strSQL .= write_number($input, $ok_null). ", ";
                break;

            case "char":
            case "string":
            case "datetime":
            default:
                $strSQL .= quote_string($input, $ok_null). ", ";
                break;
        }
	}
	$strSQL = substr($strSQL, 0, -2);
    if ($procedura["funzione"])
        $strSQL .= ")";
        
    //echo $strSQL;
    error_log("******************************************************");
    error_log($strSQL);
    error_log("******************************************************");
    $rs = $db->Execute($strSQL);

    #xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    $elenco = array();
    if ($rs != FALSE) {
        $elenco = $rs->GetArray();
    }
    else
        error_log("query fallita");
    error_log("COUNT: ".$rs->RecordCount());
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
                    $tipi_campi[$nomecampo] = "integer";
                    break;
                    
                case "real":
                case "decimal":
                case "numeric":
                    $tipi_campi[$nomecampo] = "number";
                    break;
                    
                case "money":
                    $tipi_campi[$nomecampo] = "money";
                    break;

                case "timestamptz":
                case "datetime":
                case "datetime2":
                    $tipi_campi[$nomecampo] = "datetime";
                    break;

                case "char":
                case "varchar":
                case "nvarchar":
                    $tipi_campi[$nomecampo] = "string";
                    break;

                default:
                    $tipi_campi[$nomecampo] = $field->type;
                    break;
        }
        $session->log($field->type." -> ".$nomecampo."=".$tipi_campi[$nomecampo]);
    }
    #-----------------------------------------------------------------------------
    $token = md5($procedura["codice"]);
    #$session->log($token);
    $_SESSION[$MODULO_CODE]["tipi_campi"] = $tipi_campi;
    $_SESSION[$MODULO_CODE]["risultati"][$token] = $elenco;
    #$session->log($tipi_campi);
    
    ###################################################################
    # ASSEGNAZIONI
    ###################################################################
    #$ignora_history = true;
    #require_once("include/common_footer.inc");
    #$session->smarty()->assign("records", $elenco);
    if (count($elenco))
        $session->smarty()->assign("record", $elenco[0]);
    else
        $session->smarty()->assign("record", array());
    $session->smarty()->assign("token", $token);
    $session->smarty()->assign("tipi_campi", $tipi_campi);

    $session->smarty()->display("webonline-risultati.tpl");
    exit();
});




#
# API
#
$this->respond('GET', '/api/?', function ($request, $response, $service, $app) {
    $session = getSession();
    $session->log("/api");
    $db = getDB();
    $MODULO_CODE = $session->get("MODULO_CODE");
    
    // Get the URL's query param string
    $parsed_uri = parse_url( $request->uri() );
    $session->log($parsed_uri);

    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 1000);
    $offset = ($page-1) * $size;
    $token = get("token");
    
    
    $data = $_SESSION[$MODULO_CODE]["risultati"][$token];
    $_SESSION[$MODULO_CODE]["filtri"][$token] = $filters;
    
    $session->log("token: ".$token);
    $session->log("page: ".$page);
    $session->log("size: ".$size);
    $session->log("last: ".ceil(count($data) / $size));
    $session->log("filters: ");
    $session->log($filters);
    $session->log("sorters: ");
    $session->log($sorters);

    # sorters (attenzione che i sorters salvano i risultati nel nuovo ordine!)
    if (count($sorters)) {
        
        $orderby = $sorters[0]["field"];
        $dir = $sorters[0]["dir"];
        
        $sortArray = array();

        foreach($data as $rows) {
            foreach($rows as $key=>$value) {
                if(!isset($sortArray[$key])) {
                    $sortArray[$key] = array();
                }
                $sortArray[$key][] = $value;
            }
        }
        if ($dir == "asc")
            array_multisort($sortArray[$orderby], SORT_ASC, $data); 
        else
            array_multisort($sortArray[$orderby], SORT_DESC, $data); 
        $_SESSION[$MODULO_CODE]["risultati"][$token] = $data;
    }
    
    # filters
    if (count($filters)) {
    
        $filtro = $filters[0];
        
        $field = $filtro["field"];
        $type = $filtro["type"];
        $value = $filtro["value"];
        

        // $data = array_filter($data, function ($var) use ($filtro) {
            // $field = $filtro["field"];
            // $type = $filtro["type"];
            // $value = $filtro["value"];
            // switch($type) {
                // case "like":
                    // return stripos($var[$field], $value) !== false;
                    // break;
                    
                // case "equal":
                    // return ($var[$field] == $value);
                    // break;
                    
                // default:
                    // return true;
                    // break;
            // }
            // return true;
        // });
        $data = array_filter($data, function ($var) use ($filters) {
            $res = true;
            foreach($filters as $filtro) {
                $field = $filtro["field"];
                $type = $filtro["type"];
                $value = $filtro["value"];
                
                switch($type) {
                    case "like":
                        $res &= stripos($var[$field], $value) !== false;
                        break;
                        
                    case "equal":
                        $res &= ($var[$field] == $value);
                        break;
                        
                    default:
                        $res &= true;
                        break;
                }
            }
            return $res;
        });
        
    }

    $result = [
        "last_page" => ceil(count($data) / $size),
        "data" => array_slice($data, $offset, $size, false)
    ];
    //return JSON formatted data
    echo(json_encode($result)); 
    exit();
});



#
# EXPORT
#
$this->respond('GET', '/export/[xlsx|pdf|json:format]/?', function ($request, $response, $service, $app) {
    $session = getSession();
    $format = $request->format;
    $session->log("/export/".$format);
    $db = getDB();
    $MODULO_CODE = $session->get("MODULO_CODE");
    $session->log("MODULO_CODE: ".$MODULO_CODE);
    
    
    // Get the URL's query param string
    $parsed_uri = parse_url( $request->uri() );
    $session->log($parsed_uri);

    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 1000);
    $offset = ($page-1) * $size;
    $token = get("token");
    
    export($token, $format, $page, $size);
    /*
    $data = $_SESSION[$MODULO_CODE]["risultati"][$token];
    $filters = $_SESSION[$MODULO_CODE]["filtri"][$token];
    
    # filters
    if (count($filters)) {
    
        $data = array_filter($data, function ($var) use ($filters, $session) {
            $res = true;
            foreach($filters as $filtro) {
                $field = $filtro["field"];
                $type = $filtro["type"];
                $value = $filtro["value"];
                
                switch($type) {
                    case "like":
                        $res &= stripos($var[$field], $value) !== false;
                        break;
                        
                    case "equal":
                        $res &= ($var[$field] == $value);
                        break;
                        
                    default:
                        $res &= true;
                        break;
                }
            }
            return $res;
        });
        
    }
    
    if ($format == "json") {
        $result = [
            "last_page" => ceil(count($data) / $size),
            "data" => array_slice($data, $offset, $size, false)
        ];
        //return JSON formatted data
        echo(json_encode($result)); 
    }
    elseif($format == "xlsx") {
        
        
        
        // use PhpOffice\PhpSpreadsheet\Spreadsheet;
        // use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
         
         
        $spreadsheet = new PhpOffice\PhpSpreadsheet\Spreadsheet();
        // Set properties
        $spreadsheet->getProperties()
            ->setCreator("WebTree")
            ->setLastModifiedBy("WebTree")
            ->setTitle("")
            ->setSubject("")
            ->setDescription("")
            ->setKeywords("")
            ->setCategory("");
            
        $sheet = $spreadsheet->getActiveSheet();
        
        //----------------------------------------------------------------------------
        // Record:
        // Per ogni riga:
        $row_index = 1;
        $first = true;
        foreach($data as $row) {
            if ($first) {
                //----------------------------------------------------------------------------
                // Nomi dei campi:
                $nomi_colonne = array_keys($row);
                $numfields = count($nomi_colonne);
                for ($f = 0; $f < $numfields; $f++) {
                    $sheet->setCellValueByColumnAndRow($f+1, 1, $nomi_colonne[$f]);
                }
                $first = false;
                $row_index++;
            }
            for ($i=0; $i < $numfields; $i++) {
                $valore = trim($row[$nomi_colonne[$i]]);
                $sheet->setCellValueByColumnAndRow($i+1, $row_index, $valore);
            }
            $row_index++;
        }
        
        $spreadsheet->setActiveSheetIndex(0);
        
        ob_clean();
        
        // Redirect output to a client’s web browser (Xlsx)
        header("Cache-Control: max-age=0, no-cache, must-revalidate, proxy-revalidate");
        // If you're serving to IE 9, then the following may be needed
        header('Cache-Control: max-age=1');
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="webonline.xlsx"');
        header("Content-Transfer-Encoding: binary");
        
         // If you're serving to IE over SSL, then the following may be needed
        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
        header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT'); // always modified
        header('Pragma: public'); // HTTP/1.0
        
        $writer = PhpOffice\PhpSpreadsheet\IOFactory::createWriter($spreadsheet, 'Xlsx');
        $writer->save("php://output");
    }*/
    exit();
});
