<div style="text-align:right;">
    <div class="ui green save-template button">
        Salva <i class="save icon"></i>
    </div>
    {*<div class="ui grey cancel button">
        <i class="remove icon"></i> Chiudi
    </div>*}
</div>



<script>
function returnToUrl() {
    {if $return_url|count_characters>0}
        redirect("{$return_url}");
    {/if}
}
$(document).ready(function() {
    var url = "{$APP_BASE_URL}/modal/template/{$template->code()}/update/{$record_code}";
    
    /*$('#frmModalWizardTemplate .cancel.button').click(function(event){
        $('#modal_wizard_page').modal('hide');
    });*/
    
    $('.save-template.button').click(function(event){
        console.log("form submit #frmAdminWebonlineTemplate");
        //return false; //stopPropagation
        $.ajax({
            type: "POST",
            url: url,
            data: $('#frmAdminWebonlineTemplate').serialize(),
            success: function () {
                console.log("success form submit #frmAdminWebonlineTemplate");
            }
        })
        .done(function( data ) {
            console.log("Response form submit #frmAdminWebonlineTemplate");
            console.log(data);
            
            if (data.trim() == 'OK') {
                modal_popup_url(url, returnToUrl);
                //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
                //ShowMessage(msg, false, function() { window.location = ""; });
            }
            else if (data.trim() == 'KO') {
                var msg = JSON.parse('{ "description":"Errore non specificato." }');
                ShowMessage(msg, false);
            }
            else {
                var msg = JSON.parse(data.trim());
                console.log(msg);
                ShowMessage(msg, false, function() { 
                    if (msg.level == "INFO") {
                        /*if (msg.customs) {
                            if (msg.customs.url) {
                                console.log('di qui ci passo '+msg.customs.url);
                                //modal_popup_url(url, function() { window.location = msg.customs.url; });
                                //ShowMessage(msg, false, function() { window.location = msg.customs.url; });
                                //window.location = msg.customs.url;
                                redirect(msg.customs.url);
                            }
                            else if (msg.customs.finish) {
                                $('#modal_wizard_page').modal('hide');
                            }
                        }
                        else
                            modal_popup_url(url, returnToUrl);*/
                        return true;
                    }
                    else if (msg.level == "WARNING") {
                        $("#frmAdminWebonlineTemplate input[name='ignore_warning']").val('S');
                        $("#frmAdminWebonlineTemplate").submit();
                    }
                    console.log('fine done .save-modal-template.button');
                });
            }
        });   
    });
    
});
</script>

{$APP_BASE_URL}/modal/template/{$template->code()}/update/{$record_code}

<form id="frmAdminWebonlineTemplate" class="ui form">
    <input type="hidden" name="template_code" value="{$template->code()}" />
    <input type="hidden" name="action" value="update" />
    <input type="hidden" name="ignore_warning" value="N" />
    <input type="hidden" name="code" value="{$record_code}" />

    <div class="ui header center aligned">{$template->label()}</div>
    {foreach key=key item=item from=$template->getFields()}
        {$item->display("I", $record[$item->dbfield()])}
    {foreachelse}
    <div>Template sconosciuto, nessun campo inserito.</div>
    {/foreach}

</form>