<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


GLOBAL $enabled_tables;
$enabled_tables = array(
    "MetaClassTypes",
    "MetaClassLevels",	
    "MetaClassNodes",	
    // #// "MetaClassTypeAddFields",	
    // #// "MetaClassNodeAddFields",	
    // #// "MetaClassTemplates",
    // "Procedures",	
    // "Params",
    // "MetaWizards",	
    // "MetaTemplates",
    // "MetaFields",	
    // "MetaRelations",
    // #// "Rules",
    // #// "RuleDetails",	
    // #// "MetaVoci",
    "Recordsets",
    "RecordsetColumns",
    // #// "Registries",
    // "Users",
    // "Groups",
    // "RelUserGroup",
    // "RelUserRegistry",
    // "Menus",
    // "Visibilities",
    // "Profiles",
    // "Modules",
    // "Roles"
);

#
# ALL
#
$this->respond(array('GET', 'POST'), '*', function ($request, $response, $service, $app) {
    $session = getSession();
    
    if ($session->checkLogin() === false) {
        $session->assertBearer();
    }
});

#
# INDEX
#

$this->respond('GET', '/?', function ($request, $response, $service, $app) {
    echo "SYS INDEX";
});

#
# MD5
#

$this->respond('GET', '/md5/[:text]', function ($request, $response, $service, $app) {
    echo "MD5: ".md5($request->text);
});



#
# SYNC TABLES INDEX
#

$this->respond('GET', '/sync/tables/?', function ($request, $response, $service, $app) {
    GLOBAL $enabled_tables;
    $session = getSession();
    $db = getDb();
    // echo "SYNC INDEX";
    // print_r($enabled_tables);exit('FINE');
    $differenze = array();
    
    foreach($enabled_tables as $table) {
        $source_table = array();
        $target_table = array();
        
        $differenze[$table] = array();
    
        // echo "<br>======================================================================<br>";
        // echo $table."<br>";
        // echo "======================================================================<br>";
                
        # PK
        $sql = "sp_pkeys '{$table}'";
        $rs = $db->Execute($sql, array());
        $pk = array();
        if ($rs && $rs->RecordCount()) {
            while (!$rs->EOF) {
                $pk[] = $rs->get("COLUMN_NAME");
                $rs->MoveNext();
            }
            // $primary_keys[$table] = $rs->get("COLUMN_NAME");
            // echo "primary_key: ".$primary_keys[$table]."<br><br>";
        }
        // else
            // DEBUG($sql." -> false");
        // print_r($pk);
        // echo "<br><br>";
        
        
        
        $token = openssl_cipher(date("Ymd").$session->user()->username());
        $authorization = "Authorization: Bearer {$token}";

        # Sorgente
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, SYNC_URL."/sys/sync/json/tables/{$table}");
        curl_setopt($ch, CURLOPT_HTTPHEADER, array($authorization));
        curl_setopt($ch, CURLOPT_HEADER, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_VERBOSE, 1);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
        // if (strlen(PROXY))
            // curl_setopt($ch, CURLOPT_PROXY, PROXY);
        $output = curl_exec($ch);
        curl_close($ch); 
        
        //echo $output."<br><br>";
        
        $result = json_decode($output, true);
        foreach ($result as $item) {
            $pkstring = "";
            foreach($pk as $k) {
                $pkstring .= $item[$k].'+';
            }
            $pkstring = substr($pkstring, 0, -1);
            if (isset($item['ident']))
                unset($item['ident']);
            $source_table[$pkstring] = $item;
        }
        
        
        # Destinazione
        $sql = "SELECT * FROM {$table}";
        $rs = $db->Execute($sql, array());
        if ($rs && $rs->RecordCount()) {
            $result = $rs->GetArray();
            foreach ($result as $item) {
                $pkstring = "";
                foreach($pk as $k) {
                    $pkstring .= $item[$k].'+';
                }
                $pkstring = substr($pkstring, 0, -1);
                if (isset($item['ident']))
                    unset($item['ident']);
                $target_table[$pkstring] = $item;
            }
        }
        // else
            // DEBUG($sql." -> false");
        
        
        # Differenze
        foreach ($source_table as $key =>$item) {
            foreach($item as $col => $source_val) {
                if (!isset($target_table[$key])) {
                    $differenze[$table][$key]['new'] = $item;
                    $differenze[$table][$key]['old'] = array();
                    continue;
                }
                $target_val = $target_table[$key][$col];
                if ($source_val != $target_val) {
                    $differenze[$table][$key]['new'][$col] = $source_val;
                    $differenze[$table][$key]['old'][$col] = $target_val;
                }
            }
        }
        foreach ($target_table as $key =>$item) {
            foreach($item as $col => $target_val) {
                if (!isset($source_table[$key])) {
                    $differenze[$table][$key]['old'] = $item;
                    $differenze[$table][$key]['new'] = array();
                    continue;
                }
            }
        }
        
    }
    
        // echo "<hr>";
        // print_r($differenze);
        // echo "<br><br>";
        
    $session->smarty()->assign("differenze", $differenze);
    $session->smarty()->display("sys-sync-index.tpl");
});





