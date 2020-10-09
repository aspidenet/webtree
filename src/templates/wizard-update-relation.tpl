{if $relation["readonly"] == 'N'}
<div style="text-align:right;">
    {*<a class="ui blue button" onclick="modal_page_new('{$id}', '/modal/template/{$relation.slave_code}/new', 'longer', func{$id}OnHide);">Nuovo</a>*}
    <a class="ui green button" onclick="modal_page_new('{$id}', '/modal/relation/{$relation.relation_code}/new/master/{$record_code}', 'longer', func{$id}OnHide);">Associa</a>
    <a class="ui red button" onclick="wizard_update_relation_delete_selected();">Elimina</a>
</div>
{/if}

<div id="tabulator_{$hashing}" style="margin: 3px;"></div>




<script>
{$tabulator->display("tabulator_"|cat:$hashing, 0, 20, "modal_relation_row_select_"|cat:$id, true)}

$(document).ready(function() {
});

function func{$id}OnHide () {
    console.log("------- on hide -------");
    console.log($("#modal{$id}container").parent().attr('id'));
    console.log("{$id}");
    console.log("{$REQUEST->uri()}");
    //reload($("#modal{$id}container").parent().attr('id'), "{$REQUEST->uri()}");
    
    redirect('{$refresh_uri}');
}
function modal_relation_row_select_{$id}(data, rows) {
    modal_relation_selected_{$id} = this.getSelectedData();
    console.log(modal_relation_selected_{$id});
}

function wizard_update_relation_delete_selected() { 
    console.log("wizard_update_relation_delete_selected");
    var selectedData = modal_relation_selected_{$id}; //$("#tabulator-table-{$hashing}").tabulator().getSelectedData();
    console.log(selectedData);
    
    //return;
    $.ajax({
        type: "POST",
        url: "/modal/relation/{$relation.relation_code}/delete/master/{$record_code}",
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
                //window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
                if (msg.result)
                    func{$id}OnHide();
            });
        }
    });   
}
</script>