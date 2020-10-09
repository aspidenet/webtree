{if $relation["readonly"] == 'N'}
<div style="text-align:right;">
    {if $relation.flag_can_create}
    <a class="ui green button" 
        onclick="modal_page_new(
                    '{$id}', 
                    '/modal/{$id}/template/{$relation.slave_code}/new', 
                    'longer', 
                    func{$id}OnHideRelation,
                    function() {
                        console.log('sendFormTemplate {$id}');
                        sendFormTemplate(
                            '{$id}',
                            '/modal/wizard/{$wizard_code}/relation/{$relation.relation_code}/create/master/{$step}',
                            func{$id}OnApproveRelation
                        )
                    }
                );"><i class="icon add"></i> Nuovo</a>
    {/if}
    
    {if $relation.flag_can_link}
    <a class="ui green button" onclick="modal_page_new('{$id}', '/modal/wizard/{$wizard_code}/relation/{$relation.relation_code}/new/master/{$step}', 'longer', func{$id}OnHideRelation);"><i class="icon link"></i> Associa</a>
    {/if}
    
    <a class="ui red button" onclick="wizard_update_relation_delete_selected();"><i class="icon erase"></i> Elimina</a>
</div>
{/if}

XYZ /modal/wizard/{$wizard_code}/relation/{$relation.relation_code}/new/master/{$step}
<div id="tabulator_{$hashing}" style="margin: 3px;"></div>




<script>
var tabulator_{$hashing};
    
$(document).ready(function() {
    {$tabulator->display("tabulator_"|cat:$hashing, 0, 20, "modal_relation_row_select_"|cat:$id, true)}
    
    tabulator_{$hashing}.redraw();
});
function func{$id}OnApproveRelation() {
    console.log("modal-wizard-new-relation: func{$id}OnApproveRelation(): reload tabulator.");
    tabulator_{$hashing}.redraw();
}
function func{$id}OnHideRelation () {
    console.log("------- on hide -------");
    console.log($("#modal{$id}container").parent().attr('id'));
    console.log("{$id}");
    console.log("{$REQUEST->uri()}");
    //reload($("#modal{$id}container").parent().attr('id'), "{$REQUEST->uri()}");
    
    //redirect('{$refresh_uri}');
    
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
                //window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
                if (msg.result)
                    func{$id}OnHideRelation();
            });
        }
    });   
}
</script>