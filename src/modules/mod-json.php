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
    
    // if ($session->checkLogin() === false) {
        // if (isset($_SESSION['SESSION']))
            // unset($_SESSION['SESSION']);
        // $session = getSession();
    // }
    $session->assertLogin($request->uri());

    $MODULO_CODE = "JSON";
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
#
#
# JSON
#
#
#

$this->respond('GET', '/rs/[a:code]', function ($request, $response, $service, $app) {
    $session = getSession();
    $code = $request->code;
    
    $records = $_SESSION["JSON"][$code]["records"];
    
    json_tabulator_recordset($code);
});

$this->respond('GET', '/sp/[a:code]', function ($request, $response, $service, $app) {
    $session = getSession();
    $code = $request->code;
    
    #$sql = $_SESSION["JSON"][$code]["sql"];
    
    json_tabulator_storedprocedure($code);
});

$this->respond('GET', '/q/[a:code]', function ($request, $response, $service, $app) {
    $session = getSession();
    $code = $request->code;
    
    $sql = $_SESSION["JSON"][$code]["sql"];
    $params = $_SESSION["JSON"][$code]["params"];
    $exclude = $_SESSION["JSON"][$code]["exclude"];
    $from = $_SESSION["JSON"][$code]["from"];
    
    // $session->log("------------------------------------------------------------");
    // $session->log($sql);
    // $session->log($params);
    // $session->log("------------------------------------------------------------");
    
    json_tabulator_query($sql, $params, $from);
});

$this->respond('GET', '/wiz/[a:code]/[i:index]', function ($request, $response, $service, $app) {
    $session = getSession();
    $code = $request->code;
    $index = $request->index;
    
    json_tabulator_wizard($code, $index);
});





#
#
#
# EXPORT
#
#
#

$this->respond('GET', '/export/[rs|q:type]/[a:token]', function ($request, $response, $service, $app) {

    $session = getSession();
    $session->log("------------------ EXPORT -----------------------------");
    $db = getDB();
    $MODULO_CODE = $session->get("MODULO_CODE");
    $token = $request->token;
    
    $sql = $_SESSION["JSON"][$token]["sql"];
    $params = $_SESSION["JSON"][$token]["params"];
    $session->log($sql);
    $session->log($params);
    $rs = $db->Execute($sql, $params);
    $data = array();
    if ($rs != FALSE) {
        #$data = $rs->GetArray();
        while (!$rs->EOF) {
            $row = $rs->GetRow();
            $r = array();
            foreach($row as $k => $v)
                $r[strtolower($k)] = $v;
            $data[] = $r;
        }
    }
    
    $session->log($data[0]);
    $_SESSION[$MODULO_CODE]["risultati"][$token] = $data;
    
    export($token);
    $session->log("-----------------------------------------------<");
});

$this->respond('GET', '/export/sp/[a:token]', function ($request, $response, $service, $app) {
    $session = getSession();
    $token = $request->token;
    export($token);
});