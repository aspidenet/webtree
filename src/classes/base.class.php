<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Base implements \Serializable {
    protected $_fields;
    protected $_customdata;
    private $_template;
    
    function __construct($template=null) {
        $this->_fields = [];
        #$this->_template = $template;
        if (!is_null($template) && is_object($template)) {
            $this->table($template->dbtable());
            $this->_customdata["label"] = $template->dblabel();
            $this->_customdata["dbkey"] = $template->dbkey();
            $this->_customdata["template_code"] = $template->code();
        }
    }
    
    public function id() {
        if (isset($this->_fields["ident"]))
            return $this->_fields["ident"];
        return 0;
    }
    
    
    
    public function serialize() {
        return serialize([
            'fields' => serialize($this->_fields),
            'customdata' => serialize($this->_customdata)
        ]);
    }
    public function unserialize($data) {
        $data = unserialize($data);
        $this->_fields = unserialize($data['fields']);
        $this->_customdata = unserialize($data['customdata']);
    }
    
    public function get($fieldname) {
        if (isset($this->_fields[$fieldname]))
            return $this->_fields[$fieldname];
        # tentiamo in minuscolo se non lo fosse gia'
        $fieldname = strtolower($fieldname);
        if (isset($this->_fields[$fieldname]))
            return $this->_fields[$fieldname];
        return false;
    }
    
    public function set($fieldname, $value) {
        #if (isset($this->_fields[$fieldname])) {
            $this->_fields[$fieldname] = $value;
            return true;
        #}
        #return false;
    }
    
    public function fields() {
        return $this->_fields;
    }
    
    
    
    public function table($name=null) {
        if (is_null($name))
            return $this->_customdata["table"];
        $this->_customdata["table"] = $name;
    }
    
    public function label($lang=0) {
        $session = getSession();
        // $session->log("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        // $session->log("BASE::label()");
        // $session->log($this->_fields);
        // $session->log("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        
        if (isset($this->_fields["label{$lang}"])) {
            //$session->log("LABEL0");
            return $this->_fields["label{$lang}"];
        }
        elseif (isset($this->_customdata["label"])) {
            //$session->log("TEMPLATE");
            return $this->_fields[$this->_customdata["label"]];
        }
        # TODO: il valore di dblabel potrebbe essere una concatenazione di campi. bisogna inventare un metacodice.
        //$session->log("FALSE");
        return false;
    }
    
    
    public function read($code) {
        $session = getSession();
        $db = getDB();
        $sql = "SELECT * FROM {$this->table()} WHERE {$this->_customdata["dbkey"]}=?";
        $rs = $db->Execute($sql, array($code));
        $row = $rs->GetRow();
        foreach($row as $key => $item)
            $this->set($key, $item);
    }
}

?>