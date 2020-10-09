<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


#---------------------------------------------------------------------------
# FUNCTIONS
#---------------------------------------------------------------------------
 
function autoload($className) {
    try {
        require_once("classes/".strtolower($className).".class.php");
    } catch (Exception $e) {
        #error_log("{$fileName}.class.php");
        require_once(strtolower($className).".php");
    }
}

# FUNZIONE SLUGIFY
function slugify($text) {
    // replace non letter or digits by -
    $text = preg_replace('~[^\pL\d]+~u', '-', $text);

    // transliterate
    $text = iconv('utf-8', 'us-ascii//TRANSLIT', $text);

    // remove unwanted characters
    $text = preg_replace('~[^-\w]+~', '', $text);

    // trim
    $text = trim($text, '-');

    // remove duplicate -
    $text = preg_replace('~-+~', '-', $text);

    // lowercase
    $text = strtolower($text);

    if (empty($text)) {
        return 'n-a';
    }

    return $text;
}

/*******************************************************************************
   
*******************************************************************************/
function check_login() {
    if (!isset($_SESSION['USER'])) {
        error_log("NON LOGGATO!!!!");
        header("Location:/login");
        exit();
    }
}

# SEND AS JSON
function echo_json($text, $clear_buffer=true, $exit=true) {
    # cancella il buffer (cancella eventuali 'echo' precedenti che non dovrebbero esserci)
    if ($clear_buffer)
        ob_clean();
    echo json_encode($text);
    if ($exit)
        exit();
}

# SEND AS TEXT
function echo_text($text, $clear_buffer=true) {
    # cancella il buffer (cancella eventuali 'echo' precedenti che non dovrebbero esserci)
    if ($clear_buffer)
        ob_clean();
    echo trim($text);
}

function get($name, $default=null, $source_array=null) {
    $value = null;
    
    if (!is_null($source_array)) {
        if (isset($source_array[$name]))
            $value = $source_array[$name];
    }
    elseif (isset($_GET[$name])) {
        $value = $_GET[$name];
    }
    elseif (isset($_POST[$name])) {
        $value = $_POST[$name];
    }
    elseif (isset($_SESSION[$name])) {
        $value = $_SESSION[$name];
    }

    if (is_null($value) && !is_null($default))
        return $default;

    return $value;
}

# GENERA CODICE PORTA UN AMICO
function genera_codice() {
    #return strtoupper(substr(md5(microtime()), rand(0, 10), 5));
    return md5(microtime());
}

# GET SESSION
function getSession() {
    if (isset($_SESSION['SESSION'])) {
        $session = unserialize($_SESSION['SESSION']);
    }
    else {
        $session = new Session();
    }
    return $session;
}

# GET USER
function getUser() {
    if (isset($_SESSION['USER'])) {
        $operatore = unserialize($_SESSION['USER']);
    }
    else {
        $operatore = new User();
    }
    return $operatore;
}

# GET DB
function getDB() {
    GLOBAL $db;
    
    if (is_null($db) || !is_object($db)) {
        $db = new DB();
        $db->Connetti();
        $db->Init();
    }
    // else
        // error_log("DB: riprendo l'oggetto gia' in memoria.");
    return $db;
}

################################################################################
# DEBUG:
################################################################################
function DEBUG($text) {
	if (is_object($text))
        echo var_export($text, true)."<br>";
    elseif (is_array($text))
        print_r($text)."<br>";
    else
        echo $text."<br>";
}

################################################################################
# cifra:
################################################################################
function cifra($str) {
	return base64_encode($str);
}

################################################################################
# decifra:
################################################################################
function decifra($str) {
	return base64_decode($str);
}

################################################################################
# cifra:
################################################################################
function openssl_cipher($plaintext) {
	//$key previously generated safely, ie: openssl_random_pseudo_bytes
    $ivlen = openssl_cipher_iv_length($cipher="AES-128-CBC");
    $iv = openssl_random_pseudo_bytes($ivlen);
    $ciphertext_raw = openssl_encrypt($plaintext, $cipher, SECRET, $options=OPENSSL_RAW_DATA, $iv);
    $hmac = hash_hmac('sha256', $ciphertext_raw, SECRET, $as_binary=true);
    $ciphertext = base64_encode( $iv.$hmac.$ciphertext_raw );
    return $ciphertext;
}

