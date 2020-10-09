{extends file="template-modal.tpl"}

{block name="html_head_extra"}
<link href="{$STATIC_URL}/assets/library/tabulator.min.css" rel="stylesheet" />
<!--link href="{$STATIC_URL}/assets/library/tabulator_semantic-ui.min.css" rel="stylesheet" /-->
<!--link href="{$STATIC_URL}/assets/library/tabulator_bootstrap.min.css" rel="stylesheet" /-->

<script src="{$STATIC_URL}/assets/library/jquery-ui.min.js"></script>
<script src="{$STATIC_URL}/assets/library/tabulator.min.js"></script>
<script src="{$STATIC_URL}/assets/library/xlsx.full.min.js"></script>

{/block}
    
{block name="content"}

<script>
function returnToUrl() {
    {if $wizard->getReturnUrl()|count_characters>0}
        redirect("{$wizard->getReturnUrl()}");
    {/if}
}
$(document).ready(function() {
    var url = "{$APP_BASE_URL}/wizard/{$wizard_code}/{$action}/{$record_code}";
    
    $('#frmTemplate .cancel.button').click(function(event){
        $('#modal_wizard_page').modal('hide');
    });
    
    $('#frmTemplate').submit(function(event){
        event.preventDefault();
        console.log("form submit #frmTemplate");
        //return; stopPropagation
        $.ajax({
            type: "POST",
            url: url,
            data: $('#frmTemplate').serialize(),
            success: function () {
                console.log("success");
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
            if (data == 'OK') {
                modal_popup_url(url, returnToUrl);
                //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
                //ShowMessage(msg, false, function() { window.location = ""; });
            }
            else if (data == 'KO') {
                var msg = JSON.parse('{ "description":"Errore non specificato." }');
                ShowMessage(msg, false);
            }
            else {
                var msg = JSON.parse(data);
                ShowMessage(msg, false, function() { 
                    if (msg.level == "INFO") {
                        console.log(msg);
                        if (msg.customs) {
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
                            modal_popup_url(url, returnToUrl);
                    }
                    else if (msg.level == "WARNING") {
                        $("#frmTemplate input[name='ignore_warning']").val('S');
                        $("#frmTemplate").submit();
                    }
                });
            }
        });   
        
    });
});
</script>




<div style="margin: 0.5em 0; border: 0px solid teal;">
{$APP_BASE_URL}/wizard/{$wizard_code}/{$action}/{$record_code}
    
    <form id="frmTemplate" class="ui form">
        <input type="hidden" name="template_code" value="{$template->code()}" />
        <input type="hidden" name="ignore_warning" value="N" />

        {* tastoni *}
        <div style="margin: 0.5em 0; border: 1px solid orange;"><!-- onclick="$('#frmTemplate').submit();" -->
            <button class="ui green button" type="submit">Salva e prosegui <i class="right arrow icon"></i></button>    
            
            <button class="ui grey button cancel" type="button"><i class="close icon"></i> Annulla</button>   
            
            {*<button class="ui red button delete" type="button"><i class="erase icon"></i> Elimina</button>*}
        </div>
        {* fine tastoni *}

        <div class="ui header center aligned">{$template->label()}</div>
        {foreach key=key item=item from=$fields}

            {$item->display("I", $values[$key])}

        {/foreach}

    </form>
</div>
{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
