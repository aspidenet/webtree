{extends file="template-private.tpl"}

{block name="content"}
<script>
var tabulator;
$(function(){
    {$tabulator->display("tabulator", "false", null, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['{$template->dbkey()}'];
    var url = '{$APP.url}/{$template->code()}/update/'+code;
    //modal_popup_url(, onHideTemplateField);
    redirect(url);
}
function onHideTemplateField() {
    var url = "{$APP.url}/{$template->code()}/list";
    redirect(url);
}
function onHideTemplateNew() {
    
}
function onApproveTemplateNew() {
    var url = "{$APP.url}/{$template->code()}/list";
    redirect(url);
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <div class="ui stackable two column grid">
        <div class="column">
            
            <button onclick="modal_page_new(
                        '{$current_id|md5}',
                        '{$APP_BASE_URL}/modal/wizard/new/{$template->code()}',
                        'large', 
                        onHideTemplateNew, 
                        onApproveTemplateNew
                    )" class="ui green button"><i class="add icon"></i> Nuovo</button> 
            
            
            
        </div>
        <div class="right aligned column">
            <a class="ui grey button" href="{$APP.url}">Indietro</a>
        </div>
    </div>
    
</div>
{* fine tastoni *}

<div class="ui header">{$template->label()}</div>
<div id="tabulator" style="margin: 3px;"></div>


{/block}