<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


/***********************************************************************************
 Classe HTML
***********************************************************************************/
class HTML {
	
	################################################
	# Costruttore.
	public function __construct() {
	}
	
	################################################
	# LABEL
	public function label($text) {
        echo "<label>{$text}</label>";
	}
	
	################################################
	# INPUT
	public function input($props=[]) {
    
        $icon = get("icon", "", $props);
        #------------------------------------------------------
        $placeholder = get("placeholder", "", $props);
        if (strlen($placeholder))
            $placeholder = " placeholder=\"{$placeholder}\" ";
        #------------------------------------------------------
        $required = get("required", "", $props);
        if (strlen($required))
            $required = " required ";
    
        #------------------------------------------------------
        $type = get("type", "", $props);
        if (strlen($type))
            $type = " type=\"{$type}\" ";
        else
            $type = " type=\"text\" ";
        #------------------------------------------------------
        $name = " name=\"".get("name", "", $props)."\"";
        #------------------------------------------------------
        $value = " value=\"".get("value", "", $props)."\"";
        
        if (strlen($icon))
            echo "<div class=\"ui icon input\">";
        else
            echo "<div class=\"ui input\">";
            
        echo "<input {$required} {$placeholder} {$name} {$type} {$value} />";
            
        if (strlen($icon))
            echo "<i class=\"{$icon} icon\"></i>";
        echo "</div>";
	}
	
	################################################
	# COMBOBOX
	public function combobox($props=[], $list) {
    
        $icon = get("icon", "", $props);
        #------------------------------------------------------
        $placeholder = get("placeholder", "", $props);
        if (strlen($placeholder))
            $placeholder = " placeholder=\"{$placeholder}\" ";
        #------------------------------------------------------
        $required = get("required", "", $props);
        if (strlen($required))
            $required = " required ";
    
        #------------------------------------------------------
        $name = " name=\"".get("name", "", $props)."\"";
        #------------------------------------------------------
        $value = get("value", "", $props);
        
        
        
        echo "<select class=\"ui search dropdown\" {$required} {$name}>";
        
        foreach($list as $key => $item) {
            $selected = ($key == $value) ? " selected " : "";
            
            echo "<option value=\"{$key}\" {$selected}>{$item}</option>";
            
        }
        echo "</select>";
	}
    
	################################################
	# TEXTAREA
	public function textarea($props=[]) {
    
        $icon = get("icon", "", $props);
        #------------------------------------------------------
        $placeholder = get("placeholder", "", $props);
        if (strlen($placeholder))
            $placeholder = " placeholder=\"{$placeholder}\" ";
        #------------------------------------------------------
        $required = get("required", "", $props);
        if (strlen($required))
            $required = " required ";
    
        #------------------------------------------------------
        $type = get("type", "", $props);
        if (strlen($type))
            $type = " type=\"{$type}\" ";
        else
            $type = " type=\"text\" ";
        #------------------------------------------------------
        $name = " name=\"".get("name", "", $props)."\"";
        #------------------------------------------------------
        $value = get("value", "", $props);
        
        if (strlen($icon))
            echo "<div class=\"ui icon input\">";
        else
            echo "<div class=\"ui input\">";
            
        echo "<textarea rows='2' {$required} {$placeholder} {$name}>{$value}</textarea>";
            
        if (strlen($icon))
            echo "<i class=\"{$icon} icon\"></i>";
        echo "</div>";
	}
	
}