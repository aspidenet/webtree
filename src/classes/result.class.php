<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


#class EmailInvalidException extends \Exception { }


class Result extends Exception{
    const INFO = "INFO";
    const WARNING = "WARNING";
    const ERROR = "ERROR";
    
    private $_fields;
    
    function __construct($params=[], $code="OK", $description="", $level=Result::INFO, $customs=null) {
        parent::__construct($description);
        $this->set($params, $code, $description, $level, $customs);
    }
    
    # MAGIC
    public function __sleep() {
        return array('_fields');
    }
    
    public function __toString()
    {
        return $this->getDescription();
    }
    
    # GETTER
    public function get() {
        return $this->_fields;
    }
    public function getResult() {
        return $this->_fields["result"];
    }
    public function getResultCode() {
        return $this->_fields["code"];
    }
    public function getDescription() {
        return $this->_fields["description"];
    }
    public function getLevel() {
        return $this->_fields["level"];
    }
    public function getCustoms() {
        return $this->_fields["customs"];
    }
    
    # SETTER
    public function set($params=[], $code="OK", $description="", $level=Result::INFO, $customs=null) {
        if (is_array($params) && count($params) > 0)
            $this->_fields = $params;
        elseif (is_bool($params)) {
            $this->_fields = [
                "result" => $params,
                "code" => $code,
                "description" => $description,
                "level" => $level,
                "customs" => $customs,
            ];
        }
        else
            $this->_fields = [
                "result" => true,
                "code" => "OK",
                "description" => "",
                "level" => $this::INFO,
                "customs" => $customs,
            ];
    }
    public function setResult($val) {
        $this->_fields["result"] = $val;
    }
    public function setCode($val) {
        $this->_fields["code"] = $val;
    }
    public function setDescription($val) {
        $this->_fields["description"] = $val;
    }
    public function setLevel($val) {
        $this->_fields["level"] = $val;
    }
    public function setCustoms($val) {
        $this->_fields["customs"] = $val;
    }
    public function setFromException($ex, $code="KO", $level=Result::ERROR) {
        $this->setResult(false);
        $this->setDescription($ex->getMessage());
        $this->setCode($code);
        $this->setLevel($level);
    }
    
    # SPECIAL
    public function toJson() {
        return json_encode($this->_fields, true);
    }
    public function debug() {
        DEBUG($this->_fields);
    }
}