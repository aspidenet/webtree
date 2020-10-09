{extends file="template-modal-page.tpl"}


{block name="modal_actions_footer"}
{if $action == 'new'}
<button class="ui green button" onclick="modal_wizard_add_object_ok();" title="Conferma i dati inseriti">
    <i class="plus icon"></i> OK
</button> 
{/if}
{if $action == 'remove'}
<button class="ui red button">
    <i class="remove icon"></i> Elimina
</button>   
{/if}
<button class="ui grey cancel button">
    <i class="close icon"></i> Chiudi
</button>  
{/block}

{block name="modal_content"}

<script>
//var modal_relation_selected_{$hashing} = null;

$(document).ready(function() {
});


function modal_wizard_add_object_ok() { 
    
    $.ajax({
        type: "POST",
        url: "{$REQUEST->uri()}",
        data: $('#frmModalWizardAddObject').serialize(),
        success: function () {
            console.log("modal_wizard_add_object_ok success");
        }
    })
    .done(function( data ) {
        console.log(data);
        //return false;
        if (data.trim() == 'OK') {
            
        }
        else if (data.trim() == 'KO') {
            var msg = JSON.parse('{ "description":"Errore non specificato." }');
            ShowMessage(msg, false);
        }
        else {
            var msg = JSON.parse(data);
            ShowMessage(msg, false, function() { 
                if (msg.level == "INFO") {
                    console.log("------- on ok -------");
                    var parent_id = $("#modal{$id}container").parent().attr('id');
                    console.log(parent_id);
                    console.log("{$id}");
                    modal_page_close(parent_id);
                    return true; // chiudi messaggio
                }
            });
        }
    });   
}

</script>



modal-wizard-add-object {$REQUEST->uri()} ModalID: {$id}

<form id="frmModalWizardAddObject" class="ui form">
{$object->display("I")}
</form>

{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
