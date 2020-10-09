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
    # Richiesta /STATIC
    if (stripos($request->uri(), "/static/") !== false)
        return;
    // if (stripos($request->uri(), "/sync/") !== false) {
        // error_log($request->method()." URI: ".$request->uri());
        // return;
    // }
    
    $session = getSession();
    
    # Devo ricreare la Session perché va reinizializzata la configurazione di Smarty in caso di cambio contesto
    if ($session->checkLogin() === false) {
        if (isset($_SESSION['SESSION']))
            unset($_SESSION['SESSION']);
        $session = getSession();
    }
    $session->log("------------------------------------------------------");
    $session->log($request->method()." URI: ".$request->uri());
    #$session->log($request->method()." PATH: ".$request->pathname());
    #$session->log($request->headers());
    $session->log("------------------------------------------------------");
    // echo "<br>INDEX<br>URI: ".$request->uri()."<br>";
    // echo "PATHNAME: ".$request->pathname()."<br>";
    // echo "METHOD: ".$request->method()."<br>";
    // echo "ROOT_DIR: ".ROOT_DIR.APP_BASE_URL ."<br>";
    // $passed_params = $request->params();
    // $headers = $request->headers();
    // echo "<br>HEADERS:<br>";
    // print_r($headers);
    // echo "<br><br>PARAMS:<br>";
    // print_r($passed_params);
    // echo "-----------------------------------------------------------<br>";
    
    // Ci sono parti pubbliche: ciascun modulo stabilirà se è sotto login o no e a quale livello
    // if (stripos($request->uri(), "/sync") === false) {
        // if (stripos($request->uri(), "/login") === false) {
            // $session->assertLogin($request->uri());
        // }
    // }
    $session->smarty->assign("APP_BASE_URL", ROOT_DIR.APP_BASE_URL);
    $session->smarty->assign("STATIC_URL", CURRENT_STATIC_URL);
    $session->smarty->assign("APPNAME", APPNAME);
    $session->smarty->assign("TEST", TEST);
    $session->smarty->assign("RIBBON", RIBBON);
    $session->smarty->assign("CUSTOM_CODE", get("CUSTOM_CODE", CUSTOM_CODE));
    $session->smarty->assign("CUSTOM_SOURCES", CUSTOM_SOURCES);
    $session->smarty->assign("REQUEST_URI", str_ireplace(ROOT_DIR.APP_BASE_URL, "", $request->pathname()));
    $session->smarty->assign("REQUEST", $request);
    $session->smarty->assign("EMAIL_SUPPORT", EMAIL_SUPPORT);
    
    // $service->addValidator('SearchName', function ($str) {
        // return preg_match("/^([0-9a-z@. ])*(['])?([0-9a-z@. ])*(['?????])?$/i", $str);
    // });
    
    $session->smarty->assign("now", time());
    $session->smarty->assign("session", $session);
    $session->smarty->assign("operatore", $session->user());
    $session->save();
});





# INDEX
$this->respond('GET', APP_BASE_URL."/?", function ($request, $response, $service, $app) {
    $session = getSession();
    
    if (isset($_SESSION['WIZARDS']))
        unset($_SESSION['WIZARDS']);
    
    if (isset($_SESSION["NAVIGAZIONE"]["breadcrumbs"]))
        unset($_SESSION["NAVIGAZIONE"]["breadcrumbs"]);
    
    if (defined('ROOT_URL'))
        if (strlen(ROOT_URL) > 0)
            $session->redirect(ROOT_URL);
        
    $session->smarty->assign("HOMEPAGE", true);
    $session->smarty->display("index.tpl");
    #print_r($session->user());
    #print_r($_SESSION['USER']);
    #print_r($_SESSION['SSO']);
    exit();
});

# LOGOUT
$this->respond('GET', APP_BASE_URL."/logout", function ($request, $response, $service, $app) {
    error_log("FINE SESSIONE");
    // if (isset($_SESSION['SSO']))
        // unset($_SESSION['SSO']);
    if (isset($_SESSION['USER']))
        unset($_SESSION['USER']);
    if (isset($_SESSION['SESSION']))
        unset($_SESSION['SESSION']);
    // session_unset();
    // session_destroy();
    $session = getSession();
    $session->redirect("/");
    exit();
});

# PHP-INFO
// $klein->respond('GET', ROOT_DIR.APP_BASE_URL."/phpinfo", function ($request, $response, $service, $app) {
    // phpinfo();
    // exit();
// });

# test
// $this->respond('GET', APP_BASE_URL."/test", function ($request, $response, $service, $app) {
    // $testo = date("Ymd")."marce"; #"mio nonno in cariolo con le mutande viola.";
    
    // echo $testo."<br>";
    // $cifrato = openssl_cipher($testo);
    // echo $cifrato."<br>";
    // $decifrato = openssl_decipher($cifrato);
    // echo $decifrato."<br>";
// });


# crash
$this->respond('GET', APP_BASE_URL."/crash", function ($request, $response, $service, $app) {
    throw new Exception("Error");
});