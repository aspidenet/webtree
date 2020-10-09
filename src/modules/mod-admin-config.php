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

    $MODULO_CODE = "ADMIN-CONFIG";
    $APP = [
        "title" => "Configurazioni di sistema",
        "url" => APP_BASE_URL."/admin/config",
        "code" => $MODULO_CODE
    ];
    $session->smarty()->assign("APP", $APP);
    $session->smarty()->assign("ADMINCONFIGPATH", ROOT_DIR.APP_BASE_URL."/admin/config");
    $session->save();
});

#
#  INDEX
#
$this->respond('GET', '/?', function ($request, $response, $service, $app) {
    $session = getSession();
    $session->redirect(APP_BASE_URL."/admin");
    exit();
});   




#
#  USERS LIST
#
$this->respond('GET', '/[users:template_code]/[list:action]', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = "USER"; #$request->template_code;
    $template = Template::load($template_code);
    $recordset_code = $template->get("recordset_code");
    
    $tabulator = new Tabulator();
    if (strlen($recordset_code) > 0) {
        $tabulator->setRecordset($recordset_code);
    }
    else {
        $sql = "SELECT * FROM {$template->dbview()}";
        $tabulator->setSource($sql, null, md5($sql));
    }

    #$tabulator->setTitle("Colonne configurate");
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("tabulator", $tabulator);
    $session->smarty()->display("admin-config-users-list.tpl");
    exit();
});

#
# USERS
#
$this->respond('GET', '/users/[new|update|read:action]/[a:record_code]/?[user|registry|groups|auths:tabpage]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = "USER"; #$request->template_code;
    $record_code = $request->record_code;
    $tabpage = $request->tabpage;
    $tab = $request->param("tab", "user") ;
    $action = $request->action;
    $template = Template::load($template_code);
    
    #
    $sql = "SELECT *
            FROM Users
            WHERE username=?";
    $rs = $db->Execute($sql, array($record_code));
    $record = $rs->GetRow();
    
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("template", $template);
    #$session->smarty()->assign("campi_record", $campi_record);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("tab", $tab);
    
    switch($tabpage) {
        case "user":
            #print_r($template);
            $session->smarty()->display("admin-config-users-user.tpl");
            break;
        case "registry":
            $sql = "SELECT *
                    FROM vw_Users
                    WHERE username=?";
            $rs = $db->Execute($sql, array($record_code));
            $registry = array();
            while(!$rs->EOF) {
                $row = $rs->GetRow();
                $key = strtolower($row["dbfield"]);
                $registry[$key] = $row;
            }
            $tabulator_rsregistry = new Tabulator();
            $tabulator_rsregistry->setSource($sql, array($record_code), "REGISTRY".$record_code);
            
            $return_url = "/admin/config/users/update/{$record_code}?tab=registry";
            
            $session->smarty()->assign("tabulator_rsregistry", $tabulator_rsregistry);
            $session->smarty()->assign("registry", $registry);
            $session->smarty()->assign("return_url", $return_url);
            $session->smarty()->assign("return_url_encoded", base64_encode($return_url));
            $session->smarty()->display("admin-config-users-registry.tpl");
            break;
        case "auths":
            $session->smarty()->display("admin-config-users-auths.tpl");
            break;
        default:
            $session->smarty()->display("admin-config-users.tpl");
            break;
    }
    exit();
});




#
#  SYSRECORDSETS LIST
#
$this->respond('GET', '/[sysrecordsets:template_code]/[list:action]', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = $request->template_code;
    $template = Template::load($template_code);
    $recordset_code = $template->get("recordset_code");
    
    $tabulator = new Tabulator();
    if (strlen($recordset_code) > 0) {
        $tabulator->setRecordset($recordset_code);
    }
    else {
        $sql = "SELECT * FROM {$template->dbview()}";
        $tabulator->setSource($sql, null, md5($sql));
    }

    #$tabulator->setTitle("Colonne configurate");
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("tabulator", $tabulator);
    $session->smarty()->display("admin-config-sysrecordsets-list.tpl");
    exit();
});


