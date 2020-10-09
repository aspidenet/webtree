<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


# TEMP
class X {
    private $_modulo_code;
    
	################################################
	# Costruttore.
	public function __construct($modulo_code=null) {
        GLOBAL $MODULO_CODE;
        if (is_null($modulo_code))
            $this->_modulo_code = $MODULO_CODE;
        else
            $this->_modulo_code = $modulo_code;
	}
	
	public function checkLink($data, $key="") {
        $MODULO_CODE = $this->_modulo_code;
    
		$key = strtolower($key);

		if (strpos($key, 'file_') !== FALSE) {
			if (strlen(trim($data)) == 0)
				return 'non disponibile';
            elseif (strpos($data, 'http') === 0)
                return '<a href="'.$data.'" target="_blank"><img src="images/mime_doc.png" width="22px" height="22px" /></a>';
            else
				#return '<a href="'.ROOT_DIR.'files/patrim/'.$data.'" target="_blank"><i class="icon big file pdf"></i></a>';
				return '<a href="'.ROOT_DIR.'files/wmtest.pdf" target="_blank"><i class="icon big file pdf"></i></a>';
		}
		elseif (strpos($data, '??') === FALSE) {
            if ($_SESSION[$MODULO_CODE]["tipi_campi"][$key] == "numero") {
                if (strpos($data, '.') === FALSE)
                    $data = number_format ($data, 0, ',', '.');
                else
                    $data = number_format ($data, 2, ',', '.');
            }   
            elseif ($_SESSION[$MODULO_CODE]["tipi_campi"][$key] == "data") {
                $data = date_translate($data, 'us', 'it');
            }
			return $data;
        }
			
		$array = explode('??', $data);
		
		return "<a href='".$array[1]."'>".$array[2]."</a>";
    }   
    
    public function writeHead($key="", $label="") {
        if ($key == "wmflag_controllo")
            return;
            
		if (strpos($key, 'style_') !== FALSE) {
            $key = substr($key, strpos($key, '}') + 1, strlen($key));
		}
        if (strpos($key, 'file_') !== FALSE)
            $key = str_replace("file_", "", $key);
        
        #echo "<th class='centrato grassetto'>";
        if (strlen($label))
            echo $label;
        else
            echo $key;
        #echo "</th>";
	}  
        
    public function writeValue($data, $key="", $riga) {
        $session = getSession();
        $MODULO_CODE = $this->_modulo_code;
   
		$key = strtolower($key);
        // $session->log("KEY: ".$key);
        // $session->log("MODULO_CODE: ".$MODULO_CODE);
        // $session->log($_SESSION[$MODULO_CODE]["tipi_campi"]);
        
        if ($_SESSION[$MODULO_CODE]["tipi_campi"][$key] == "numero") {
            $allineamento = "right aligned";
        }
        elseif ($_SESSION[$MODULO_CODE]["tipi_campi"][$key] == "data") {
            $allineamento = "center aligned";
        }
        else
            $allineamento = "left aligned";
            
        $colore = "white";
		$forecolore = "nero";
        
        if (strpos($key, 'style_') !== FALSE) {
            $style = substr($key, strpos($key, '{')+1, strpos($key, '}')-strpos($key, '{')-1);
            $style .= "font-weight:bold;";
		}
        else
            $style = "";
        
        echo "<td class='bg_{$riga}{$colore} {$forecolore} {$allineamento} note' style='{$style}'>";
        echo $this->checkLink($data, $key);
        echo "</td>";
	}
}