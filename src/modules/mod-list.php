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
});


#
# INDEX
#
$this->respond('GET', '/?', function ($request, $response, $service, $app) {
    $session = getSession();

});

#
# UTENTI
#
/*
$this->respond('GET', '/[:wizard]/[a:code]?', function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    #$action = $request->action;
    $wizard_code = $request->wizard;
    $code = $request->code;
    $tabulator = new Tabulator();
    
    // $wizard = Wizard::load($wizard_code);
    // $wizard->save();
    
    // $session->smarty()->assign("wizard_code", $wizard_code);
        
    if (isset($_SESSION['WIZARDS']))
        unset($_SESSION['WIZARDS']);
    #$sql = "SELECT TOP 1 * FROM {$wizard->dbview()}";
    #$sql = "SELECT * FROM webmonitormodulitest.dbo.SIM2_SIM WHERE 1=1";
    // $rs = $db->Execute($sql);
    // $records = $rs->GetArray();
    
    
    // $sql = "SELECT * FROM webmonitormodulitest.dbo.SIM2_SIM WHERE 1=1";
    // $_SESSION["JSON"][$code]["sql"] = $sql;
    
    // $tabulator->setColumns($records[0]);
    // #$tabulator->setAjaxUrl(APP_BASE_URL."/list/json/wizard-{$wizard_code}");
    // $tabulator->setDataIndex($code);
    #$tabulator->setSource($sql, $code);
    $tabulator->setRecordset($code);
    $tabulator->setTitle("Elenco SIM");
    
    $session->smarty()->assign("tabulator", $tabulator);
    #$session->smarty()->assign("record", $records[0]);
    $session->smarty()->display("list-elenco.tpl");
    exit();
});
*/





#
#
#
# JSON
#
#
#

$this->respond('GET', '/json/wizard-[a:wizard]', function ($request, $response, $service, $app) {
    $session = getSession();
    $wizard_code = $request->wizard;
    $wizard = Wizard::load($wizard_code);
    $sql = "SELECT * FROM {$wizard->dbview()} WHERE 1=1";
    $sql = "SELECT * FROM webmonitormodulitest.dbo.SIM2_SIM WHERE 1=1";

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













#
#
#
# TABULATOR
#
#
#

$this->respond('GET', '/tabulator/[a:token]', function ($request, $response, $service, $app) {
    $session = getSession();
    $token = $request->token;
    
    $session->log("TABULATOR ({$token})");
    /*
    $_SESSION["CACHE"]["TABULATOR"][$token] = array(
            "type" => "query",
            "sql" => $sql,
            "params" => array($code),
            "recordset_code" => $recordset_code,
            "json_code" => "NAVCDCPERSLOC",
            "exlude_columns" => array(),
            "from" => "from"
        );
    */
    $tab_data = $_SESSION["CACHE"]["TABULATOR"][$token];
    $tabulator = new Tabulator();
    $session->log("TABULATOR CONTAINER EXECUTE ({$token})");
        
    switch($tab_data["type"]) {
        case "query":
            $session->log("/tabulator/{$token} -> imposto la sorgente");
            $tabulator->setSource($tab_data["sql"], $tab_data["params"], $tab_data["json_code"], $tab_data["exlude_columns"], $tab_data["recordset_code"], $tab_data["from"]);
            break;
            
        case "storedprocedure":
        
            break;
            
        case "recordset":
        
            break;
            
            
        
    }
    $session->log("TABULATOR CONTAINER DISPLAY");
    
    $session->smarty()->assign("tabulator", $tabulator);
    $session->smarty()->assign("token", $token);
    $session->smarty()->display('container.tabulator.tpl');
    
    $session->log("TABULATOR CONTAINER DISPLAY FINE ======================================================");
});