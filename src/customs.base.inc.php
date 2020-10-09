<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


#------------------------------------------------------------------------------
# CONSTANTS WEB3
#------------------------------------------------------------------------------
define("CUSTOM_CODE", "default");
define("CUSTOM_SOURCES", array("default" => "Webtree"));

define("DB_TYPE", "mssqlnative");
define("DB_HOST_SERVER", ""); 
define("DB_USERNAME", ""); 
define("DB_PASSWORD", ""); 
define("DB_NAME", "web3_".CUSTOM_CODE);

define("APPNAME", "Webtree");

define("ROOT_DIR", "");
define("STATIC_URL", "/static/".CUSTOM_CODE);

define("LOCALE", "it_IT.UTF-8");
define("BASE_NAME", "webtree");
define("BASE_DIR", "/var/www/".BASE_NAME);

define("SECRET", '');
define("BASE_URL", "https://".$_SERVER["SERVER_NAME"]);
define("API_URL", "/api");
define("SYNC_URL", "");

define("APP_BASE_URL", "");

define("INDEX", "");
define("TEST", true);
define("EMAIL_SUPPORT", "");
define("PROXY", "");

define("MONEY_DECIMAL", 2);
define("MONEY_SIGN", "EUR");

define("LDAP_SERVERS", "");
define("LDAP_PORT", 389);
define("LDAP_BASE_DN", "");
define("LDAP_BIND_DN", "");
define("LDAP_BIND_PW", "");
define("LDAP_LOGINATTRIB", "uid");
define("LDAP_FILTER", "");


define("LOGINFO",    10001);
define("LOGWARNING", 10002);
define("LOGERROR",   10003);


// FILTRI DINAMICI
define("FILTRO_UTENTE", "{USERNAME}");
define("FILTRO_MATRICOLA", "{MATRICOLA}");
define("FILTRO_GRUPPO", "{GRUPPO}");
define("FILTRO_ESERCIZIO", "{ESERCIZIO}");



$modules = array(
    
    'login',
    'sys',
    #'static',
    'json',
    'list',
    'modal',
    'admin' => array(
        "config",
        "webonline"
    ),
    'wizard',
    'navigazione',
    'webonline'
);

#error_log('Load customs;');