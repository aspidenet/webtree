{extends file="template-modal-page.tpl"}

{block name="modal_actions"}
    
    <div class="ui green ok save-modal-template button">
        <i class="checkmark icon"></i> Salva
    </div>
    <div class="ui grey cancel button">
        <i class="remove icon"></i> Chiudi
    </div>
    {block name="modal_actions_custom"}
    {/block}
{/block}


{block name="modal_content"}

<script>
function returnToUrl() {
    {if $return_url|count_characters>0}
        redirect("{$return_url}");
    {/if}
}
$(document).ready(function() {
    var url = "{$APP_BASE_URL}/modal/wizard/new/{$wizard_code}/{$step}";
    
    /*$('#frmModalWizardTemplate .cancel.button').click(function(event){
        $('#modal_wizard_page').modal('hide');
    });*/
    
    $('.save-modal-template.button').click(function(event){
        console.log("modal-wizard-template: form submit #frmModalWizardTemplate");
        //return false; //stopPropagation
        $.ajax({
            type: "POST",
            url: url,
            data: $('#frmModalWizardTemplate').serialize(),
            success: function () {
                console.log("success form submit #frmModalWizardTemplate");
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
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
                        console.log(msg);
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
                        return false;
                    }
                    else if (msg.level == "WARNING") {
                        $("#frmModalWizardTemplate input[name='ignore_warning']").val('S');
                        //$("#frmModalWizardTemplate").submit();
                        $('.save-modal-template.button').click();
                    }
                    console.log('fine');
                    return false;
                });
            }
        });   
    });
    
});
</script>




<div style="margin: 0.5em 0; border: 0px solid teal;">
    Modal WIZARD Template {$APP_BASE_URL}/modal/wizard/new/{$wizard_code}/{$step}
    
    <form id="frmModalWizardTemplate" class="ui form">
        <input type="hidden" name="wizard_code" value="{$wizard_code}" />
        <input type="hidden" name="template_code" value="{$template->code()}" />
        <input type="hidden" name="action" value="new" />
        <input type="hidden" name="step" value="{$step}" />
        <input type="hidden" name="ignore_warning" value="N" />

        {* tastoni 
        <div style="margin: 0.5em 0; border: 1px solid orange;"><!-- onclick="$('#frmModalWizardTemplate').submit();" -->
            <button class="ui green button" type="submit">Salva e prosegui <i class="right arrow icon"></i></button>    
            
            <button class="ui grey button cancel" type="button"><i class="close icon"></i> Annulla</button>   
        </div>
         fine tastoni *}

        <div class="ui header center aligned">{$template->label()}</div>
        {foreach key=key item=item from=$template->getFields()}

            {$item->display("I", $values[$key])}

        {/foreach}

    </form>
</div>
{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
