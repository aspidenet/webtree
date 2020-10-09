<?php
//  
// Copyright (c) ASPIDE.NET. All rights reserved.  
// Licensed under the GPLv3 License. See LICENSE file in the project root for full license information.  
//  
// SPDX-License-Identifier: GPL-3.0-or-later
//


# FUNZIONE SENDMAIL
function web3_send_mail($subject, $arrayto, $body_text, $body_html=null, $from=null) {
    $db = getDB();
    
    if (is_array($arrayto)) {
        $to = "";
        foreach($arrayto as $key => $item) {
			if (strlen($key) > 0) {
                $to .= $key.",";
            }
		}
        if (strlen($to) > 0)
            $arrayto = substr($to, 0, -1);
    }
    
    $params = array();
    $params[] = $subject;
    $params[] = $arrayto;
    $params[] = $from;
    $params[] = $body_text;
    $params[] = $body_html;
    
    $sql = "INSERT INTO WEB3_Mailer(subject, arrayto, sender, body_text, body_html)
            VALUES(?, ?, ?, ?, ?)";
    $rs = $db->Execute($sql, $params);
    
    return ($rs === false) ? false : true;
}


# FUNZIONE REAL-SENDMAIL
function real_send_mail($subject, $arrayto, $body_text, $body_html=null, $from=null) {
    
    error_log("-------------------------------------------------------------");
    error_log($from);
    error_log(var_export($arrayto, true));
    error_log("-------------------------------------------------------------");
    
    if (!is_array($arrayto)) {
        $array = explode (',', $arrayto);
		$arrayto = array();
		foreach($array as $item) {
			if (strlen($item) > 0)
				$arrayto[] = $item;
		}
    }
		
	if (is_null($body_html)) {
		$body_html = str_replace(array('à', 'è', 'é', 'ì', 'ò', 'ù'), array('&agrave;', '&egrave;', '&eacute;', '&igrave;', '&ograve;', '&ugrave;'), $body_text);
		$body_html = nl2br($body_html);
	}

    $transport = (new Swift_SmtpTransport(MAIL_SMTP, MAIL_PORT, 'ssl'))
        ->setUsername(MAIL_USERNAME)
        ->setPassword(MAIL_PASSWD)
    ;
    // Create the Mailer using your created Transport
    $mailer = new Swift_Mailer($transport);
    
    if (is_null($from) || strlen(trim($from)) == 0)
        $from = MAIL_SENDER;
        
    if (TEST) {
        $body_text = var_export($arrayto, true)."\r\nTEST\r\n".$body_text;
        $body_html = var_export($arrayto, true)."<h1>TEST</h1>".$body_html;
        $arrayto = MAIL_TEST_RECEIVER;
        $subject = "TEST ".$subject;
    }

    // Create the message
    $message = (new Swift_Message($subject))  

        // Set the From address with an associative array
        ->setFrom($from)

        // Set the To addresses with an associative array
        ->setTo($arrayto)

        // Set the Bcc addresses with an associative array
        ->setBcc(MAIL_BCC)
        
        // Set ReplayTo
        ->setReplyTo(MAIL_SENDER)

        // Give it a body
        ->setBody($body_text)

        // And optionally an alternative body
        ->addPart($body_html, 'text/html')

        // Optionally add any attachments
        //->attach(Swift_Attachment::fromPath('my-document.pdf'))
    ;
    
    try {
        // Send the message
        $result = $mailer->send($message, $failures);
        return $failures;
    }
    catch(Exception $ex) {
        error_log("Mail fallita.... Amen.");
    }
    return false;
}