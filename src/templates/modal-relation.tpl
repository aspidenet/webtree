{extends file="template-modal-page.tpl"}

{block name="modal_actions_footer"}
{if $action == 'new'}
<a class="ui blue button" onclick="modal_page_new(
        '{$hashing}', 
        '/modal/template/{$template->code()}/new', 
        'longer', 
        reload{$hashing}Tabulator,
        function() {
            alert('nuovo');
        }
    );" title="Crea un nuovo record perch&egrave; non presente in elenco">Nuovo</a>
<button class="ui green button" onclick="modal_relation_add_selected();" title="Associa i record selezionati">
    <i class="plus icon"></i> Associa
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
<div id="tabulator_{$hashing}" style="margin: 3px;"></div>


<script>
var modal_relation_selected_{$hashing} = null;
var tabulator_{$hashing};

$(document).ready(function() {

    {$tabulator->display("tabulator_"|cat:$hashing, 0, 20, modal_relation_row_select, true)}

});
function reload{$hashing}Tabulator() {
    console.log("--- Reload tabulator_{$hashing} -----------------------");
    tabulator_{$hashing}.setData();
}
function modal_relation_row_select(data, rows) {
    /*
    if (data.length == 0)
        return;
    console.log(data);
    var selectedData = this.getSelectedData();
    console.log(selectedData);
    var myJSON = JSON.stringify(selectedData);
    console.log(myJSON);*/
    modal_relation_selected_{$hashing} = this.getSelectedData();
    console.log(modal_relation_selected_{$hashing});
}

function modal_relation_add_selected() { 
    console.log("modal_relation_add_selected");
    var selectedData = modal_relation_selected_{$hashing}; 
    console.log("selectedData");
    console.log(selectedData);
    if (selectedData.length == 0) {
        alert("Nessun elemento selezionato");
        return false;
    }
    
    //return;
    $.ajax({
        type: "POST",
        url: "{$REQUEST->uri()}",
        data: { dati: JSON.stringify(selectedData) },
        success: function () {
            console.log("modal_relation_add_selected success");
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
                if (msg.result)
                    $(".ui.cancel.button").click();
            });
        }
    });   
}

</script>
MODAL RELATION {$REQUEST->uri()}



{/block}