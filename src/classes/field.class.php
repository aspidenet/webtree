<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Field extends Base {
    
    function __construct($row) {
        parent::__construct();
        
        $this->_fields = $row;
    }
    
    
    
    #--------------------------------------------------------
    
    public function visible($action='R') {
        if ($action == 'I') {
            if ($this->get("flag_ins_visible") == 'S')
                return true;
        }
        elseif ($action == 'U' || $action == 'R') {
            if ($this->get("flag_upd_visible") == 'S')
                return true;
        }
        
        return false;
    
    }
    
    public function mandatory($action='R') {
        if ($action == 'I') {
            if (toBool($this->get("flag_ins_mandatory")))
                return true;
        }
        elseif ($action == 'U') {
            if (toBool($this->get("flag_upd_mandatory")))
                return true;
        }
        return false;
    }
    
    public function modifiable($action='R') {
        #if ($this->get())
    
        return true;
    }
    #--------------------------------------------------------
    
    public function dbfield() {
        return $this->get("dbfield");
    }
    public function format() {
        return $this->get("format_code");
    }
    
    public function default() {
        return $this->get("default_value");
    }
    
    
    
    
    
    public function display($action='R', $value=null) {
        $session = getSession();
        $list = array();
        if (strlen($this->get("list_code"))) {
            # se è un template
            $template_code = $this->get("list_code");
            $template = Template::load($template_code);
            # se è una lista
            # TODO
            
            $db = getDB();
            $sql = "SELECT * FROM {$template->dbview()}";
            $rs = $db->Execute($sql);
            while (!$rs->EOF) {
                $key = $rs->Fields($template->dbkey());
                $label = $rs->Fields($template->dblabel());
                $list[$key] = $label;
                $rs->MoveNext();
            }
            $session->log("MetaField::display(): LIST table: {$template->dbtable()}, key {$template->dbkey()}, label {$template->dblabel()}");
        }
        elseif (strlen($this->get("classtype_code"))) {
            # se è un template
            $classtype = new ClassType($this->get("classtype_code"));
            $list = $classtype->nodes();
            $session->log("MetaField::display(): ClassType: ".$this->get("classtype_code"));
        }
        $ui = new UI();
        $ui->displayFields(array($this), $action, array($value), $list);
    }

}