################################################################################
# decifra:
################################################################################
function openssl_decipher($ciphertext) {
	$c = base64_decode($ciphertext);
    $ivlen = openssl_cipher_iv_length($cipher="AES-128-CBC");
    $iv = substr($c, 0, $ivlen);
    $hmac = substr($c, $ivlen, $sha2len=32);
    $ciphertext_raw = substr($c, $ivlen+$sha2len);
    $original_plaintext = openssl_decrypt($ciphertext_raw, $cipher, SECRET, $options=OPENSSL_RAW_DATA, $iv);
    $calcmac = hash_hmac('sha256', $ciphertext_raw, SECRET, $as_binary=true);
    if (hash_equals($hmac, $calcmac)) { //PHP 5.6+ timing attack safe comparison
        return $original_plaintext;
    }
    return false;
}

# BOOL
function toBool($char) {
    if ($char === true)
        return true;
	if (strcasecmp($char, 'S') == 0)
		return true;
	if (strcasecmp($char, '1') == 0)
		return true;
	return false;
}

# number
function to_number($stringa, $format_from='it', $format_to='us') {
	
	// La stringa e' VUOTA:
	if (strlen($stringa) == 0)
		return "";
	
	if (preg_match ("/\A(-){0, 1}([0-9]+)((,|.)[0-9]{3, 3})*((,|.)[0-9]){0, 1}([0-9]*)\z/" ,$stringa) == 1)
		return 0;
        
    # TODO: distinguere formati di ingresso/uscita.
    # Al momento converte qualunque cosa in formato 'us'.

	// ____________________________________________________
	// La stringa NON ha PUNTI:
	if (strpos($stringa, ".") === false) {
		// e nemmeno VIRGOLE
		if (strpos($stringa, ",") === false) {
			return intval($stringa);
		}
		// c'e' almeno UNA virgola:
		else {
			// se ce n'e' piu' d'una:
			if (substr_count($stringa, ",") > 1)
				return 0;
			else
				return str_replace(",", ".", $stringa);
		}
	}
	// ____________________________________________________
	// La stringa NON ha VIRGOLE:
	else if (strpos($stringa, ",") === false) {
		// se c'e' piu' di un PUNTO:
		if (substr_count($stringa, ".") > 1)
			return 0;
		else
			return $stringa;
		
	}
	// ____________________________________________________
	// La stringa ha PUNTI e VIRGOLE:
	else {
		# se l'ultimo e' un PUNTO:
		if (strrpos($stringa, ".") > strrpos($stringa, ",")) {
			$stringa = str_replace(",", "", $stringa);
			if (substr_count($stringa, ".") > 1)
				return 0;
			else
				return $stringa;
		}
		# se l'ultimo e' una VIRGOLA:
		else {
			$stringa = str_replace(".", "", $stringa);
			if (substr_count($stringa, ",") > 1)
				return 0;
			else
				return str_replace(",", ".", $stringa);;
		}
	}
}

################################################################################
# quote_string:
################################################################################
function quote_string($stringa, $null=false, $apici=true) {
    $apice = "'";
    if ($apici == false)
        $apice = "";
    # se null è permesso:
	if ($null) {
		if (strlen($stringa) == 0)
			return "null";
		else
			return $apice.str_replace(
  						array ('"', "'"),
  						array('"', "''"),
  						$stringa
  				).$apice;
	}
	else
		return $apice.str_replace(
								array ('"', "'"),
								array('"', "''"),
								$stringa
						).$apice;
}

