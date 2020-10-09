<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


class TableManager implements \Serializable {
    protected $_fields;
    protected $_customdata;
    
    function __construct($table) {
        $this->_fields = [];
        $this->_customdata["table"] = $table;
        
        $db = getDB();
        $session = getSession();
        
        // $vals = explode(".", $table);
        // $lastid = count($vals);
        // $table = $vals[$lastid - 1];
        
        // $sql = "sp_columns '{$table}'"; # NON PERMETTE DI LEGGERE UN DB DIVERSO DA QUELLO CORRENTE!
        $dbtable = $table;
        $dbsource = "";
        $e = explode(".", $dbtable);
        if (count($e) == 3) {
            $dbtable = $e[2];
            $dbsource = $e[0].".";
        }
        $session->log("TableManager::constructor({$table})");
        
        // Mi faccio dire le colonne della tabella da db
        $sql = "select *
                from {$dbsource}information_schema.columns
                where table_name=?
                order by table_name, ordinal_position";
        $rs = $db->Execute($sql, array($dbtable));
        $rows = $rs->GetArray();
        
        foreach($rows as $row) {
            $this->_fields[] = [
                "name" => $row["column_name"],
                "type" => $row["data_type"],
                "len" => intval($row["character_octet_length"]),
                "null" => ($row["is_nullable"] == 'NO') ? false : true,
                #"ident" => (stripos($row["type_name"], 'identity') === false) ? false : true,
                "ident" => ($row["column_name"] == 'ident') ? true : false,
                "default" => $row["column_default"]
            ];
        }
        #$session->log("TableManager::_fields.");
        #$session->log($this->_fields);
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
    
    // public function get($fieldname) {
        // if (isset($this->_fields[$fieldname]))
            // return $this->_fields[$fieldname];
        // return false;
    // }
    
    // public function set($fieldname, $value) {
        // #if (isset($this->_fields[$fieldname])) {
            // $this->_fields[$fieldname] = $value;
            // return true;
        // #}
        // #return false;
    // }
    
    public function table($name=null) {
        if (is_null($name))
            return $this->_customdata["table"];
        $this->_customdata["table"] = $name;
    }
    
    public function fields() {
        return $this->_fields;
    }
    
    public function check($baserecord, $dbkey=null) {
        $session = getSession();
        #$session->log("TableManager::check() - START");

        foreach($this->_fields as $column) {
            if ($column["ident"])
                continue;
            $rawval = $baserecord->get($column["name"]);

            if (strlen($rawval) == 0) {
                if (!$column["null"] && strlen($column["default"]) == 0) {
                    #$session->log("Il campo '{$column["name"]}' &egrave; obbligatorio.");
                    throw new Result(false, "KO", "Il campo '{$column["name"]}' della tabella {$this->table()} &egrave; obbligatorio ma non valorizzato.", Result::ERROR);
                }
                else 
                    continue;
            }
        }

        #$session->log("TableManager::check() - END");
        return true;
    }
    
    public function insert($baserecord, $dbkey=null) {
        $session = getSession();
        #$session->log("TableManager::insert() - START");
        $db = getDB();
        
        $sql = "INSERT INTO {$this->table()} (";
        
        $columns_list = $columns_string = $column_ident = "";
        
        foreach($this->_fields as $column) {
            if ($column["ident"]) {
                $column_ident = $column["name"];
                if (is_null($dbkey))
                    $dbkey = $column["ident"];
                continue;
            }
            $rawval = $baserecord->get($column["name"]);
            if (strlen($rawval) == 0)
                continue;
            
            $columns_list .= $column["name"].",";
        }
        $sql .= substr($columns_list, 0, -1).") VALUES(";
        
        foreach($this->_fields as $column) {
            if ($column["ident"])
                continue;
            $rawval = $baserecord->get($column["name"]);
            /*switch($column["type"]) {
                case 'int':
                    $value = intval($rawval);
                    break;
                default:
                    $value = $db->qStr($rawval);
                    break;
            }*/
            if (strlen($rawval) == 0) {
                // if ($column["null"])
                    // $rawval = null;
                // elseif (strlen($column["default"])) {
                    // $rawval = $column["default"];
                    // if ($column["type"] == 'bit')
                        // $rawval = intval($rawval);
                // }
                // else {
                    // #$session->log("Il campo '{$column["name"]}' &egrave; obbligatorio.");
                    // throw new Result(false, "KO", "Il campo '{$column["name"]}' &egrave; obbligatorio ma non valorizzato.", Result::ERROR);
                // }
                if (!$column["null"] && strlen($column["default"]) == 0) {
                    #$session->log("Il campo '{$column["name"]}' &egrave; obbligatorio.");
                    throw new Result(false, "KO", "Il campo '{$column["name"]}' &egrave; obbligatorio ma non valorizzato.", Result::ERROR);
                }
                else 
                    continue;
            }
            
            $columns_string .= "?,";
            $columns_values[] = $rawval;
        }
        $sql .= substr($columns_string, 0, -1).")";
        
        $session->log("TableManager::insert(): ".$sql);
        $session->log($columns_values);
        
        $db->Execute($sql, $columns_values);
        #$session->log("insert_Id(): ");
        #$session->log($db->link->insert_Id());
        $last_id = $db->link->insert_Id();
        $sql = "SELECT {$dbkey} FROM {$this->table()} WHERE {$column_ident}=?";
        #$session->log($sql);
        $rs = $db->Execute($sql, $last_id);
        
        #$session->log("TableManager::insert() - END");
        return $rs->Fields($dbkey);
    }
    
    public function update($baserecord, $dbkey="ident", $keyvalue=null) {
        $session = getSession();
        $db = getDB();
        
        $sql = "UPDATE {$this->table()} SET ";

        $values = array();
        foreach($this->_fields as $column) {
            
            if ($column["ident"])
                continue;
            $rawval = $baserecord->get($column["name"]);
            
            if (strlen($rawval) == 0) {
                if ($column["null"])
                    $value = "null";
                elseif (strlen($column["default"]))
                    $value = $column["default"];
                else
                    throw new Result(false, "KO", "Il campo '{$column["name"]}' è obbligatorio.", Result::ERROR);
            }
            else {
                #$value = $rawval;
                #$session->log("Column type: ".$column["type"]);
                switch($column["type"]) {
                    case 'int':
                        $value = intval($rawval);
                        break;
                    default:
                        $value = $db->qStr($rawval);
                        break;
                }
            }
            
            $values[] = $value;
            $sql .= "{$column["name"]}={$value},"; #?
        }
        if (is_null($keyvalue))
            $keyvalue = $baserecord->get($dbkey);
                
        $sql = substr($sql, 0, -1)." WHERE {$dbkey}=?";
        $values[] = $baserecord->get($dbkey);
        
        try {
            $session->log("TableManager::update(): ".$sql);
            $session->log($keyvalue);
            $db->Execute($sql, array($keyvalue)); #, $values
            #$session->log("query eseguita");
        }
        catch(Exception $ex) {
            #$session->log($ex);
            #$session->log($db->ErrorMsg());
            throw $ex;
        }
    }
    
    
    public function delete($baserecord, $dbkey="ident", $keyvalue=null) {
        $session = getSession();
        $db = getDB();
        
        $sql = "DELETE FROM {$this->table()} ";

        if (is_null($keyvalue))
            $keyvalue = $baserecord->get($dbkey);
                
        $sql .= " WHERE {$dbkey}=?";
        
        try {
            #$session->log($sql);
            ##$session->log($values);
            $db->Execute($sql, array($keyvalue)); #, $values
            #$session->log("query eseguita");
        }
        catch(Exception $ex) {
            #$session->log($ex);
            #$session->log($db->ErrorMsg());
            throw $ex;
        }
    }
    
    static function load($table, $force=false) {
        if (isset($_SESSION['TABLEMANAGER'][$table]) && !$force) {
            $manager = unserialize($_SESSION['TABLEMANAGER'][$table]);
        }
        else {
            $manager = new TableManager($table);
            $_SESSION['TABLEMANAGER'][$table] = serialize($manager);
        }
        return $manager;
    }
    
}