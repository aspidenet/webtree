<?php
@require_once "common.inc.php";

$db = getDB();
    
try {
    $sql = "SELECT * FROM WEB3_Mailer
            WHERE dt_sent IS NULL
            ORDER BY status, dt_create";
    $rs = $db->Execute($sql);
    
    if ($rs->RecordCount()) {
        $row = $rs->GetRow();
        $failures = real_send_mail($row["subject"], $row["arrayto"], $row["body_text"], $row["body_html"], $row["sender"]);
            
        if (strlen($failures[0]) == 0) {
            $sql = "UPDATE WEB3_Mailer SET sent=1, dt_sent=GETDATE(), status='OK'
                    WHERE ident=?";
            $rs = $db->Execute($sql, $row["ident"]);
        }
        else {
            $sql = "UPDATE WEB3_Mailer SET status='KO'
                    WHERE ident=?";
            $rs = $db->Execute($sql, $row["ident"]);
            real_send_mail("Simnova KO", MAIL_TEST_RECEIVER, "Impossibile inviare a ".$row["arrayto"]);
        }
    }
}
catch(Exception $ex) {
    real_send_mail("Simnova KO", MAIL_TEST_RECEIVER, "Impossibile leggere le mail da inviare.");
    exit('FINE KO');
}

exit();