#
# SYSRECORDSETS
#
$this->respond('GET', '/[sysrecordsets:template_code]/[new|update|read:action]/[:record_code]/?[recordset|columns|auths:tab2]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = $request->template_code;
    $record_code = $request->record_code;
    $tab2 = $request->tab2;
    $tab = $request->param("tab", "recordset") ;
    $action = $request->action;
    $template = Template::load($template_code);
    
    # Campi configurati
    $sql = "SELECT dbfield
            FROM MetaFields
            WHERE template_code=?";
    $rs = $db->Execute($sql, array($template_code));
    $record_ok = array();
    while(!$rs->EOF) {
        $k = $rs->Fields("dbfield");
        $record_ok[$k] = true;
        $rs->MoveNext();
    }
    
    # Campi della tabella
    $sql = "sp_columns '{$template->dbtable()}'";
    $rs = $db->Execute($sql);
    $campi_record = array();
    while(!$rs->EOF) {
        $row = $rs->GetRow();
        if ($row["type_name"] != "int identity" && !isset($record_ok[$row["column_name"]]))
            $campi_record[] = $row;
    }
    
    #
    $sql = "SELECT *
            FROM Recordsets
            WHERE code=?";
    $rs = $db->Execute($sql, array($record_code));
    $record = $rs->GetRow();
    
    $session->smarty()->assign("template_code", $template_code);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("campi_record", $campi_record);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("tab", $tab);
    
    switch($tab2) {
        case "recordset":
            $session->smarty()->display("admin-config-sysrecordsets-recordset.tpl");
            break;
        case "columns":
            $sql = "SELECT 
                     sorting 
                    ,column_code
                    ,dbcolumn 
                    ,label0 
                    ,format_code 
                    ,flag_visible 
                    ,note
                    FROM RecordsetColumns
                    WHERE recordset_code=?";
            $rs = $db->Execute($sql, array($record_code));
            $columns = array();
            while(!$rs->EOF) {
                $row = $rs->GetRow();
                $key = strtolower($row["dbcolumn"]);
                $columns[$key] = $row;
            }
            $tabulator_rscolumns = new Tabulator();
            $tabulator_rscolumns->setSource($sql, array($record_code), "SYSCOLUMNS".$record_code);
            #$tabulator_rscolumns->setTitle("Colonne configurate");
    
            $source = $record["source"];
            $sql = str_ireplace("SELECT", "SELECT TOP 1", $source);
            $rs = $db->Execute($sql);
            // $source_colums = $rs->GetRow();
            // foreach($source_colums as $key => $item) {
                // if (isset($columns[strtolower($key)])) 
                    // unset($source_colums[$key]);
            // }
            $source_colums = $rs->Fields();
            foreach($source_colums as $key => $item) {
                if (isset($columns[$key])) 
                    unset($source_colums[$key]);
            }
            $session->smarty()->assign("tabulator_rscolumns", $tabulator_rscolumns);
            $session->smarty()->assign("columns", $columns);
            $session->smarty()->assign("source_colums", $source_colums);
            $session->smarty()->display("admin-config-sysrecordsets-columns.tpl");
            break;
        case "auths":
            $session->smarty()->display("admin-config-sysrecordsets-auths.tpl");
            break;
        default:
            $session->smarty()->display("admin-config-sysrecordsets.tpl");
            break;
    }
    exit();
});


#
# Riordino sorting
#
$this->respond('POST', '/[sysrecordsets|systemplates|sysrelations:template_code]/[update-sorting:action]/?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = $request->template_code;
    $action = $request->action;
    #$template = Template::load($template_code);
    
    $data = json_decode($request->param("data"));
    #$session->log($data);
    $s = 10;
    foreach($data as $item) {
        #$session->log($item->sorting." - ".$item->column_code);
        #$session->log($item);
        
        if ($template_code == "sysrecordsets") {
            $sql = "UPDATE RecordsetColumns SET sorting=? WHERE column_code=?";
            $db->Execute($sql, array($s, $item->column_code));
        }
        elseif ($template_code == "systemplates") {
            $sql = "UPDATE MetaFields SET sorting=? WHERE field_code=?";
            $db->Execute($sql, array($s, $item->field_code));
        }
        elseif ($template_code == "sysrelations") {
            $sql = "UPDATE MetaRelations SET sorting=? WHERE relation_code=?";
            $db->Execute($sql, array($s, $item->relation_code));
        }
        $s += 10;
    }
    #$session->log($data);
    echo "OK";
    exit();
});


