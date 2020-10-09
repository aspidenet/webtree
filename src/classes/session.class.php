<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Session {
    private $vars;
    public $smarty;
    function __construct() {
        $this->vars = array();
        
        $this->smarty = new Smarty;
        $this->smarty->template_dir = array(
        
            CUSTOM_DIR."/src/templates",
            BASE_DIR."/src/templates",
        );
        $this->smarty->compile_dir =  BASE_DIR."/templates_c";
        
        $this->smarty->registerPlugin("modifier",'base64_encode',  'base64_encode');
        
        #$this->smarty->cache_dir = "cache";
        #$this->smarty->config_dir = "configs";
        #$this->smarty->debug = true;
    }
    
    public function get($varname, $default=false) {
        if (isset($this->vars[$varname]))
            return $this->vars[$varname];
        elseif (isset($_SESSION[$varname]))
            return $_SESSION[$varname];
        return $default;
    }
    
    public function set($varname, $value, $sess=true) {
        $this->vars[$varname] = $value;
        if ($sess)
            $_SESSION[$varname] = $value;
    }
    
    public function save() {
        $_SESSION['SESSION'] = serialize($this);
    }
    
    public function user() {
        if (isset($_SESSION['USER']))
            $user = unserialize($_SESSION['USER']);
        else
            $user = new User();
        return $user;
    }
    
    public function smarty() {
        return $this->smarty;
    }
    
    public function log($text) {
        if (is_object($text))
            error_log(var_export($text, true));
        elseif (is_array($text))
            error_log(var_export($text, true));
        else
            error_log($text);
    }
    
    public function checkLogin() {
        if (isset($_SESSION['USER']))
            return true;
        return false;
    }
    
    public function assertLogin($url=null) {
        if (!$this->checkLogin()) {
            if ($url)
                $this->set("REDIRECT_URL_AFTER_LOGIN", $url, true);
            $this->redirect(ROOT_DIR."/login");
        }
    }
    
    ################################################################################
    # checkBearer:
    ################################################################################
    public function checkBearer() {
        $db = getDB();
        
        $headers = apache_request_headers();#$request->headers();
        $token = str_replace("Bearer ", "", $headers["Authorization"]);
        
        # TODO estrarre username dal token
        $decifrato = openssl_decipher($token);
        $data = substr($decifrato, 0, 8);
        $username = substr($decifrato, 8, strlen($decifrato));
        if (date("Ymd") != $data) {
            error_log("Data non corrisponde a {$data}. Bearer check fallito!");
            return false;
        }
        
        $sql = "SELECT username
                FROM Users
                WHERE username=? AND flag_active='S'";
        $rs = $db->Execute($sql, array($username));
        
        if ($rs->RecordCount() == 1)
            return $username;
        
        error_log("Username {$username} inesistente o non attivo. Bearer check fallito!");
        return false;
    }

    ################################################################################
    # assertBearer:
    ################################################################################
    public function assertBearer() {
        $check = $this->checkBearer();
        
        if ($check === false) {
            header("HTTP/1.1 401 Unauthorized");
            $result = [ 
                "code" => 401,
                "authentication" => "failed",
                "reason" => "bearer token unknown"
            ];
            echo_json($result);
            exit();
        }
    }
    
    
    // public function isAdmin($uid) {
        // if (in_array(strtoupper($uid), array('C0707', '53698'))) {
            // return true;
        // }
        // return false;
    // }
    
    public function redirect($url) {
        if (strlen($url) > 0) {
            $this->log("Redirect: {$url}");
            header("Location:{$url}");
            exit();
        }
    }
    
    // public function checkMatricola($matricola) {
        // $operatore = $this->user();
        
        // if ($operatore->admin()) {
            // $this->log("L'operatore {$operatore->uid()} e' ADMIN!");
            // return $matricola;
        // }
        // else {
            // $this->log("L'operatore {$operatore->uid()} NON e' ADMIN!");
            // return $operatore->matricola();
        // }
    // }
    
    
    public function menu() {
        if (!$this->checkLogin()) 
            return false;
        
        $user = $this->user();
        $db = getDB();
        
        $sql = "SELECT DISTINCT m.link, m.icon, m.label0 as menu, m.menu_code, COALESCE(m.module_code, mo.module_code) as module_code, mo.label0 as module
                FROM Users u
                JOIN RelUserProfile up ON u.username=up.user_code
                JOIN RelProfileMenu pm ON pm.profile_code=up.profile_code
                JOIN Profiles p ON p.profile_code=up.profile_code
                JOIN Modules mo ON mo.module_code=p.module_code
                JOIN Menus m ON m.menu_code=pm.menu_code
                WHERE u.username=?";
        $rs = $db->Execute($sql, array($user->username()));
        $result = $rs->GetArray();
        
        $menu = array();
        foreach($result as $item) {
            $module_code = $item["module_code"];
            $module = $item["module"];
            $menu_code = $item["menu_code"];
            
            $menu[$module_code]["title"] = $module;
            $menu[$module_code]["items"][$menu_code] = array(
                "title" => $item["menu"],
                "link" => $item["link"],
                "image" => $item["icon"],
            );
        }

        return $menu;
    }
}