#
# SYNC VIEWS STORED FUNCTIONS INDEX
#

$this->respond('GET', '/sync/objects/?[:db]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDb();
    $objects = array();
    $dbname = $request->db;
    
    $sql = "select name, type, type_desc from {$dbname}.sys.objects
            where type in ('P', 'V', 'IF', 'FN', 'TF')
            order by type";
    $rs = $db->Execute($sql, array());
    if ($rs)
        $objects = $rs->GetArray();
    
    $session->smarty()->assign("dbname", $dbname);
    $session->smarty()->assign("objects", $objects);
    $session->smarty()->display("sys-sync-objects-index.tpl");
    /*foreach($objects as $object) {
        $object_name = $object["name"];
        
        
        
        # Sorgente
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, SYNC_URL."/sys/sync/json/tables/{$table}");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $output = curl_exec($ch);
        curl_close($ch); 
        
        #echo $output."<br><br>";
        
        $result = json_decode($output, true);
        foreach ($result as $item) {
            $pkstring = "";
            foreach($pk as $k) {
                $pkstring .= $item[$k];
            }
            $source_table[$pkstring] = $item;
        }
        // echo "<hr>";
        // print_r($source_table);
        // echo "<br><br>";
        
        
        # Destinazione
        $sql = "SELECT * FROM {$table}";
        $rs = $db->Execute($sql, array());
        if ($rs && $rs->RecordCount()) {
            $result = $rs->GetArray();
            foreach ($result as $item) {
                $pkstring = "";
                foreach($pk as $k) {
                    $pkstring .= $item[$k];
                }
                $target_table[$pkstring] = $item;
            }
            // echo "<hr>";
            // print_r($target_table);
            // echo "<br><br>";
        }
        else
            DEBUG($sql." -> false");
        
    }
    
    
    foreach($enabled_tables as $table) {
        $source_table = array();
        $target_table = array();
        
        $differenze[$table] = array();
    
        // echo "<br>======================================================================<br>";
        // echo $table."<br>";
        // echo "======================================================================<br>";
                
        # PK
        $sql = "sp_pkeys '{$table}'";
        $rs = $db->Execute($sql, array());
        $pk = array();
        if ($rs && $rs->RecordCount()) {
            while (!$rs->EOF) {
                $pk[] = $rs->get("COLUMN_NAME");
                $rs->MoveNext();
            }
            // $primary_keys[$table] = $rs->get("COLUMN_NAME");
            // echo "primary_key: ".$primary_keys[$table]."<br><br>";
        }
        else
            DEBUG($sql." -> false");
        // print_r($pk);
        // echo "<br><br>";
        
        # Sorgente
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, SYNC_URL."/sys/sync/json/tables/{$table}");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $output = curl_exec($ch);
        curl_close($ch); 
        
        #echo $output."<br><br>";
        
        $result = json_decode($output, true);
        foreach ($result as $item) {
            $pkstring = "";
            foreach($pk as $k) {
                $pkstring .= $item[$k];
            }
            $source_table[$pkstring] = $item;
        }
        // echo "<hr>";
        // print_r($source_table);
        // echo "<br><br>";
        
        
        # Destinazione
        $sql = "SELECT * FROM {$table}";
        $rs = $db->Execute($sql, array());
        if ($rs && $rs->RecordCount()) {
            $result = $rs->GetArray();
            foreach ($result as $item) {
                $pkstring = "";
                foreach($pk as $k) {
                    $pkstring .= $item[$k];
                }
                $target_table[$pkstring] = $item;
            }
            // echo "<hr>";
            // print_r($target_table);
            // echo "<br><br>";
        }
        else
            DEBUG($sql." -> false");
        
        
        # Differenze
        foreach ($source_table as $key =>$item) {
            
            foreach($item as $col => $source_val) {
                if (!isset($target_table[$key])) {
                    $differenze[$table][$key]['new'] = $item;
                    $differenze[$table][$key]['old'] = array();
                    continue;
                }
                $target_val = $target_table[$key][$col];
                if ($source_val != $target_val) {
                    $differenze[$table][$key]['new'][$col] = $source_val;
                    $differenze[$table][$key]['old'][$col] = $target_val;
                }
            }
        }
        foreach ($target_table as $key =>$item) {
            
            foreach($item as $col => $target_val) {
                if (!isset($source_table[$key])) {
                    $differenze[$table][$key]['old'] = $item;
                    $differenze[$table][$key]['new'] = array();
                    continue;
                }
            }
        }
        
    }
    
        // echo "<hr>";
        // print_r($differenze);
        // echo "<br><br>";
    */
    
});