#
# TEMPLATES LIST
#
$this->respond('GET', '/systemplates/[list:action]', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $sql = "SELECT *
            FROM MetaTemplates";
    $rs = $db->Execute($sql);
    $record = $rs->GetRow();
    
    $tabulator_rscolumns = new Tabulator();
    $tabulator_rscolumns->setSource($sql, null, "SYSTEMPLATESLIST");
    #$tabulator_rscolumns->setTitle("Colonne configurate");

    #$session->smarty()->assign("template", $template);
    $session->smarty()->assign("tabulator_rscolumns", $tabulator_rscolumns);

    $session->smarty()->display("admin-config-templates-list.tpl");
    exit();
});



#
# TEMPLATES
#
$this->respond('GET', '/systemplates/[new|update|read:action]/[a:record_code]/?[template|fields|relations|auths:tabpage]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = "SYSTEMPLATE"; #$request->template_code;
    $record_code = $request->record_code;
    $tabpage = $request->tabpage;
    $tab = $request->param("tab", "template") ;
    $action = $request->action;
    $template = Template::load($template_code);
    
    # Campi configurati
    /*$sql = "SELECT dbfield
            FROM MetaFields
            WHERE template_code=?";
    $rs = $db->Execute($sql, array($template_code));
    $record_ok = array();
    while(!$rs->EOF) {
        $k = $rs->Fields("dbfield");
        $record_ok[$k] = true;
        $rs->MoveNext();
    }
    
    # Campi della tabella
    $sql = "sp_columns '{$template->dbtable()}'";
    $rs = $db->Execute($sql);
    $campi_record = array();
    while(!$rs->EOF) {
        $row = $rs->GetRow();
        if ($row["type_name"] != "int identity" && !isset($record_ok[$row["column_name"]]))
            $campi_record[] = $row;
    }*/
    
    #
    $sql = "SELECT *
            FROM MetaTemplates
            WHERE template_code=?";
    $rs = $db->Execute($sql, array($record_code));
    $record = $rs->GetRow();
    
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("template", $template);
    #$session->smarty()->assign("campi_record", $campi_record);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("tab", $tab);
    
    switch($tabpage) {
        case "template":
            #print_r($template);
            $session->smarty()->display("admin-config-templates-template.tpl");
            break;
        case "fields":
            $sql = "SELECT 
                     sorting 
                    ,field_code
                    ,dbfield
                    ,label0 
                    ,format_code 
                    ,list_code
                    ,classtype_code
                    ,help0
                    ,note
                    FROM MetaFields
                    WHERE template_code=?";
            $rs = $db->Execute($sql, array($record_code));
            $columns = array();
            while(!$rs->EOF) {
                $row = $rs->GetRow();
                $key = strtolower($row["dbfield"]);
                $columns[$key] = $row;
            }
            $tabulator_rscolumns = new Tabulator();
            $tabulator_rscolumns->setSource($sql, array($record_code), "SYSFIELDS".$record_code);
            #$tabulator_rscolumns->setTitle("Colonne configurate");
    
            // $source = "SELECT * FROM ".$record["dbtable"];
            // $sql = str_ireplace("SELECT", "SELECT TOP 1", $source);
            // $session->log("SQL: ".$sql);
            // $rs = $db->Execute($sql);
            // $source_colums = $rs->GetRow();
            // foreach($source_colums as $key => $item) {
                // if (isset($columns[strtolower($key)])) 
                    // unset($source_colums[$key]);
            // }
            
            $dbtable = $record["dbtable"];
            $dbsource = "";
            $e = explode(".", $dbtable);
            if (count($e) == 3) {
                $dbtable = $e[2];
                $dbsource = $e[0].".";
            }
            
            $sql = "select *
                    from {$dbsource}information_schema.columns
                    where table_name=?
                    order by table_name, ordinal_position";
            $rs = $db->Execute($sql, array($dbtable));
            $source_colums_array = $rs->GetArray();
            #$session->log($source_colums_array);
            foreach($source_colums_array as $item) {
                $key = $item["column_name"];
                if (isset($columns[strtolower($key)])) 
                    unset($source_colums[$key]);
                else
                    $source_colums[$key] = $item;
            }

            
            $return_url = "/admin/config/systemplates/update/{$record_code}?tab=fields";
            
            $session->smarty()->assign("tabulator_rscolumns", $tabulator_rscolumns);
            $session->smarty()->assign("columns", $columns);
            $session->smarty()->assign("source_colums", $source_colums);
            $session->smarty()->assign("return_url", $return_url);
            $session->smarty()->assign("return_url_encoded", base64_encode($return_url));
            $session->smarty()->display("admin-config-templates-fields.tpl");
            break;
        case "relations":
            $sql = "SELECT 
                     sorting 
                    ,slave_code
                    ,label0 
                    ,dbtable 
                    ,cardinality_min
                    ,cardinality_max
                    ,note
                    ,relation_code
                    FROM MetaRelations
                    WHERE master_code=?";
            $rs = $db->Execute($sql, array($record_code));
            $relations = array();
            while(!$rs->EOF) {
                $row = $rs->GetRow();
                $key = strtolower($row["dbfield"]);
                $relations[$key] = $row;
            }
            $tabulator_rsrelations = new Tabulator();
            $tabulator_rsrelations->setSource($sql, array($record_code), "SYSFIELDS".$record_code);
            
            $return_url = "/admin/config/systemplates/update/{$record_code}?tab=relations";
            
            $session->smarty()->assign("tabulator_rsrelations", $tabulator_rsrelations);
            $session->smarty()->assign("relations", $relations);
            $session->smarty()->assign("return_url", $return_url);
            $session->smarty()->assign("return_url_encoded", base64_encode($return_url));
            $session->smarty()->display("admin-config-templates-relations.tpl");
            break;
        case "auths":
            $session->smarty()->display("admin-config-templates-auths.tpl");
            break;
        default:
            $session->smarty()->display("admin-config-templates.tpl");
            break;
    }
    
    exit();
});






