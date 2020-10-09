{extends file="template-private.tpl"}

{block name="content"}
<script>
$(function(){
    {$tabulator->display("tabulator", "false", null, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['code'];
    var url = '/admin/config/{$template->code()|lower}/update/'+code;
    //modal_popup_url(, onHideTemplateField);
    redirect(url);
}
function onHideTemplateField() {
    var url = "/admin/config/{$template->code()}/list";
    redirect(url);
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <div class="ui stackable two column grid">
        <div class="column">
            <button onclick="modal_popup_url('/wizard/sysrecordsets/new', onHideTemplateField)" class="ui green button"><i class="add icon"></i> Nuovo</button>   
        </div>
        <div class="right aligned column">
            <a class="ui grey button" href="{$APP_BASE_URL}/admin">Indietro</a>
        </div>
    </div>
    
</div>
{* fine tastoni *}

<div class="ui header">{$template->label()}</div>
<div id="tabulator" style="margin: 3px;"></div>


{/block}