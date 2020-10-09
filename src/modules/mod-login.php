<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//



#
# LOGIN
#
$this->respond('GET', "/?", function ($request, $response, $service, $app) {
    $session = getSession();
    $url = $session->get("REDIRECT_URL_AFTER_LOGIN", ROOT_DIR.APP_BASE_URL."/");
    $session->log("LOGIN - ".$url);
    if (!$session->checkLogin($url)) {
        if (CUSTOM_CODE == "default")
            $session->smarty->display(BASE_DIR."/src/templates/login.tpl");
        else
            $session->smarty->display("login.tpl");
        exit();
    }
    $session->redirect($url);
    exit();
});


#
# LOGIN POST
#
$this->respond('POST', "/?", function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDB();
    $user = new User();
    $result = new Result();
    
    $username = get("uname", 0);
    #$username = substr($username, 0, MAX_LEN_USERNAME); // Prendo SOLO i primi X caratteri.
    $password = get("passwd", 0);
    #$password = substr($password, 0, MAX_LEN_PASSWORD); // Prendo SOLO i primi Y caratteri.
    #$session->log("UNAME: ".$username);
    #$session->log("PASSWD: ".$password);
    
    if (strlen($username) == 0) {
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription("E' necessario indicare lo username.");
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }

    if (strlen($password) == 0) {
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription("E' necessario indicare una password.");
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }

    try {
        $res = $user->login(trim($username), md5(trim($password)));
        if ($res) {
            if ($session->get("REDIRECT_URL_AFTER_LOGIN") === false) {
                error_log("No redirect");
                echo_text("OK");
                exit();
            }
            else {
                error_log("Redirect ".$session->get("REDIRECT_URL_AFTER_LOGIN"));
                $result->setResult(true);
                $result->setCode("OK");
                $result->setDescription("Login effettuata con successo.");
                $result->setLevel(Result::INFO);
                $result->setCustoms(['url' => $session->get("REDIRECT_URL_AFTER_LOGIN")]);
                return $result->toJson();
            }
        }
    }
    catch (Exception $ex) {
        $result->setResult(false);
        $result->setCode("KO");
        $result->setDescription($ex->getMessage());
        $result->setLevel(Result::ERROR);
        return $result->toJson();
    }
    $result->setResult(false);
    $result->setCode("KO");
    $result->setDescription("Accesso fallito. Verificare nome utente e password.");
    $result->setLevel(Result::ERROR);
    return $result->toJson();
    
});