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

    $MODULO_CODE = "WEBONLINE-CONFIG";
    #$applicazione->setModulo($MODULO_CODE);
    $APP = [
        "title" => "WebOnline Configurazione",
        "url" => APP_BASE_URL."/webonline-config",
        "code" => $MODULO_CODE
    ];

    if (!isset($_SESSION[$MODULO_CODE]["breadcrumbs"])) {
        $breadcrumbs = array(
            "current" => -1,
            "list" => []
        );
        $_SESSION[$MODULO_CODE]["breadcrumbs"] = $breadcrumbs;
    }
    
    $i = 0;
    $configurazione[$i]["nome"] = "Web Online";
    $configurazione[$i]["icona"] = "globe";
    $configurazione[$i]["link"] = $APP["url"]."/procedure";

    $i++;
    $configurazione[$i]["nome"] = "Categorie";
    $configurazione[$i]["icona"] = "tag";
    $configurazione[$i]["link"] = $APP["url"]."/categorie";

    $session->smarty->assign("configurazione", $configurazione);

    $session->smarty()->assign("APP", $APP);
    $session->set("MODULO_CODE", $MODULO_CODE, true);
    $session->save();
});





#
# INDEX 
#
$this->respond('GET', '/?', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    $session = getSession();
    $session->smarty()->display("webonline-config-index.tpl");
    exit();
});


#
# PROCEDURE 
#
$this->respond('GET', '/procedure/?[a:tipo]?', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    $session = getSession();
    $db = getDB();
    $tipo = $request->tipo;
    if (strlen($tipo) == 0)
        $tipo = 'X';
    
    # LEGGO TUTTE LE PROCEDURE DELLA SEZIONE
    $sql = "SELECT p.*, v.label0 as label_categoria 
            , (select count(*) from MetaParametri where code_sp=p.code) as paramcount
            FROM MetaProcedure p
            left join MetaVoci v ON v.code_voce=p.categoria
            WHERE p.tipo=?
            ORDER BY p.Categoria, p.label0";
    $rs = $db->Execute($sql, array($tipo));
    if ($rs)
        $procedure = $rs->GetArray();

    $session->smarty()->assign("procedure", $procedure);
    $session->smarty()->display("webonline-config-procedure.tpl");
    exit();
});




#
# PROCEDURA 
#
$this->respond('GET', '/procedura/[a:code]', function ($request, $response, $service, $app) { #'/?[a:tipo]?'
    $session = getSession();
    $db = getDB();
    $code_procedura = $request->code;
    
    $procedura = Factory::crea("MetaProcedura", $code_procedura);

    $session->smarty()->assign("procedura", $procedura);
    $session->smarty()->display("webonline-config-procedura.tpl");
    exit();
});