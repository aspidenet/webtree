<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


/***********************************************************************************
 Classe Tabulator
***********************************************************************************/
class Tabulator {
    private $m_columns;
    private $m_ajax_url;
    private $m_data_index;
    private $m_data_index2;
    private $m_title;
    private $m_json;
    private $m_recordset_code;
    private $m_source_config_url;
	
	################################################
	# Costruttore.
	public function __construct() {
	}
	
    public function setTitle($title) {
        $this->m_title = $title;
    }
	
    public function setColumns($col) {
        $this->m_columns = $col;
    }
	
    public function setAjaxUrl($url) {
        $this->m_ajax_url = $url;
        $this->m_json = "custom";
    }
	
    public function setDataIndex($index, $index2=null) {
        $this->m_data_index = $index;
        if (!is_null($index2))
            $this->m_data_index2 = $index2;
    }
	
    public function setSourceConfigUrl($url) {
        $this->m_source_config_url = $url;
    }
    
	
    # se la sorgente è una query
    public function setSource($sql, $params, $code, $exclude=array(), $recordset_code=null, $from="FROM") {
        $session = getSession();
        foreach($exclude as $k => $i) {
            $exclude[$i] = strtolower($i);
        }
        $db = getDB();
        $sql2 = str_ireplace($from, "FROM", $sql);
        $rs = $db->Execute($sql2, $params);
        $rows = array();
        if ($rs && $rs->RecordCount() > 0) {
            $rows = $rs->GetRow();
            $fields = array();
            $cols = $rs->fieldCount();
            for($i=0;$i<$cols;$i++){
                $fld = $rs->FetchField($i);
                $fields[strtolower($fld->name)] = $fld;
            }
        }

        foreach($rows as $key => $item) {
            $key = strtolower($key);
            if (!in_array($key, $exclude)) {
                $formatter = "plaintext";
                $formatterParams = "";
                switch($fields[$key]->type) {
                    case "int":
                        $formatter = "money";
                        $formatterParams = "{ decimal:',',thousand:'.',symbol:'',symbolAfter:'',precision:0 }";
                        break;
                        
                    case "decimal":
                        $formatter = "money";
                        $formatterParams = "{ decimal:',',thousand:'.',symbol:'',symbolAfter:'',precision:false }";
                        break;
                    
                    case "date":
                    case "datetime":
                        $formatter = "datetime";
                        $formatterParams = "{ inputFormat:'YYYY-MM-DD',outputFormat:'DD/MM/YYYY' }";
                        break;
                    
                    case "nvarchar":
                    case "varchar":
                    case "ntext":
                    case "text":
                    default:
                        $formatter = "plaintext";
                        break;
                }
                if ($key == 'xxx')
                    $formatter = "html";
                
                $record_source[$key] = array(
                    'title' => $key,
                    'field' => $key,
                    'visible' => "true",
                    'formatter' => $formatter,
                    'formatterParams' => $formatterParams,
                );
            }
        }
        
        # Se c'è un recordset, rigenero la configurazione delle colonne
        if (strlen($recordset_code) >0) {
            # Azzero la visibilità vecchia
            // foreach($record as $key => $item) {
                // $record[$key]['visible'] = "false";
            // }
            
            # Prendo la configurazione del recordset
            $sql3 = "SELECT * FROM RecordsetColumns WHERE recordset_code=? ORDER BY sorting";
            $rs = $db->Execute($sql3, array($recordset_code));
            #$record = array();
            while(!$rs->EOF) {
                $dbcolumn = $rs->Fields("dbcolumn");
                $label = $rs->Fields("label0");
                $visible = $rs->Fields("flag_visible");
                $format_code = $rs->Fields("format_code");
                $formatterParams = "";
                $cellClick = "";
                if (isset($record_source[$dbcolumn])) {
                    switch($format_code) {
                        case "INT":
                            $formatter = "money";
                            $formatterParams = "{ decimal:',',thousand:'.',symbol:'',symbolAfter:'',precision:0 }";
                            break;
                            
                        case "NUMERIC":
                            $formatter = "money";
                            $formatterParams = "{ decimal:',',thousand:'.',symbol:'',symbolAfter:'',precision:false }";
                            break;
                        
                        case "DATE":
                            $formatter = "datetime";
                            $formatterParams = "{ inputFormat:'YYYY-MM-DD',outputFormat:'DD/MM/YYYY' }";
                            break;
                        
                        case "FILE":
                        case "LINK":
                            $formatter = "html";
                            //$formatterParams = "{ decimal:',',thousand:'.',symbol:'',symbolAfter:'',precision:0 }";
                            $cellClick = "function(e, cell){ e.stopPropagation(); }";
                            break;
                            
                        case "TEXT":
                        default:
                            $formatter = "plaintext";
                            break;
                    }
                    
                    $record[$dbcolumn] = array(
                        'title' => $label,
                        'field' => $dbcolumn,
                        'visible' => ($visible == 'S') ? "true" : "false",
                        'formatter' => $formatter,
                        'formatterParams' => $formatterParams,
                        'cellClick' => $cellClick
                    );
                }
                $rs->MoveNext();
            }
        }
        else
            $record = $record_source;
        
        $this->setColumns($record);
        
        $code = preg_replace('/[^\da-zA-Z]/i', '', $code);
        
        $_SESSION["JSON"][$code]["sql"] = $sql;
        $_SESSION["JSON"][$code]["params"] = $params;
        $_SESSION["JSON"][$code]["exclude"] = $exclude;
        $_SESSION["JSON"][$code]["from"] = $from;
        $this->setDataIndex($code);
        $this->m_json = "query";
        $this->m_recordset_code = $recordset_code;
    }
	
