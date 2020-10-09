{extends file="template-modal.tpl"}

{block name="html_head_extra"}
{/block}
    
{block name="content"}

<script>
$(document).ready(function() {
    
    $('#frmWizard').submit(function(event){
    
        event.preventDefault();
        console.log("form submit");
        //return;
        $.ajax({
            type: "POST",
            url: "{$APP_BASE_URL}/wizard/{$wizard_code}/save",
            data: $('#frmWizard').serialize(),
            success: function () {
                console.log("success");
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
            if (data == 'OK') {
                window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
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
                    console.log("--------------------------------------- ok");
                    if (msg.customs) {
                        if (msg.customs.url)
                            redirect(msg.customs.url);
                    }
                    else {
                        console.log("altrimenti.... mi arrabbio!");
                        if (msg.result) {
                            $('#modal_wizard_page').modal('hide');
                            return true;    
                        }
                        /*if (msg.level == "INFO") {
                            console.log("------- on ok -------");
                            var parent_id = $("#modal{$id}container").parent().attr('id');
                            console.log(parent_id);
                            console.log("{$id}");
                            modal_page_close(parent_id);
                            return true; // chiudi messaggio
                        }*/
                    }
                });
            }
        });   
        
    });
    
    
    
    $('#frmWizard .cancel.button').click(function(event){
    
        event.preventDefault();
        
        $.ajax({
            type: "POST",
            url: "{$APP_BASE_URL}/wizard/{$wizard_code}/cancel",
            data: $('#frmWizard').serialize(),
            success: function () {
                console.log("success");
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
            if (data == 'OK') {
                //window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
                //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
                //ShowMessage(msg, false, function() { window.location = ""; });
                $('#modal_wizard_page').modal('hide');
            }
            else if (data == 'KO') {
                var msg = JSON.parse('{ "description":"Errore non specificato." }');
                ShowMessage(msg, false);
            }
            else {
                var msg = JSON.parse(data);
                ShowMessage(msg, false, function() { 
                    //window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
                    console.log('Provo a fare hide:');
                    $('#modal_wizard_page').modal('hide');
                });
            }
        });   
        
    });
});
</script>




<div style="margin: 0.5em 0; border: 1px solid teal;">

    <form id="frmWizard" class="ui form">
        <input type="hidden" name="wizard_code" value="{$wizard_code}" />
        
        <div class="ui header center aligned">Vuoi salvare?</div>
        
        {* tastoni *}
        <div style="margin: 0.5em 0; border: 1px solid orange;">
            <button class="ui green button" type="submit">Conferma <i class="right arrow icon"></i></button>    
            <button class="ui cancel button" type="button">Annulla <i class="icon"></i></button>    
        </div>
        {* fine tastoni *}
    </form>
    
</div>
{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