################################################################################
# IsValidMail:
################################################################################
function IsValidMail($email) {
	return eregi ("^[[:alnum:]][a-z0-9_.-]*@[a-z0-9.-]+\.[a-z]{2,6}$", stripslashes(trim($email)));
}
################################################################################
# IsValidMail:
################################################################################
function checkCF($cf) {
    $cf = stripslashes(trim(strtoupper($cf)));
    
    /*/^(?:(?:[B-DF-HJ-NP-TV-Z]|[AEIOU])[AEIOU][AEIOUX]|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[1256LMRS][\dLMNP-V])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]$/i
    */
    //$regex = '/^[A-Z]{6}\d{2}[ABCDEHLMPRST]\d{2}[A-Z]\d{3}[A-Z]$/';
    $regex =  "/^(?:(?:[B-DF-HJ-NP-TV-Z]|[AEIOU])[AEIOU][AEIOUX]|[B-DF-HJ-NP-TV-Z]{2}[A-Z]){2}[\dLMNP-V]{2}(?:[A-EHLMPR-T](?:[04LQ][1-9MNP-V]|[1256LMRS][\dLMNP-V])|[DHPS][37PT][0L]|[ACELMRT][37PT][01LM])(?:[A-MZ][1-9MNP-V][\dLMNP-V]{2}|[A-M][0L](?:[1-9MNP-V][\dLMNP-V]|[0L][1-9MNP-V]))[A-Z]$/i";
	if (preg_match($regex, $cf)) {
        $s = 0;
        for( $i = 1; $i <= 13; $i += 2 ) {
            $c = $cf[$i];
            if( '0' <= $c && $c <= '9' )
                $s += ord($c) - ord('0');
            else
                $s += ord($c) - ord('A');
        }
        for( $i = 0; $i <= 14; $i += 2 ) {
            $c = $cf[$i];
            switch( $c ){
                case '0':  $s += 1;  break;
                case '1':  $s += 0;  break;
                case '2':  $s += 5;  break;
                case '3':  $s += 7;  break;
                case '4':  $s += 9;  break;
                case '5':  $s += 13;  break;
                case '6':  $s += 15;  break;
                case '7':  $s += 17;  break;
                case '8':  $s += 19;  break;
                case '9':  $s += 21;  break;
                case 'A':  $s += 1;  break;
                case 'B':  $s += 0;  break;
                case 'C':  $s += 5;  break;
                case 'D':  $s += 7;  break;
                case 'E':  $s += 9;  break;
                case 'F':  $s += 13;  break;
                case 'G':  $s += 15;  break;
                case 'H':  $s += 17;  break;
                case 'I':  $s += 19;  break;
                case 'J':  $s += 21;  break;
                case 'K':  $s += 2;  break;
                case 'L':  $s += 4;  break;
                case 'M':  $s += 18;  break;
                case 'N':  $s += 20;  break;
                case 'O':  $s += 11;  break;
                case 'P':  $s += 3;  break;
                case 'Q':  $s += 6;  break;
                case 'R':  $s += 8;  break;
                case 'S':  $s += 12;  break;
                case 'T':  $s += 14;  break;
                case 'U':  $s += 16;  break;
                case 'V':  $s += 10;  break;
                case 'W':  $s += 22;  break;
                case 'X':  $s += 25;  break;
                case 'Y':  $s += 24;  break;
                case 'Z':  $s += 23;  break;
            }
        }
        if( chr($s%26 + ord('A')) != $cf[15] )
            return false;
        return true;
    }
    return false; #eregi ("", );
}
################################################################################
# checkPIVA:
################################################################################
function checkPIVA($pi) {
		if( strlen($pi) == 0 )
			return false;
		else if( strlen($pi) != 11 )
			return false;
		if( preg_match("/^[0-9]{11}\$/sD", $pi) !== 1 )
			return false;
		$s = 0;
		for( $i = 0; $i < 11; $i++ ){
			$n = ord($pi[$i]) - ord('0');
			if( ($i & 1) == 1 ){
				$n *= 2;
				if( $n > 9 )
					$n -= 9;
			}
			$s += $n;
		}
		if( $s % 10 != 0 )
			return false;
		return true;
}

################################################################################
# checkIBAN:
################################################################################
function checkIBAN($iban) {

    // Normalize input (remove spaces and make upcase)
    $iban = strtoupper(str_replace(' ', '', trim($iban)));

    if (preg_match('/^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$/', $iban)) {
        $country = substr($iban, 0, 2);
        $check = intval(substr($iban, 2, 2));
        $account = substr($iban, 4);

        // To numeric representation
        $search = range('A','Z');
        foreach (range(10,35) as $tmp)
            $replace[]=strval($tmp);
        $numstr=str_replace($search, $replace, $account.$country.'00');

        // Calculate checksum
        $checksum = intval(substr($numstr, 0, 1));
        for ($pos = 1; $pos < strlen($numstr); $pos++) {
            $checksum *= 10;
            $checksum += intval(substr($numstr, $pos,1));
            $checksum %= 97;
        }

        return ((98-$checksum) == $check);
    } else
    return false;
}
################################################################################
# check_filtro_dinamico:
################################################################################
function check_filtro_dinamico($filtro) {	
	if (strcmp(FILTRO_UTENTE, $filtro) == 0)
		return TRUE;
	if (strcmp(FILTRO_MATRICOLA, $filtro) == 0)
		return TRUE;
	if (strcmp(FILTRO_GRUPPO, $filtro) == 0)
		return TRUE;
	if (strcmp(FILTRO_ESERCIZIO, $filtro) == 0)
		return TRUE;
	return FALSE;
}
################################################################################
# decodifica_filtri_dinamici:
################################################################################
function replace_dynamic_filters($text) {	
    $session = getSession();
    
    $text = str_replace(FILTRO_UTENTE, $session->user()->username(), $text);
	// $text = str_replace(FILTRO_MATRICOLA, $matricola, $text);
	// $text = str_replace(FILTRO_GRUPPO, $metautente->ou(), $text);
	// $text = str_replace(FILTRO_ESERCIZIO, $applicazione->esercizio(), $text);
	$text = str_replace("{OGGI}", date("d/m/Y"), $text);

	return $text;
}

