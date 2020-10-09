<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


/************************************************************************************
* classe User
************************************************************************************/
class User extends Meta {
	
	################################################
	# Costruttore.
	public function __construct() {
		parent::__construct();
	}
	################################################
	# LOAD
	public function load($uid) {
        GLOBAL $DBMODULI;
        $session = getSession();
        $db = getDB();
        
        try {
            $sql = "SELECT *, u.ident as user_id, r.ident as registry_id  
                    FROM dbo.Registries r
                    RIGHT OUTER JOIN dbo.RelUserRegistry ur ON r.registry_code = ur.slave_code
                    RIGHT OUTER JOIN dbo.Users u ON ur.master_code = u.username 
                    WHERE flag_active='S'
                    AND username=?";
            $rs = $db->Execute($sql, array($uid));
            
            $count = $rs->RecordCount();
            if ($count == 0)
                throw new Exception("Utente {$uid} inesistente o non configurato.");
                
            $row = $rs->GetRow();
            
            $this->set("id", $row["user_id"]);
            $this->set("username", $row["username"]);
            $this->set("label", $row["person_surname"]." ".$row["person_name"]);
            $this->set("nome", $row["person_name"]);
            $this->set("cognome", $row["person_surname"]);
            $this->set("admin", $row["flag_admin"]);
            
            // Azioni
            $sql = "SELECT DISTINCT a.action_code
                    FROM Users u
                    JOIN RelUserProfile up ON u.username=up.user_code
                    JOIN RelProfileAction pa ON pa.profile_code=up.profile_code
                    JOIN Actions a ON a.action_code=pa.action_code
                    WHERE u.username=?";
            $rs = $db->Execute($sql, array($uid));
            $result = $rs->GetArray();
            $actions = array();
            foreach($result as $item) {
                $actions[] = strtolower($item["action_code"]);
            }
            $this->set("actions", $actions);
            
            
            $_SESSION['USER'] = serialize($this);
            
            $rs->Close();
            return true;
        }
        catch(Exception $ex) {
            $session->log("User::load: ".$ex->getMessage());
            throw $ex;
        }
        return false;
	}
    

	################################################
	# LOGIN.
	public function login($username, $password) {
		$db = getDB();
        $session = getSession();

        try {
            $sql = "SELECT *
                    FROM dbo.Users 
                    WHERE flag_active='S'
                    AND username=? AND password=?";
            $rs = $db->Execute($sql, array($username, $password));
            
            $count = $rs->RecordCount();
            if ($count == 0)
                throw new Exception("Login fallito o utente inesistente.");
                
            return $this->load($username);
        }
        catch(Exception $ex) {
            $session->log("User::login: ".$ex->getMessage());
            throw $ex;
        }
		return false;
	}
	
	################################################
	# GET
	public function uid() {
		return $this->get("username");
	}
	public function username() {
		return $this->get("username");
	}
	public function matricola() {
		return $this->get("matricola");
	}
	public function label() {
		return $this->get("label");
	}
	public function admin() {
		return toBool($this->get("admin"));
	}
	public function codeStruttura() {
		return $this->get("code_struttura");
	}
	public function codeServizio() {
		return $this->get("code_servizio");
	}
	public function codeSettore() {
		return $this->get("code_settore");
	}
	public function manager($codestruttura=null) {
        if ($this->admin())
            return true;
        $manager = $this->get("manager");
        if (is_null($codestruttura))
            return $manager;
        else
            return isset($manager[$codestruttura]);
	}
    public function gruppo($gruppo) {
        if ($this->admin())
            return true;
        
        if ($gruppo == "WEBONLINE") {
            if (in_array(strtolower($this->username()), array(
                    ''
                ))) { 
                return true;
            }
        }
        
        if ($gruppo == "NAVIGAZIONE") {
            if (in_array(strtolower($this->username()), array(
                    ''
                ))) { 
                return true;
            }
        }
        
        return false;
	}
    public function has($action) {
        $actions = $this->get("actions");
        if (in_array(strtolower($action), $actions)) { 
            return true;
        }
        return false;
    }
}