#
# PROCEDURES LIST
#
$this->respond('GET', '/procedures/[list:action]', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $sql = "SELECT *
            FROM Procedures";
    $rs = $db->Execute($sql);
    $record = $rs->GetRow();
    
    $tabulator = new Tabulator();
    #$tabulator->setSource($sql, null, "METAPROCEDURESLIST");
    $tabulator->setRecordset("METAPROCEDURE");
    #$tabulator->setTitle("Colonne configurate");

    #$session->smarty()->assign("template", $template);
    $session->smarty()->assign("tabulator_procedures", $tabulator);

    $session->smarty()->display("admin-config-procedures-list.tpl");
    exit();
});



#
# PROCEDURES
#
$this->respond('GET', '/[procedures|metaprocedures:template]/[new|update|read:action]/[a:record_code]/?[procedure|params:tabpage]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = "METAPROCEDURES"; #$request->template_code;
    $record_code = $request->record_code;
    $tabpage = $request->tabpage;
    $tab = $request->param("tab", "procedure") ;
    $action = $request->action;
    $template = Template::load($template_code);
    
    #
    $sql = "SELECT *
            FROM Procedures
            WHERE code=?";
    $rs = $db->Execute($sql, array($record_code));
    $record = $rs->GetRow();
    
    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("template", $template);
    #$session->smarty()->assign("campi_record", $campi_record);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("tab", $tab);
    
    switch($tabpage) {
        case "procedure":
            #print_r($template);
            $session->smarty()->display("admin-config-procedures-procedure.tpl");
            break;
        case "params":
            
            $tabulator = new Tabulator();
            $tabulator->setRecordset("METAPARAMS", "AND code_procedure=?", array($record_code));
            #$tabulator_rscolumns->setTitle("Colonne configurate");

            $return_url = "/admin/config/procedures/update/{$record_code}?tab=params";
            
            $session->smarty()->assign("tabulator_params", $tabulator);
            $session->smarty()->assign("return_url", $return_url);
            $session->smarty()->assign("return_url_encoded", base64_encode($return_url));
            $session->smarty()->display("admin-config-procedures-params.tpl");
            break;
        case "auths":
            $session->smarty()->display("admin-config-procedures-auths.tpl");
            break;
        default:
            $session->smarty()->display("admin-config-procedures.tpl");
            break;
    }
    exit();
});