$this->respond('POST', '/sync/objects/?[:object_name]?', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDb();
    $objects = array();
    $object_name = $request->object_name;
    
    # Target
    $a = explode(".", $object_name);
    if (count($a) == 2) {
        $sql = "{$a[0]}.dbo.sp_helptext ?";
        $rs = $db->Execute($sql, array($a[1]));
    }
    else {
        $sql = "sp_helptext ?";
        $rs = $db->Execute($sql, array($object_name));
    }
    #$target = $rs->GetArray();
    while(!$rs->EOF) {
        $row = $rs->GetRow();
        if (strlen(trim($row["text"])) > 0)
            $target[] = $row;
    }
    #print_r($target);
    $_SESSION["SYNC"][$object_name]["TARGET"] = $target;
    
    
    $token = openssl_cipher(date("Ymd").$session->user()->username());
    $authorization = "Authorization: Bearer {$token}";

    # Source
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, SYNC_URL."/sys/sync/json/objects/{$object_name}");
    curl_setopt($ch, CURLOPT_HTTPHEADER, array($authorization));
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_VERBOSE, 1);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
    // if (strlen(PROXY))
        // curl_setopt($ch, CURLOPT_PROXY, PROXY);
    $output = curl_exec($ch);
    curl_close($ch); 
    
    #
    
    // $session->log($output);
    // echo "OUTPUT:<br>";
    // echo $output."<br><br>";
    
    $result = json_decode($output, true);
    foreach($result as $row) {
        if (strlen(trim($row["text"])) > 0)
            $source[] = $row;
    }
    $_SESSION["SYNC"][$object_name]["SOURCE"] = $source;
    #$session->log($output);
    // echo "SOURCE:<br>";
    // print_r($source);
    
    // exit();
    foreach($target as $key => $item) {
        $source_text = $source[$key]["text"];
        $target_text = $target[$key]["text"];
        if (strcasecmp(trim($source_text), trim($target_text)) != 0) {
            $session->log($source_text);
            $session->log($target_text);
            exit("KO");
        }
    }
    
    foreach($source as $key => $item) {
        $source_text = $source[$key]["text"];
        $target_text = $target[$key]["text"];
        if (strcasecmp(trim($source_text), trim($target_text)) != 0) {
            $session->log($source_text);
            $session->log($target_text);
            exit("KO");
        }
    }
    
    exit('OK'); 
});



#
# SYNC VIEWS STORED FUNCTIONS INDEX
#

