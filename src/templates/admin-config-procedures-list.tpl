{extends file="template-private.tpl"}

{block name="content"}
<script>
var tabulator_procedures;
$(function(){
    {$tabulator_procedures->display("tabulator_procedures", "false", null, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['code'];
    var url = '/admin/config/procedures/update/'+code;
    //modal_popup_url(, onHideTemplateField);
    redirect(url);
}
function onHide() {
}
function onApprove() {
    var url = "/admin/config/procedures/list";
    redirect(url);
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <div class="ui stackable two column grid">
        <div class="column">
            
            {assign var="current_id" value="hgyg6gyg77jh"}
            <button onclick="modal_page_new(
                        '{$current_id|md5}',
                        '{$APP_BASE_URL}/modal/wizard/new/metaprocedures',
                        'large', 
                        onHide, 
                        onApprove
                    )" class="ui green button"><i class="add icon"></i> Nuova procedura</button> 
                    
        </div>
        <div class="right aligned column">
            <a class="ui grey button" href="{$APP_BASE_URL}/admin">Indietro</a>
        </div>
    </div>
    
</div>
{* fine tastoni *}

<div class="ui header">Procedure</div>
<div id="tabulator_procedures" style="margin: 3px;"></div>


{/block}