################################################################################
# check_date_format:
################################################################################
# Parametri:
#   $date - data da controllare nel solo formato.
#   $format - formato data (it: gg/mm/aaaa, us: aaaa-mm-gg).
################################################################################
function check_date_format($date, $format='it') 
{
	$date = substr($date, 0, 10);
	
	// Delimitatori di testo: barre, punti, trattini
	$arr = preg_split('/[\/\.-]/', $date);
	if (count($arr) != 3)
		return false;
	
    if ($format == 'it')
		list ($giorno, $mese, $anno) = $arr;
	else
		list ($anno, $mese, $giorno) = $arr;
		
	if (!is_numeric($giorno))
		return false;
	if (!is_numeric($mese))
		return false;
	if (!is_numeric($anno))
		return false;
		
	if ($giorno > 31 || $giorno <= 0 || $mese > 12 || $mese <=0)
		return false;
		
  return true;
}

################################################################################
# check_date:
################################################################################
# Parametri:
#   $date - data da controllare.
#   $format - formato data (it: gg/mm/aaaa, us: aaaa-mm-gg).
################################################################################
function check_date($date, $format='it') 
{
	if (check_date_format($date, $format) == false)
  	    return false;
	
    if ($format == 'it')
		list ($giorno, $mese, $anno) = preg_split('/[\/\.-]/', $date);
	else
		list ($anno, $mese, $giorno) = preg_split('/[\/\.-]/', $date);
		
    return checkdate($mese, $giorno, $anno);
}

################################################################################
# date_translate:
################################################################################
# Parametri: 
# 	$format_input - data nel formato originale.
# 	$format_output - data nel formato da convertire.
################################################################################
function date_translate($date, $format_input='it', $format_output='us') {
	if (strlen($date) == 0)
		return "";
	$date = substr($date, 0, 10);
	
	if (check_date_format($date, $format_output) == true)
		return $date;
	elseif (check_date_format($date, $format_input) == false) {
			return false;
	}
	
	switch ($format_input) {
		case 'it':
			list($g,$m,$a) = preg_split('/[\/\.-]/', $date);
			if ($format_output == 'us')
				return $a."-".$m."-".$g;
			break;
			
		case 'us':
		default:
			list($a,$m,$g) = preg_split('/[\/\.-]/', $date);
			if ($format_output == 'it')
				return $g."/".$m."/".$a;
			break;
	}
	return false;
}

function json_tabulator_recordset($code, $filter="", $params=array(), $from="FROM") {
    $db = getDB();
    $session = getSession();
        
    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 100);
    $offset = ($page-1) * $size;
    
    // $sql = "SELECT * FROM Recordsets WHERE code=?";
    // $rs = $db->Execute($sql, array($code));
    // $row = $rs->GetRow();
    
    // $sql = $row["source"];
    // if (stripos($sql, "WHERE") === false)
        // $sql .= " WHERE 1=1 ";
    // $sql .= $filter;
    
    $sql = $_SESSION["JSON"][$code]["sql"];
    $params = $_SESSION["JSON"][$code]["params"];
        
    foreach($filters as $filter) {
        $name = "[{$filter['field']}]";
        $type = $filter["type"];
        $value = $filter["value"];
        
        $sql .= " AND {$name} {$type} '%{$value}%' ";
    }
    if (count($sorters)) {
        $sql .= " ORDER BY ";
        foreach($sorters as $sorter) {
            $name = "[{$sorter['field']}]";
            $dir = $sorter["dir"];
            
            $sql .= "{$name} {$dir},";
        }
        $sql = substr($sql, 0, -1);
    }
    else
        $sql .= " ORDER BY 1 ";

    $sql .= " OFFSET {$offset} ROWS FETCH NEXT {$size} ROWS ONLY";

    # aggiungiamo COUNT(*) OVER()
    $sql = str_ireplace($from, ",COUNT(*) OVER() as c FROM", $sql);

    $rs = $db->Execute($sql, $params);
    $session->log("json_tabulator_recordset()");
    $session->log($sql);
    $session->log($params);
    $data = array();
    if ($rs != FALSE) {
        $data = $rs->GetArray();
    }
    
    

    $result = [
        "last_page" => ceil($data[0]["c"] / $size),
        "data" => $data
    ];
    //return JSON formatted data
    echo_json($result); 
}