    # se la sorgente è una stored procedure
    public function setStoredProcedure($sql, $params, $token, $exclude=array(), $recordset_code=null) {
        foreach($exclude as $k => $i) {
            $exclude[$i] = strtolower($i);
        }
        $db = getDB();
        $rs = $db->Execute($sql, $params);
        $records = $rs->GetArray();
        if (count($records)) {
            foreach($records[0] as $key => $item) {
                $key = strtolower($key);
                if (!in_array($key, $exclude))
                    $record_source[$key] = array(
                        'title' => $key,
                        'field' => $key,
                        'visible' => "true"
                    );
            }
        }
        
        # Se c'è un recordset, rigenero la configurazione delle colonne
        if (strlen($recordset_code) >0) {
            # Azzero la visibilità vecchia
            // foreach($record as $key => $item) {
                // $record[$key]['visible'] = "false";
            // }
            
            # Prendo la configurazione del recordset
            $sql3 = "SELECT * FROM RecordsetColumns WHERE recordset_code=? ORDER BY sorting";
            $rs = $db->Execute($sql3, array($recordset_code));
            #$record = array();
            while(!$rs->EOF) {
                $dbcolumn = $rs->Fields("dbcolumn");
                $label = $rs->Fields("label0");
                $visible = $rs->Fields("flag_visible");
                if (isset($record_source[$dbcolumn])) {
                    $record[$dbcolumn] = array(
                        'title' => $label,
                        'field' => $dbcolumn,
                        'visible' => ($visible == 'S') ? "true" : "false"
                    );
                }
                $rs->MoveNext();
            }
        }
        else
            $record = $record_source;
        
        $this->setColumns($record);
        
        $token = preg_replace('/[^\da-zA-Z]/i', '', $token);
        
        // $_SESSION["JSON"][$code]["sql"] = $sql;
        // $_SESSION["JSON"][$code]["params"] = $params;
        // $_SESSION["JSON"][$code]["exclude"] = $exclude;
        // $_SESSION["JSON"][$code]["records"] = $records;
        $session = getSession();
        $MODULO_CODE = $session->get("MODULO_CODE");
        $session->log("MODULO_CODE: ".$MODULO_CODE);
            
        $_SESSION[$MODULO_CODE]["risultati"][$token] = $records;
        
        $this->setDataIndex($token);
        $this->m_json = "storedprocedure";
        $this->m_recordset_code = $recordset_code;
    }
	