#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************



#
#  TEMPLATE GENERICO LIST
#
$this->respond('GET', '/[:template_code]/[list:action]', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = $request->template_code;
    $template = Template::load($template_code);
    $recordset_code = $template->get("recordset_code");
    
    $tabulator = new Tabulator();
    if (strlen($recordset_code) > 0) {
        $tabulator->setRecordset($recordset_code);
    }
    else {
        $sql = "SELECT * FROM {$template->dbview()}";
        $tabulator->setSource($sql, null, md5($sql));
    }

    #$tabulator->setTitle("Colonne configurate");
    $session->smarty()->assign("current_id", microtime());
    $session->smarty()->assign("template", $template);
    $session->smarty()->assign("tabulator", $tabulator);
    $session->smarty()->display("admin-config-generic-list.tpl");
});



#
# TEMPLATE GENERICO 
#
$this->respond('GET', '/[:template_code]/[new|update|read:action]/[:record_code]/[:tabpage]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    
    $template_code = $request->template_code;
    $record_code = $request->record_code;
    $tabpage = $request->tabpage;
    $tab = $request->param("tab", "template") ;
    $action = $request->action;
    $template = Template::load($template_code);
    
    #
    $sql = "SELECT *
            FROM {$template->dbview()}
            WHERE {$template->dbkey()}=?";
    $rs = $db->Execute($sql, array($record_code));
    if ($rs == false || $rs->RecordCount() == 0) {
        $session->smarty()->display("404.tpl");
        exit();
        
    }
    $record = $rs->GetRow();
    
    

    $session->smarty()->assign("record_code", $record_code);
    $session->smarty()->assign("action", $action);
    $session->smarty()->assign("template", $template);
    #$session->smarty()->assign("campi_record", $campi_record);
    $session->smarty()->assign("record", $record);
    $session->smarty()->assign("tab", $tab);
    
    switch($tabpage) {
        case "":
            $relations = $template->relations();
            $session->smarty()->assign("relations", $relations);
            $session->smarty()->display("admin-config-generic-update.tpl");
            break;
            
        case "template":
            #print_r($template);
            $session->smarty()->display("admin-config-generic-template.tpl");
            break;

        case "auths":
            $session->smarty()->display("admin-config-templates-auths.tpl");
            break;
            
        default:
        
            $relation = new Relation($tabpage);
            $recordset_code = $relation->get("recordset_code");
        
            $tabulator = new Tabulator();
            
            if (strlen($recordset_code) > 0) {
                
                $tabulator->setRecordset($recordset_code, "AND {$relation->dbfieldMaster()}=?", array($record_code));
                
            }
            else {
                $sql = "SELECT * FROM {$relation->dbview()} WHERE {$relation->dbfieldMaster()}=?";
                $tabulator->setSource($sql, array($record_code), "RELATION".$record_code.md5(microtime()));
            }
            
            $tabulator_name = "tab".md5(microtime());
            // $rs = $db->Execute($sql, array($record_code));
            // $columns = array();
            // while(!$rs->EOF) {
                // $row = $rs->GetRow();
                // $key = strtolower($row["dbcolumn"]);
                // $columns[$key] = $row;
            // }
            
            // 
            // #$tabulator->setTitle("Colonne configurate");
    
            $session->smarty()->assign("relation", $relation);
            $session->smarty()->assign("tabulator", $tabulator);
            $session->smarty()->assign("tabulator_name", $tabulator_name);
            
            $session->smarty()->display("admin-config-generic-relations.tpl");
            break;
    }
    
    exit();
});