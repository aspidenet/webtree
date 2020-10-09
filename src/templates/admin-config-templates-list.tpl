{extends file="template-private.tpl"}

{block name="page_content"}
<script>
$(function(){
    {$tabulator_rscolumns->display("tabulator_tplfields", "false", null, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['template_code'];
    var url = '/admin/config/systemplates/update/'+code;
    //modal_popup_url(, onHideTemplateField);
    redirect(url);
}
function onHideTemplateNew() {
    
}
function onApproveTemplateNew() {
    var url = "/admin/config/systemplates/list";
    redirect(url);
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <div class="ui stackable two column grid">
        <div class="column">
            
            {assign var="current_id" value="fkjdkjskdjfkdsjfksjkd"}
            <button onclick="modal_page_new(
                        '{$current_id|md5}',
                        '{$APP_BASE_URL}/modal/wizard/new/systemplates',
                        'large', 
                        onHideTemplateNew, 
                        onApproveTemplateNew
                    )" class="ui green button"><i class="add icon"></i> Nuovo template</button> 
            
        </div>
        <div class="right aligned column">
            <a class="ui grey button" href="{$APP_BASE_URL}/admin">Indietro</a>
        </div>
    </div>
    
</div>
{* fine tastoni *}

<div class="ui header">Templates disponibili</div>
<div id="tabulator_tplfields" style="margin: 3px;"></div>


{/block}