<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


/***********************************************************************************
 Classe UI
***********************************************************************************/
class UI {
	private $m_pre;
	private $m_post;
	private $m_readonly;
    private $m_numbers;
    private $html;

	################################################
	# Costruttore.
	public function __construct($readonly=false, $pre="", $post="") {
		$this->setReadonly($readonly);
		$this->setPrePost($pre, $post);
        $this->html = new HTML();
        $this->m_numbers = array(
            0                   => 'zero',
            1                   => 'one',
            2                   => 'two',
            3                   => 'three',
            4                   => 'four',
            5                   => 'five',
            6                   => 'six',
            7                   => 'seven',
            8                   => 'eight',
            9                   => 'nine',
            10                  => 'ten',
            11                  => 'eleven',
            12                  => 'twelve',
            13                  => 'thirteen',
            14                  => 'fourteen',
            15                  => 'fifteen',
            16                  => 'sixteen',
        );
	}
    
    private function numberName($number, $lang='en') {
        # per ora solo EN
        if (isset($this->m_numbers[$number]))
            return $this->m_numbers[$number];
        return false;
    }
	
	################################################
	# FILTRI DINAMICI - TEMP
	public function decodificaFiltriDinamici($testo) {
		return decodifica_filtri_dinamici($testo);
	}
	
	################################################
	# PRE-POST
	public function setPrePost($pre="", $post="") {
		$this->m_pre = $pre;
		$this->m_post = $post;
	}

	################################################
	# ReadOnly
	public function setReadonly($ro=false) {
		$this->m_readonly = $ro;
	}
	public function readonly() {
		return $this->m_readonly;
	}
    
    
    ################################################
	# Format
	public function format($metafield, $value, $placeholder="") {
        if (strlen($value) == 0) {
            echo $placeholder;
            return;
        }
            
        switch($metafield->format()) {
        
            case "DATE":
                $date = new DateTime($value);
                echo $date->format('d/m/Y');
                break;
        
            case "TEXT":
            default:
                echo $value;
                break;
        }
    }
    
    
    public function displayFields($fieldsArray, $action, $values=null, $list=null) {
        // $num = count($fieldsArray);
        
        // if ($num >= 2 || true) {
            // $num_name = $this->numberName($num);
            // echo "<div class='{$num_name} fields'>";
        // }
        
        echo "<div class='ui two column very compact stackable grid'>";

        foreach($fieldsArray as $key => $metafield) {
        
            // echo "<div class='field' style='border: 1px solid red;'>";
            
            // echo "<div class='field-label'>";
            // $this->label($metafield, $action);
            // echo "</div><div class='field-content'>";
            // $this->field($metafield, $action, $values[$key], $list);
            // echo "</div>";
            
            // echo "<div class='field-help'>";
            // echo $metafield->get("help0");
            // echo "</div>";
            
            // echo "</div>";
            echo "<div class='row'>";
            
            # Label + input
            echo "<div class='column'>";
                echo "<div class='field'><div class='field-label'>";
                $this->label($metafield, $action);
                echo "</div><div class='field-content'>";
                $this->field($metafield, $action, $values[$key], $list);
                echo "</div>";
                echo "</div>"; # fine field
            echo "</div>"; # fine column 1
            
            if ($action == 'I' || $action == 'U') {
                # help
                echo "<div class='column'>";
                if (strlen($metafield->get("help0"))) {
                    echo "<div class='ui orange message'><p><em>{$metafield->get("help0")}</em></p></div>";
                }
                echo "</div>"; # fine column 2
                echo "</div><div class='ui divider'>";
            }
            echo "</div>"; # fine row
        }
        echo "</div>"; # fine grid
        
        // if ($num >= 2 || true) {
            // echo "</div>";
        // }
    }
    

	################################################
	# LABEL
	public function label($metafield, $action='R') {

		if (!is_object($metafield))
			return "";
        
		if (!$metafield->visible($action)) 
			return;
  
		$label = $metafield->label();
        
        if ($metafield->mandatory($action) && $action != 'R') {
			$label .= "<span class='ui inverted red text'>*</span>";
		}

		if ($this->readonly() || $action == 'R') {
        
			$this->html->label($label);
			return;
		}
        // $help = "";
        // if (strlen($campo->helpLungo($lingua)) > 0)
            // $help = " <i class='info circle teal large icon' title=\"{$campo->helpLungo($lingua)}\" style='vertical-align:middle;'></i> ";
        // echo $obb_code.$label.$help;
        $this->html->label($label);
	}
	
	################################################
	# FIELD
	public function field($metafield, $action='R', $value=null, $list=null) {
        $props = [];
        $props["type"] = "text";
        $props["name"] = $metafield->dbfield();
        
        if (!is_object($metafield))
			return "";

		if (!$metafield->visible($action) && $metafield->format() != "CODE") {
            return "";
        }
        $readonly = ($this->m_readonly || $action == 'R');
        if ($readonly) {
            echo $this->format($metafield, $value);
            return;
        }
        else {
            // error_log("NO READONLY");
            // error_log("DEFAULT: ".$metafield->default());
            if (strlen($value) == 0 && strlen($metafield->default()) > 0)
                $value = $metafield->default();
            $props["value"] = $value;
        }
    
        if ($metafield->mandatory($action)) {
            $props["required"] = "required";
        }
		
        if (count($list)) {
            return $this->html->combobox($props, $list);
        }
        else {
            switch($metafield->format()) {
            
                // if ($campo->tipo() == 'I') {
                    // $onkeyup = "onkeypress='return soloNumeriInteri(event);'";
                // }
                // elseif ($campo->tipo() == 'F') {
                    // $onkeyup = "onkeypress='return soloNumeri(event);'";
                // }
                // elseif ($campo->tipo() == 'V') {
                    // $onkeyup = "onkeypress='return soloNumeri(event);'";
                // }
                // elseif ($campo->tipo() == 'P') {
                    // $props["type"] = "password";
                // }
            
                case "CODE":
                    $props["type"] = "hidden";
                    $props["value"] = (strlen($value)) ? $value : md5(microtime());
                    break;
            
                case "PSWD":
                    $props["type"] = "password";
                    break;
            
                case "TEXT":
                default:
                    $props["type"] = "text";
                    break;
            }
            
            if ($metafield->format() == 'TEXT')
                return $this->html->textarea($props);
            else
                return $this->html->input($props);
        }
	}

	
}