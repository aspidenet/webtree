{extends file="template-modal-page.tpl"}

{block name="modal_actions_footer"}

<button class="ui green button" onclick="modal_relation_add_selected();" title="Associa i record selezionati">
    <i class="plus icon"></i> Associa
</button> 
<button class="ui grey cancel button">
    <i class="close icon"></i> Chiudi
</button>  
{/block}




{block name="modal_content"}

<div class="ui two column grid">
  
    <div class="column">
        <button class="ui button" id="user-select-all">Tutti</button> 
        <button class="ui button" id="user-deselect-all">Nessuno</button> 
        <div id="tabulator_users"></div>
    </div>
    
    <div class="column">
        <button class="ui button" id="visib-select-all">Tutti</button> 
        <button class="ui button" id="visib-deselect-all">Nessuno</button> 
        <div id="tabulator_visibility"></div>
    </div>
</div>






<script>
var users_selected = null;
var visibilities_selected = null;
var tabulator_users
var tabulator_visibility;

$(document).ready(function() {

    {$tabulator_users->display("tabulator_users", 0, 5, user_row_select, true)}
    {$tabulator_visibility->display("tabulator_visibility", 0, 5, visibility_row_select, true)}

});
function reload{$hashing}Tabulator() {
    console.log("--- Reload tabulator_{$hashing} -----------------------");
    tabulator_{$hashing}.setData();
}
function user_row_select(data, rows) {
    users_selected = this.getSelectedData();
    console.log(users_selected);
}
function visibility_row_select(data, rows) {
    visibilities_selected = this.getSelectedData();
    console.log(visibilities_selected);
}

function modal_relation_add_selected() { 
    console.log("modal_relation_add_selected");
    if (users_selected.length == 0) {
        alert("Nessun utente selezionato");
        return false;
    }
    if (visibilities_selected.length == 0) {
        alert("Nessuna visibilità selezionata");
        return false;
    }
    //return;
    $.ajax({
        type: "POST",
        url: "{$REQUEST->uri()}",
        data: { users: JSON.stringify(users_selected), visib: JSON.stringify(visibilities_selected) },
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


//select row on "select all" button click
$("#user-select-all").click(function(){
    tabulator_users.selectRow();
});

//deselect row on "deselect all" button click
$("#user-deselect-all").click(function(){
    tabulator_users.deselectRow();
});




//select row on "select all" button click
$("#visib-select-all").click(function(){
    tabulator_visibility.selectRow();
});

//deselect row on "deselect all" button click
$("#visib-deselect-all").click(function(){
    tabulator_visibility.deselectRow();
});
</script>
CUSTOM MODAL RELATION USERPROFILE {$REQUEST->uri()}



{/block}