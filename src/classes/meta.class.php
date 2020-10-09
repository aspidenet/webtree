<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class Meta implements \Serializable {
    protected $_fields;
    
    function __construct() {
        $this->_fields = [];
    }
    
    public function id() {
        if (isset($this->_fields["id"]))
            return $this->_fields["id"];
        return 0;
    }
    
    
    public function serialize() {
        return serialize($this->_fields);
    }
    public function unserialize($data) {
        $this->_fields = unserialize($data);
    }
    
    public function get($fieldname) {
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
}