<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Relation extends Base {
    private function init() {
        $master_template_code = $this->get("master_code");
        $slave_template_code = $this->get("slave_code");
        
        $this->_customdata["master_template"] = Template::load($master_template_code);
        $this->_customdata["slave_template"] = Template::load($slave_template_code);
    }
    
    function __construct($code) {
        parent::__construct();
        
        $this->_customdata["code"] = $code;
        
        $db = getDB();
        $sql = "SELECT * FROM MetaRelations WHERE relation_code='{$code}'";
        $rs = $db->Execute($sql);
        $this->_fields = $rs->GetRow();

        $this->init();
    }
    
    public function loadFromRS($rs) {
        $this->_fields = $rs->GetRow();
        $this->init();
    }
    
    public function loadFromArray($row) {
        $this->_fields = $row;
        $this->init();
    }
    
    #
    # TEMPLATES
    #
    public function templateMaster() {
        return $this->_customdata["master_template"];
    }
    public function templateSlave() {
        return $this->_customdata["slave_template"];
    }
    
    #
    # DB FIELDS
    #
    public function dbfieldCode() {
        return $this->get("code_dbfield");
    }
    public function dbfieldMaster() {
        return $this->get("master_dbfield");
    }
    public function dbfieldSlave() {
        return $this->get("slave_dbfield");
    }
    
    
    public function dbview() {
        return $this->get("dbview");
    }
    public function dbtable() {
        return $this->get("dbtable");
    }
    
    public function class() {
        return $this->get("class");
    }
    
    
    
    static function load($code) {
        if (isset($_SESSION['RELATIONS'][$code])) {
            $relation = unserialize($_SESSION['RELATIONS'][$code]);
        }
        else {
            $relation = new Relation($code);
        }
        return $relation;
    }

    public function save() {
        $code = $this->_customdata["code"];
        $_SESSION['RELATIONS'][$code] = serialize($this);
    }
}