    # se la sorgente è un oggetto recordset
    public function setRecordset($code, $filter="", $params=array()) {
        $db = getDB();
        $session = getSession();
        
        $sql = "SELECT * FROM Recordsets WHERE code=?";
        $rs = $db->Execute($sql, array($code));
        $row = $rs->GetRow();
        
        $sql = $row["source"];
        if (stripos($sql, "WHERE") === false)
            $sql .= " WHERE 1=1 ";
        if (stripos($filter, "WHERE") !== false)
            $filter = str_replace("WHERE", "AND", $filter);
        $sql .= $filter;
        $rs = $db->Execute($sql, $params);
        $session->log("Tabulator::setRecordset()");
        $session->log($sql);
        $session->log($params);
        $record = $rs->GetRow();
        
        $_SESSION["JSON"][$code]["sql"] = $sql;
        $_SESSION["JSON"][$code]["params"] = $params;
        
        $sql = "SELECT * FROM RecordsetColumns WHERE recordset_code=? ORDER BY sorting";
        $rs = $db->Execute($sql, array($code));
        $columns = array();
        while(!$rs->EOF) {
            $dbcolumn = $rs->Fields("dbcolumn");
            $label = $rs->Fields("label0");
            $columns[$dbcolumn] = array(
                'title' => $label,
                'field' => $dbcolumn,
                'visible' => "true"
            );
            $rs->MoveNext();
        }
        
        $this->setColumns($columns);
        
        $this->setDataIndex($code);
        $this->m_json = "recordset";
        $this->m_recordset_code = $code;
    }
    
    # se la sorgente è un wizard in memoria
    public function setMemoryWizard($wizard_code, $tab_index, $exclude=array(), $recordset_code=null) {
        $session = getSession();
        $wizard = Wizard::load($wizard_code);
        $wizard_index = $wizard->getIndex();
        $index = $wizard_index[$tab_index];
        $template_code = $index["template"];
        $template = Template::load($template_code);
        $fields = $template->getFields();
        
        $columns = array();
        foreach($fields as $metafield) {
            $dbcolumn = $metafield->dbfield();
            $label = $metafield->label();
            $columns[$dbcolumn] = array(
                'title' => $label,
                'field' => $dbcolumn,
                'visible' => "true"
            );
        }
        
        $this->setColumns($columns);
        
        $this->setDataIndex($wizard_code, $tab_index);
        $this->m_json = "wizard";
    }
    
    public function getAjaxUrl() {
        if ($this->m_json == "custom") 
            return $this->m_ajax_url;
        elseif ($this->m_json == "query") 
            return APP_BASE_URL."/json/q/{$this->m_data_index}";
        elseif ($this->m_json == "storedprocedure") 
            return APP_BASE_URL."/json/sp/{$this->m_data_index}";
        elseif ($this->m_json == "recordset") 
            return APP_BASE_URL."/json/rs/{$this->m_data_index}";
        elseif ($this->m_json == "wizard") 
            return APP_BASE_URL."/json/wiz/{$this->m_data_index}/{$this->m_data_index2}";
        else
            return "";
    }
    
    public function getExportUrl() {
        if ($this->m_json == "query") 
            return APP_BASE_URL."/json/export/q/{$this->m_data_index}";
        elseif ($this->m_json == "storedprocedure") 
            return APP_BASE_URL."/json/export/sp/{$this->m_data_index}";
        elseif ($this->m_json == "recordset") 
            return APP_BASE_URL."/json/export/rs/{$this->m_data_index}";
        else
            return "";
    }
	
	public function display($selector, $height=null, $page_size=100, $row_function=null, $selectable=false, $movable=false) {
        $session = getSession();

        $session->smarty()->assign("tabulator_selector", $selector);
        $session->smarty()->assign("tabulator_height", $height);
        $session->smarty()->assign("tabulator_page_size", $page_size);
        if ($selectable)
            $session->smarty()->assign("row_select_function", $row_function);
        else
            $session->smarty()->assign("row_click_function", $row_function);
        
        if ($movable) {
            $session->smarty()->assign("tabulator_movable", true);
            $session->smarty()->assign("tabulator_movable_url", $movable);
        }
        else
            $session->smarty()->assign("tabulator_movable", false);
        
        $session->smarty()->assign("tabulator_selectable", $selectable);
        $session->smarty()->assign("tabulator_title", $this->m_title);
        $session->smarty()->assign("tabulator_columns", $this->m_columns);
        
        if (count($this->m_columns) > 7 && false)
            $session->smarty()->assign("tabulator_layout", "fitDataFill");
        else
            $session->smarty()->assign("tabulator_layout", "fitColumns");
        
        
        $session->smarty()->assign("ajax_url", $this->getAjaxUrl());
        $session->smarty()->assign("recordset_code", $this->m_recordset_code);
        $session->smarty()->assign("source_config_url", $this->m_source_config_url);
		$session->smarty()->display("class.tabulator.tpl");
	}
    
    
    
    
    
    
    

	
}