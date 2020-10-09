{extends file="template-private.tpl"}

{block name="content"}
<script>
var tabulator_procedure;
$(function(){
    {$tabulator_procedure->display("tabulator_procedure", "false", 100, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['code'];
    var url = '/admin/webonline/procedura/'+code;
    //modal_popup_url(, onHideTemplateField);
    redirect(url);
}
function onHideNewProcedure() {
    var url = "/admin/webonline/";
    redirect(url);
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <button onclick="modal_popup_url('/wizard/metaprocedures/new?return_url={$return_url_encoded}', onHideNewProcedure)" class="ui green button"><i class="add icon"></i> Nuova procedura</button>  
    
</div>
{* fine tastoni *}

<div class="ui header">Procedure</div>
<div id="tabulator_procedure" style="margin: 3px;"></div>


{/block}