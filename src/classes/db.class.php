<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


/*
/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
\ Classe RS                                                  /
/                                                            \
\ Oggetto che descrive il recordset risultante di una query. /
/                                                            \
\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
*/
class RS {
	private $m_adorecordset;

	public function __call($name,  $arguments) {
	#	return call_user_func_array(array($this->m_adorecordset, $name), $arguments);
		// DEBUG($name);
		// print_r($arguments);
		// DEBUG('');
        $session = getSession();
		$session->log("RS::".$name." NOT found!");
		$session->log($arguments);
		die();
	}
	public function __get($name) {
		return $this->m_adorecordset->$name;
	}
	#-----------------------------------------------------------------------------
	public function setRS($rs) {
		if (is_object($rs))
			$this->m_adorecordset = $rs;
	}
	public function getRS() {
		return $this->m_adorecordset;
	}
	public function get($nomecampo) {
		return $this->Fields($nomecampo);
	}
	#-----------------------------------------------------------------------------
	public function Fields($nomecampo=null) {
        if (is_null($nomecampo)) {
            $fields = array();
            $f = $this->FieldTypesArray();
            foreach($f as $item) {
                $fields[strtolower($item->name)] = $item;
            } 
            return $fields;
        }
        
		switch (ADODB_ASSOC_CASE) {
			case 0: # lower
				$nomecampo = strtolower($nomecampo);
				break;
			case 1: # UPPER
				$nomecampo = strtoupper($nomecampo);
				break;
			
			default:# non faccio nulla.
				break;
		}
		return $this->m_adorecordset->Fields($nomecampo); #utf8_encode
	}

	public function RecordCount() {
		return $this->m_adorecordset->RecordCount();
	}
	public function FieldCount() {
		return $this->m_adorecordset->FieldCount();
	}
	public function FieldTypesArray() {
		return $this->m_adorecordset->FieldTypesArray();
	}
	public function FetchField($pos) {
		return $this->m_adorecordset->FetchField($pos);
	}


	public function MoveFirst() {
		if (get_class($this->m_adorecordset) == 'ADORecordSet_empty')
			return true;
		return $this->m_adorecordset->MoveFirst();
	}

	public function MoveNext() {
		if (get_class($this->m_adorecordset) == 'ADORecordSet_empty')
			return true;
		return $this->m_adorecordset->MoveNext();
	}

	public function Close() {
		return $this->m_adorecordset->Close();
	}

	public function GetArray() {
		if (get_class($this->m_adorecordset) == 'ADORecordSet_empty')
			return array();
		return array_change_key_case($this->m_adorecordset->GetArray(), CASE_LOWER);
	}

	public function GetRows() {
		return array_change_key_case($this->m_adorecordset->GetRows(), CASE_LOWER);
	}

	public function GetRow() {
		return array_change_key_case($this->m_adorecordset->FetchRow(), CASE_LOWER);
	}

	public function FetchRow() {
		return array_change_key_case($this->m_adorecordset->FetchRow(), CASE_LOWER);
	}
	
	public function LastPageNo() {
		return $this->m_adorecordset->LastPageNo();
	}
	public function AtFirstPage() {
		return $this->m_adorecordset->AtFirstPage();
	}
	public function AtLastPage() {
		return $this->m_adorecordset->AtLastPage();
	}
}

$ADODB_FETCH_MODE = ADODB_FETCH_ASSOC; //ADODB_FETCH_BOTH;
/*******************************************************************************

/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
\ Classe DB                                                /
/                                                          \
\ Oggetto che descrive il database.                        /
/                                                          \
\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
*/
class DB {
	public $link;
	private $db_type;
	private $last_error_code;
	private $last_error_message;

	private $db_name;
	private $db_host;
	private $db_user;

	private $m_querylist;
	private $m_langid;
	private $m_language;
	
	################################################
	# Costruttore.
	function __construct($db_type=DB_TYPE) {
		$this->db_type = $db_type;
	}
	
	################################################
	function __sleep() {
		return array("db_type", "db_name", "m_langid", "m_language");
	}
	
	################################################
	function __wakeup() {
		$this->Connetti();
		$this->Init();
	}

	################################################
	# GET
	function get($what) {
		switch ($what) {
			case 'type':
				return $this->db_type;
				break;

			case 'host':
				return $this->db_host;
				break;

			case 'user':
				return $this->db_user;
				break;

			case 'database':
				return $this->db_name;
				break;

			case 'langid':
				return $this->m_langid;
				break;

			case 'language':
				return $this->m_language;
				break;
		}
	}
 
	################################################
	# Connetti:
	function Connetti($host=DB_HOST_SERVER, $user=DB_USERNAME, $pwd=DB_PASSWORD, $nomedb="") {
        
		if (strlen($nomedb) > 0)
			$this->db_name = $nomedb;
		elseif (isset($_SESSION["DB_NAME"]) && strlen($_SESSION["DB_NAME"]) > 0)
			$this->db_name = $_SESSION["DB_NAME"];
		else
			$this->db_name = DB_NAME;

		$this->db_host = $host;
		$this->db_user = decifra($user);
        
        #error_log("Mi collego a ".$this->db_name);

		// Creo la connessione:
		$this->link = ADONewConnection($this->db_type);
		#$this->link->charPage = 65001;

		$res = $this->link->PConnect($host, decifra($user), decifra($pwd), $this->db_name);
		#DEBUG("$host, $user, $pwd, $nomedb");
		#DEBUG("$host, ".decifra($user).", ".decifra($pwd).", $this->db_name");
        // if ($res === false)
            // throw new Exception("DB KO");
        
        #$this->link->debug = true;
        
		return $res;
	}