function json_tabulator_query($sql, $params=array(), $from="FROM") {
    $session = getSession();
    $db = getDB();
    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 100);
    $offset = ($page-1) * $size;
    
    if (stripos($sql, "WHERE") === false)
        $sql .= " WHERE 1=1 ";

    foreach($filters as $filter) {
        $name = "[{$filter['field']}]";
        $type = $filter["type"];
        $value = $filter["value"];
        
        $sql .= " AND {$name} {$type} '%{$value}%' ";
    }
    if (count($sorters)) {
        $sql .= " ORDER BY ";
        foreach($sorters as $sorter) {
            $name = "[{$sorter['field']}]";
            $dir = $sorter["dir"];
            
            $sql .= "{$name} {$dir},";
        }
        $sql = substr($sql, 0, -1);
    }
    else
        $sql .= " ORDER BY 1 ";

    $sql .= " OFFSET {$offset} ROWS FETCH NEXT {$size} ROWS ONLY";

    # aggiungiamo COUNT(*) OVER()
    $sql = str_ireplace($from, ",COUNT(*) OVER() as c FROM", $sql);

    $rs = $db->Execute($sql, $params);
    $data = array();
    if ($rs != FALSE) {
        $data = $rs->GetArray();
    }
    $session->log($sql);
    $session->log($params);
    
    $result = [
        "last_page" => ceil($data[0]["c"] / $size),
        "data" => $data
    ];
    //return JSON formatted data
    echo_json($result); 
}

function json_tabulator_storedprocedure($token, $filter="", $params=array()) {
    $session = getSession();
    $db = getDB();
    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 100);
    $offset = ($page-1) * $size;
    
    #$data = $_SESSION["JSON"][$token]["records"];
    $MODULO_CODE = $session->get("MODULO_CODE");
    $data = $_SESSION[$MODULO_CODE]["risultati"][$token];
    #$data = array_change_key_case($_SESSION[$MODULO_CODE]["risultati"][$token], CASE_LOWER);
    
    # sorters (attenzione che i sorters salvano i risultati nel nuovo ordine!)
    if (count($sorters)) {
        
        $orderby = $sorters[0]["field"];
        $dir = $sorters[0]["dir"];
        
        $sortArray = array();

        foreach($data as $rows) {
            foreach($rows as $key=>$value) {
                if(!isset($sortArray[$key])) {
                    $sortArray[$key] = array();
                }
                $sortArray[$key][] = $value;
            }
        }
        if ($dir == "asc")
            array_multisort($sortArray[$orderby], SORT_ASC, $data); 
        else
            array_multisort($sortArray[$orderby], SORT_DESC, $data); 
        $_SESSION[$MODULO_CODE]["risultati"][$token] = $data;
    }
    
    # filters
    if (count($filters)) {
    
        $data = array_filter($data, function ($var) use ($filters) {
            $res = true;
            foreach($filters as $filtro) {
                $field = $filtro["field"];
                $type = $filtro["type"];
                $value = $filtro["value"];
                
                switch($type) {
                    case "like":
                        $res &= stripos($var[$field], $value) !== false;
                        break;
                        
                    case "equal":
                        $res &= ($var[$field] == $value);
                        break;
                        
                    default:
                        $res &= true;
                        break;
                }
            }
            return $res;
        });
        
    }
    
    $result = [
        "last_page" => ceil(count($data) / $size),
        "data" => array_values($data)
    ];
    $session->log(json_encode($result));
    //return JSON formatted data
    echo_json($result); 
}