$this->respond('GET', '/sync/objects/diff/[:object_name]', function ($request, $response, $service, $app) {
    $session = getSession();
    $db = getDb();
    $differences = array();
    $object_name = $request->object_name;
    $dbname = "web3";
    
    $a = explode(".", $object_name);
    if (count($a) == 2) {
        $dbname = $a[0];
    }
    
    $target = $_SESSION["SYNC"][$object_name]["TARGET"];
    $source = $_SESSION["SYNC"][$object_name]["SOURCE"];
    
    $i=0;
    foreach($target as $key => $item) {
        $source_text = $source[$key]["text"];
        $target_text = $target[$key]["text"];
        $differences[$i] = array(
            "source" => $source_text,
            "target" => $target_text,
            "diff" => (trim($source_text) != trim($target_text)) ? true : false
        );
        $i++;
    }
    
    foreach($source as $key => $item) {
        $source_text = $source[$key]["text"];
        $target_text = $target[$key]["text"];
        $differences[$i] = array(
            "source" => $source_text,
            "target" => $target_text,
            "diff" => (trim($source_text) != trim($target_text)) ? true : false
        );
        $i++;
    }
    $session->smarty()->assign("hashing", md5(microtime()));
    $session->smarty()->assign("dbname", $dbname);
    $session->smarty()->assign("object_name", $object_name);
    $session->smarty()->assign("differences", $differences);
    $session->smarty()->display("sys-sync-objects-modal-diff.tpl");
});


#
#
#
# JSON SYNC TABLES CONFIG
#
#
#

$this->respond('GET', '/sync/json/tables/[:table]', function ($request, $response, $service, $app) {
    GLOBAL $enabled_tables;
    $session = getSession();
    $db = getDb();
    $table = $request->table;
    
    
    if (!in_array($table, $enabled_tables))
        exit("KO");
    
    $sql = "SELECT * FROM {$table}";
    $rs = $db->Execute($sql, array());
    
    echo_json($rs->GetArray());
});
# JSON SYNC TABLES CONFIG - SINGLE KEY
$this->respond('GET', '/sync/json/tables/[:table]/[:key]', function ($request, $response, $service, $app) {
    GLOBAL $enabled_tables;
    $session = getSession();
    $db = getDb();
    $table = $request->table;
    $key = $request->key;
    
    if (!in_array($table, $enabled_tables))
        exit("KO");
    
    # Leggiamo le chiavi della tabella
    $sql = "sp_pkeys '{$table}'";
    $rs = $db->Execute($sql, array());
    $pk = array();
    $pk_string = "";
    if ($rs && $rs->RecordCount()) {
        while (!$rs->EOF) {
            $colname = $rs->get("COLUMN_NAME");
            $pk[] = $colname;
            $pk_string .= " AND {$colname}=? ";
            $rs->MoveNext();
        }
        // $primary_keys[$table] = $rs->get("COLUMN_NAME");
        // echo "primary_key: ".$primary_keys[$table]."<br><br>";
    }
    
    $keys = explode('+', $key);
    if (!is_array($keys))
        $keys = array($keys);
    
    $sql = "SELECT * FROM {$table} WHERE 1=1 {$pk_string}";
    $rs = $db->Execute($sql, $keys);
    
    echo_json($rs->GetArray());
});


#
#
#
# JSON SYNC VIEWS STORED FUNCTIONS
#
#
#

$this->respond('GET', '/sync/json/objects/[:object_name]', function ($request, $response, $service, $app) {
    GLOBAL $enabled_tables;
    $session = getSession();
    $db = getDb();
    $object_name = $request->object_name;
    
    
    // if (!in_array($table, $enabled_tables))
        // exit("KO");
    $a = explode(".", $object_name);
    if (count($a) == 2) {
        $sql = "{$a[0]}.dbo.sp_helptext ?";
        $rs = $db->Execute($sql, array($a[1]));
    }
    else {
        $sql = "sp_helptext ?";
        $rs = $db->Execute($sql, array($object_name));
    }
    
    echo_json($rs->GetArray());
});


#
#
#
# SYNC IMPORT TABLES RECORD
#
#
#

$this->respond('GET', '/sync/import/tables/[:table]/[:key]', function ($request, $response, $service, $app) {
    GLOBAL $enabled_tables;
    $session = getSession();
    $db = getDb();
    $table = $request->table;
    $key = $request->key;
    $session->log("IMPORT: $table $key");
    
    if (!in_array($table, $enabled_tables))
        exit("KO");
    
    $token = openssl_cipher(date("Ymd").$session->user()->username());
    $authorization = "Authorization: Bearer {$token}";

    # Sorgente
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, SYNC_URL."/sys/sync/json/tables/{$table}/{$key}");
    curl_setopt($ch, CURLOPT_HTTPHEADER, array($authorization));
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_VERBOSE, 1);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
    // if (strlen(PROXY))
        // curl_setopt($ch, CURLOPT_PROXY, PROXY);
    $output = curl_exec($ch);
    curl_close($ch); 
    
    //echo $output."<br><br>";
    #$session->log($output);
    
    $results = json_decode($output, true);
    $record = new Base();
    
    if (count($results) == 0)
        exit("KO");
    
    # Lo trasformo in Record Base
    foreach($results[0] as $k => $val) {
        $record->set($k, $val);
    }
    
    $manager = new TableManager($table);
    try {
        $session->log($record);
        $manager->insert($record);
    }
    catch(Excepion $ex) {
        exit("KO");
    }
    exit("OK");
});


