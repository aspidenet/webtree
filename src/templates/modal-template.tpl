{extends file="template-modal-page.tpl"}

{block name="modal_actions_footer"}
    
    <div class="ui green ok save-modal-template button">
        <i class="checkmark icon"></i> Salva
    </div>
    <div class="ui grey cancel button">
        <i class="remove icon"></i> Chiudi
    </div>
    {if $action == "update"}
    <div class="ui red delete-modal-template button">
        <i class="erase icon"></i> Elimina
    </div>
    {/if}
    {block name="modal_actions_custom"}
    {/block}
{/block}


{block name="modal_content"}
<script>
var modal_id = '{$modal_id}';
function returnToUrl() {
    {if $return_url|count_characters>0}
        redirect("{$return_url}");
    {/if}
}
$(document).ready(function() {
    $(".delete-modal-template.button").click(function() {
        var msg = JSON.parse('{ "level":"WARNING", "description":"Stai per eliminare il record." }');
        ShowMessage(msg, false, function(){
            $("#frmModalTemplate{$modal_id} input[name='custom_action']").val('delete');
            $(".save-modal-template.button").click();
        });
        
    });
});
</script>




<div style="margin: 0.5em 0; border: 0px solid teal;">
    {**}modal-template.tpl Form id="frmModalTemplate{$modal_id}" {$action}
    <form id="frmModalTemplate{$modal_id}" class="ui form">
        <input type="hidden" name="template_code" value="{$template->code()}" />
        <input type="hidden" name="ignore_warning" value="N" />
        <input type="hidden" name="custom_action" value="{$action}" />

        <div class="ui header center aligned">{$template->label()}</div>
        {foreach key=key item=item from=$template->getFields()}

            {$item->display("{if $action == 'new'}I{elseif $action == 'update'}U{else}R{/if}", $values[$key])}

        {/foreach}
    </form>
</div>
{/block}