function json_tabulator_wizard($wizard_code, $tab_index, $filter="") {
    $db = getDB();
    $session = getSession();
        
    $filters = isset($_GET["filters"]) ? $_GET["filters"] : [];
    $sorters = isset($_GET["sorters"]) ? $_GET["sorters"] : [];
    $page = get("page", 1);
    $size = get("size", 100);
    $offset = ($page-1) * $size;
    
    $wizard = Wizard::load($wizard_code);
    $wizard_index = $wizard->getIndex();
    $index = $wizard_index[$tab_index];
    $data = array();
    foreach($index["records"] as $record) {
        $data[] = $record->fields();
    }

    $result = [
        "last_page" => ceil(count($index["records"]) / $size),
        "data" => $data
    ];
    //return JSON formatted data
    echo_json($result); 
}



function export($token, $format='xlsx', $page=1, $size=1000000) {
    $session = getSession();
    $MODULO_CODE = $session->get("MODULO_CODE");
    
    $offset = ($page-1) * $size;
    $data = $_SESSION[$MODULO_CODE]["risultati"][$token];
    $filters = $_SESSION[$MODULO_CODE]["filtri"][$token];
    
    # filters
    if (isset($filters)) {
    
        $data = array_filter($data, function ($var) use ($filters, $session) {
            $res = true;
            foreach($filters as $filtro) {
                $field = $filtro["field"];
                $type = $filtro["type"];
                $value = $filtro["value"];
                
                switch($type) {
                    case "like":
                        $res &= stripos($var[$field], $value) !== false;
                        break;
                        
                    case "equal":
                        $res &= ($var[$field] == $value);
                        break;
                        
                    default:
                        $res &= true;
                        break;
                }
            }
            return $res;
        });
        
    }
    
    if ($format == "json") {
        $result = [
            "last_page" => ceil(count($data) / $size),
            "data" => array_slice($data, $offset, $size, false)
        ];
        //return JSON formatted data
        echo(json_encode($result)); 
    }
    elseif($format == "xlsx") {
        // use PhpOffice\PhpSpreadsheet\Spreadsheet;
        // use PhpOffice\PhpSpreadsheet\Writer\Xlsx;
         
         
        $spreadsheet = new PhpOffice\PhpSpreadsheet\Spreadsheet();
        // Set properties
        $spreadsheet->getProperties()
            ->setCreator("WebTree")
            ->setLastModifiedBy("WebTree")
            ->setTitle("")
            ->setSubject("")
            ->setDescription("")
            ->setKeywords("")
            ->setCategory("");
            
        $sheet = $spreadsheet->getActiveSheet();
        
        //----------------------------------------------------------------------------
        // Record:
        // Per ogni riga:
        $row_index = 1;
        $first = true;
        $numfields = 0;
        foreach($data as $row) {
            if ($first) {
                //----------------------------------------------------------------------------
                // Nomi dei campi:
                $nomi_colonne = array_keys($row);
                $session->log($nomi_colonne);
                $numfields = count($nomi_colonne);
                for ($f = 0; $f < $numfields; $f++) {
                    $sheet->setCellValueByColumnAndRow($f+1, 1, $nomi_colonne[$f]);
                }
                $first = false;
                $row_index++;
            }
            for ($i=0; $i < $numfields; $i++) {
                $valore = @trim($row[$nomi_colonne[$i]]);
                $sheet->setCellValueByColumnAndRow($i+1, $row_index, $valore);
            }
            $row_index++;
        }
        
        $spreadsheet->setActiveSheetIndex(0);
        
        ob_clean();
        
        // Redirect output to a client’s web browser (Xlsx)
        header("Cache-Control: max-age=0, no-cache, must-revalidate, proxy-revalidate");
        // If you're serving to IE 9, then the following may be needed
        header('Cache-Control: max-age=1');
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename="webonline.xlsx"');
        header("Content-Transfer-Encoding: binary");
        
         // If you're serving to IE over SSL, then the following may be needed
        header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
        header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT'); // always modified
        header('Pragma: public'); // HTTP/1.0
        
        $writer = PhpOffice\PhpSpreadsheet\IOFactory::createWriter($spreadsheet, 'Xlsx');
        $writer->save("php://output");
    }
}
#error_log('Load functions;');