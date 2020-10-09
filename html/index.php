<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


ob_start();
session_start();
require_once("../src/common.inc.php");

try {
    
    $klein = new Klein\Klein();

    // Using range behaviors via if/else
    $klein->onHttpError(function ($code, $router) {
        $session = getSession();
        
        if ($code >= 400 && $code < 500) {
            $session->smarty->display("404.tpl"); 
            exit();
        } 
        elseif ($code >= 500 && $code <= 599) {
            error_log('uhhh, something bad happened');
            $session->smarty->display("500.tpl"); 
        }
    });

    
    # ROOT / INDEX
    $klein->with(APP_BASE_URL, "../src/modules/mod-root.php");
    

    # CUSTOM MODULES
    if (isset($custom_modules)) {
        foreach($custom_modules as $key =>$modulo) {
            if (is_array($modulo)) {
                $klein->with(APP_BASE_URL."/{$key}", CUSTOM_DIR."/src/modules/mod-{$key}.php");
                foreach($modulo as $submodulo) {
                    $klein->with(APP_BASE_URL."/{$key}/{$submodulo}", CUSTOM_DIR."/src/modules/mod-{$key}-{$submodulo}.php");
                }
            }
            else {
                $klein->with(APP_BASE_URL."/{$modulo}", CUSTOM_DIR."/src/modules/mod-{$modulo}.php");
            }
        }
    }

    # WEB3 STANDARD MODULES
    foreach($modules as $key =>$modulo) {
        if (is_array($modulo)) {
            $klein->with(APP_BASE_URL."/{$key}", "../src/modules/mod-{$key}.php");
            foreach($modulo as $submodulo) {
                $klein->with(APP_BASE_URL."/{$key}/{$submodulo}", "../src/modules/mod-{$key}-{$submodulo}.php");
            }
        }
        else {
            $klein->with(APP_BASE_URL."/{$modulo}", "../src/modules/mod-{$modulo}.php");
        }
    }

    #error_log("ora faccio il dispatch");
    $klein->dispatch();

}
catch(Exception $ex) {
    // echo "ERRORE! ".$ex->getMessage();
    // exit();
    $session = getSession();
    $session->log($ex->getMessage());
    $session->log($ex->getTraceAsString());
    $session->smarty->display("500.tpl"); 
    exit();
}