#
# Generazione DB base
#
$this->respond('GET', "/gensql", function ($request, $response, $service, $app) {
    $db = getDB();
    $session = getSession();
    
    $db->StartTrans();
    
    #
    # WIZARD
    #
    echo "Generazione wizard \"Templates\"<br>";
    $sql = "INSERT INTO MetaWizards (
                wizard_code
               ,label0
               ,dbview
               ,template_code
               ,note
               ,class)
            VALUES (
                'SYSTEMPLATES'
               ,'Wizard templates'
               ,'MetaTemplates'
               ,'SYSTEMPLATE'
               ,null
               ,null
            )";
    #$db->Execute($sql);
    
    
    #
    # TEMPLATE TEMPLATE
    #
    echo "Generazione template \"Template\"<br>";
    $sql = "INSERT INTO MetaTemplates (
                template_code
               ,label0
               ,dbtable
               ,dbview
               ,dbkey
               ,dblabel
               ,icon
               ,note
               ,class)
            VALUES (
                'SYSTEMPLATE'
               ,'SYS Template'
               ,'MetaTemplates'
               ,'MetaTemplates'
               ,'template_code'
               ,'label0'
               ,null
               ,null
               ,null
            )";
    #$db->Execute($sql);
    
    #
    # FIELDS di TEMPLATE
    #
    echo "Generazione fields \"Template\"<br>";
    
    # template_code
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_TEMPLATE_CODE','SYSTEMPLATE','template_code','Codice template',1,'TEXT','S','S','S','S','S','N',null,null,null)";
    #$db->Execute($sql);
    
    # label0
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_LABEL0','SYSTEMPLATE','label0','Etichetta del template',2,'TEXT','S','S','S','S','S','S',null,null,null)";
    #$db->Execute($sql);
    
    # dbtable
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_DBTABLE','SYSTEMPLATE','dbtable','Tabella sul DB',3,'TEXT','S','S','S','S','S','S',null,null,null)";
    #$db->Execute($sql);
    
    # dbview
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_DBVIEW','SYSTEMPLATE','dbview','Vista',4,'TEXT','S','S','S','S','S','S',null,null,null)";
    #$db->Execute($sql);
    
    # dbkey
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_DBKEY','SYSTEMPLATE','dbkey','Chiave sul DB',5,'TEXT','S','S','S','S','S','S',null,null,null)";
    #$db->Execute($sql);
    
    # dblabel
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_DBLABEL','SYSTEMPLATE','dblabel','Etichetta del campo sul DB',6,'TEXT','S','N','S','S','N','S',null,null,null)";
    #$db->Execute($sql);
    
    # icon
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_ICON','SYSTEMPLATE','icon','Icona',7,'TEXT','S','N','S','S','N','S',null,null,null)";
    #$db->Execute($sql);
    
    # note
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_NOTE','SYSTEMPLATE','note','Note',8,'TEXT','S','N','S','S','N','S',null,null,null)";
    #$db->Execute($sql);
    
    # class
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSTEMPLATE_CLASS','SYSTEMPLATE','class','PHP Class',9,'TEXT','S','N','S','S','N','S',null,null,null)";
    #$db->Execute($sql);
    
    
    #
    # TEMPLATE FIELDS
    #
    echo "Generazione template \"Fields\"<br>";
    $sql = "INSERT INTO MetaTemplates (
                template_code
               ,label0
               ,dbtable
               ,dbview
               ,dbkey
               ,dblabel
               ,icon
               ,note
               ,class)
            VALUES (
                'SYSFIELDS'
               ,'SYS Fields'
               ,'MetaFields'
               ,'MetaFields'
               ,'field_code'
               ,'label0'
               ,null
               ,null
               ,null
            )";
    #$db->Execute($sql);
    
    
    #
    # FIELDS di FIELDS
    #
    echo "Generazione fields \"Template\"<br>";
    
    # field_code
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FIELD_CODE','SYSFIELDS','field_code','Codice del campo',1,'TEXT','S','S','S','S','S','N',null,null,null)";
    $db->Execute($sql);
    
    # template_code
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_TEMPLATE_CODE','SYSFIELDS','template_code','Codice template',2,'TEXT','S','S','S','S','S','N',null,null,null)";
    $db->Execute($sql);
    
    # label0
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_LABEL0','SYSFIELDS','label0','Etichetta del campo',3,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # dbfield
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_DBFIELD','SYSFIELDS','dbfield','Campo corrispondente sul DB',4,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # sorting
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_SORTING','SYSFIELDS','sorting','Ordine',5,'INT','S','N','S','S','N','S',null,null,null)";
    $db->Execute($sql);
    
    # format_code
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FORMAT_CODE','SYSFIELDS','format_code','Formato',6,'TEXT','S','N','S','S','N','S',null,null,null)";
    $db->Execute($sql);
    
    # flag_ins_visible
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FLAG_INS_VISIBLE','SYSFIELDS','flag_ins_visible','Flag visibile - Insert',6,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # flag_ins_mandatory
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FLAG_INS_MANDATORY','SYSFIELDS','flag_ins_mandatory','Flag obbligatorio - Insert',6,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # flag_ins_modifiable
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FLAG_INS_MODIFIABLE','SYSFIELDS','flag_ins_modifiable','Flag modificabile - Insert',6,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # flag_upd_visible
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FLAG_UPD_VISIBLE','SYSFIELDS','flag_upd_visible','Flag visibile - Update',6,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # flag_upd_mandatory
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FLAG_UPD_MANDATORY','SYSFIELDS','flag_upd_mandatory','Flag obbligatorio - Update',6,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # flag_upd_modifiable
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_FLAG_UPD_MODIFIABLE','SYSFIELDS','flag_upd_modifiable','Flag modificabile - Update',6,'TEXT','S','S','S','S','S','S',null,null,null)";
    $db->Execute($sql);
    
    # list_code
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_LIST_CODE','SYSFIELDS','list_code','',7,'TEXT','S','N','S','S','N','S',null,null,null)";
    $db->Execute($sql);
    
    # note
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_NOTE','SYSFIELDS','note','Note',8,'TEXT','S','N','S','S','N','S',null,null,null)";
    $db->Execute($sql);
    
    # class
    $sql = "INSERT INTO MetaFields (
                field_code,template_code,dbfield,label0,sorting,format_code,flag_ins_visible,flag_ins_mandatory,flag_ins_modifiable,flag_upd_visible,flag_upd_mandatory,flag_upd_modifiable,list_code,note,class)
            VALUES (
                'SYSFIELDS_CLASS','SYSFIELDS','class','PHP Class',9,'TEXT','S','N','S','S','N','S',null,null,null)";
    $db->Execute($sql);
    
    
    #
    # FIELDS di FIELDS
    #
    echo "Generazione fields \"Template\"<br>";
    
    # field_code
    $sql = "INSERT INTO MetaRelations
               (relation_code
               ,master_code
               ,slave_code
               ,label0
               ,sorting
               ,dbview
               ,dbtable
               ,flag_ins_visible
               ,flag_ins_mandatory
               ,flag_ins_modifiable
               ,flag_upd_visible
               ,flag_upd_mandatory
               ,flag_upd_modifiable
               ,cardinality_min
               ,cardinality_max
               ,flag_active
               ,note
               ,class)
            VALUES
               ('SYSTEMPLATE-FIELDS'
               ,'SYSTEMPLATE'
               ,'SYSFIELDS'
               ,'Template-Fields'
               ,1
               ,'MetaFields'
               ,'MetaFields'
               ,'S'
               ,'S'
               ,'S'
               ,'S'
               ,'S'
               ,'S'
               ,1
               ,1000
               ,'S'
               ,null
               ,null)";
    $db->Execute($sql);
    
    
    
    
    /*
    
    */
    
    # FINE
    $db->CompleteTrans();
    echo "Fine";
    exit();
});