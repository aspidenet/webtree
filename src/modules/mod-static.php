<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


#
# ALL
#
$this->respond(array('GET', 'POST'), '*', function ($request, $response, $service, $app) {
    $session = getSession();
});



#
#
#
# STATIC
#
#
#

$this->respond('GET', '/[a:custom_code]/[**:filename]', function ($request, $response, $service, $app) {
    $session = getSession();
    $custom_code = $request->custom_code;
    $filename = $request->filename;
    
    if ($custom_code != "default") 
        $filename = BASE_DIR."/../web3-{$custom_code}/static/".$filename;
    else
        $filename = BASE_DIR."/html/static-default/".$filename;
    error_log("GET ".$custom_code."/".$filename);

    
    //header('Content-Type: application/octet-stream');
    //header("Content-Disposition: attachment; filename=\"" . basename($filename) . "\"");
    #readfile($filename);
    
    
    if (file_exists($filename)) {
        $path_parts = pathinfo($filename);
        switch($path_parts['extension']) {
            case 'js':
                $mime = "application/javascript";
                break;
            
            case 'css':
                $mime = "text/css";
                break;
            
            case 'png':
                $mime = "image/png";
                break;
            
            case 'jpg':
            case 'jpeg':
                $mime = "image/jpeg";
                break;
            
            case 'bmp':
                $mime = "image/bmp";
                break;
            
            case 'ico':
                $mime = "image/x-icon";
                break;
                
            case 'ttf':
                $mime = "font/ttf";
                break; 
                
            case 'woff':
                $mime = "font/woff";
                break;  
                
            case 'woff2':
                $mime = "font/woff2";
                break;    
            
            default:
                $mime = mime_content_type($filename);
                break;
        }


        $seconds_to_cache = 3600;
        $ts = gmdate("D, d M Y H:i:s", time() + $seconds_to_cache) . " GMT";



        ob_clean();
        header('Content-Description: File Transfer');
        header("Content-Type: {$mime}");
        header('Content-Disposition: attachment; filename="'.basename($filename).'"');
        header('Content-Length: ' . filesize($filename));
        // header('Expires: 0');
        // header('Cache-Control: must-revalidate');
        // header('Pragma: public');
        header("Expires: $ts");
        header("Pragma: cache");
        header("Cache-Control: max-age=$seconds_to_cache");
        readfile($filename);
    }
    else {
        $session->log("404 NOT FOUND! ".$filename);
        #http_response_code(404);
        $protocol = (isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0');
        header($protocol . ' 404 Not Found');
    }
    exit();
});