	################################################
	# Init:
	function Init() {
		if ($this->db_type == "mssql" || $this->db_type == "xxxxmssqlnative") {
			$this->Execute("SET ANSI_WARNINGS ON");
			$this->Execute("SET ANSI_NULLS ON");
			$this->Execute("SET ANSI_NULL_DFLT_ON ON");
			#$this->Execute("SET NOCOUNT ON");
            #$this->Execute("SET CONCAT_NULL_YIELDS_NULL ON", false);

			// if (strlen($this->m_language) == 0) {
				// $rs = $this->Execute("SELECT @@langid as code, @@language as label", true);
				// if ($rs != FALSE) {
					// $this->m_langid = strtolower(substr($rs->Fields("label"), 0, 2));
					// $this->m_language = $rs->Fields("label");
				// }
			// }
		}
	}
 
	################################################
	# Disconnetti:
	function Disconnetti() {
		$res = $this->link->Disconnect();
		StampaErrore($res, "Disconnessione fallita.", true);
		return $res;
	}
 
	################################################
	# Execute:
	function Execute($sql, $params=array(), $logga=true, $titolo='SQL') {
        if (strlen($sql) == 0)
			return true;
        
        #$sql = str_ireplace("Consolidamento.", "Consolidamento_".CUSTOM_CODE.".", $sql);
        #$sql = str_ireplace("Consolidamento.", "Consolidamento_web3.", $sql);
        
        
        try {
            $res = $this->link->Execute($sql, $params);
            if ($res != FALSE) {
                $rs = new RS();
                $rs->setRS($res);
                return $rs;
            }
            else {
                $this->last_error_code = $this->link->ErrorNo();
                $this->last_error_message = $this->link->ErrorMsg();
                return FALSE;
            }
        }
        catch (Exception $e)
        {   
            $session = getSession();
            error_log("--- SQL --------------------------------------------");  
            error_log($sql);   
            $session->log($params);   
            error_log("----------------------------------------------------");  
            error_log($e->getMessage());   
            error_log("--- /SQL -------------------------------------------");  
            $this->last_error_code = $e->getCode();
            $this->last_error_message = $e->getMessage();
            $user = $session->user();
            if ($user->admin())
                $ex = new Result(false, "KO", $e->getMessage(), Result::ERROR);
            else
                $ex = new Result(false, "KO", "Errore di esecuzione nel database, impossibile proseguire. Segnalare agli amministratori.", Result::ERROR);
            #$ex->setFromException($e);
            throw $ex;
            return FALSE;
        }
	}
 
	################################################
	# ErrorNo:
	function ErrorNo() {
		return $this->last_error_code;
	}
	
	################################################
	# ErrorMsg:
	function ErrorMsg() {
		return $this->last_error_message;
	}
	
	################################################
	# StartTrans:
	function StartTrans($mode="serializable") {
        #return true;
		#$this->link->setTransactionMode($mode);
		return $this->link->startTrans(); # <-- INIZIO TRANSAZIONE.
	}
	
	################################################
	# CompleteTrans:
	function CompleteTrans($autocomplete=true) {
        #return true;
		$res = $this->link->completeTrans($autocomplete); # <-- FINE TRANSAZIONE.
		if ($this->TransNo() == 0) {
			Factory::conferma($res);
			
			if (strlen($this->m_querylist) > 0) {
				if ($res)
					$this->Logga(LOGINFO, "TRANSAZIONE OK", $this->m_querylist);
				else
					$this->Logga(LOGERROR, "TRANSAZIONE FALLITA!", $this->m_querylist);
				$this->m_querylist = "";
			}
		}

		return $res;
	}

	################################################
	# CompleteTrans:
	function HasFailedTrans() {
		return $this->link->hasFailedTrans(); # <-- CHECK FINE TRANSAZIONE.
	}

	################################################
	# CompleteTrans:
	function FailTrans() {
		#$this->Execute("INSERT INTO TABELLACHENONESISTE VALUES('pippo', 'pluto', 'topolino')");
		return $this->link->failTrans(); # <-- FORZO ROLLBACK.
	}

	function TransNo() {
		return $this->link->transCnt;
	}
	
	function FailAllTrans() {
		if ($this->transNo() > 0) {
			$this->failTrans();

			while ($this->transNo() > 0)
				$this->completeTrans();
		}
	}

	################################################
	# :
	function qStr($string) {
		return $this->link->qStr($string);
	}
    
	################################################
	# :
	function DbName() {
		return $this->db_name;
	}

	function Data($data) {
		# DATA E' ITALIANA
		if (check_date_format($data, 'it')) {
			if ($this->m_langid == 'it')
				;
			else
				$data = date_translate($data, 'it', 'us');
		}
		# DATA NON E' ITALIANA
		elseif (check_date_format($data, 'us')) {
			if ($this->m_langid == 'it')
				$data = date_translate($data, 'us', 'it');
			else
				;
		}
		else
			$data = "";


		return $data;
	}
}