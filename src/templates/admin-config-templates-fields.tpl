<script>
$(function(){
    {$tabulator_rscolumns->display("tabulator_tplfields", "false", 5, "rowClick", false, '/admin/config/systemplates/update-sorting')}
});
function rowClick(e, row) {
    var code = row.getData()['field_code'];
    modal_page_new(
        '{$code|md5}', 
        '/modal/{$code|md5}/template/sysfields/update/'+code, 
        'large', 
        onHideTemplateField, 
        function() {
            sendFormTemplate(
                '{$code|md5}',
                '/modal/template/sysfields/update/'+code,
                onApproveTemplateField
            )
        }
    );
}
function onApproveTemplateField() {
    var url = "{$return_url}";
    redirect(url);
}
function onHideTemplateField() {
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;"> 
    
    {assign var="current_id" value="modaladdfield"|cat:$record_code}
    <button onclick="modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/sysfields/new?template_code={$record_code}&field_code={$record_code}_',
                'large', 
                onHideTemplateField, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/sysfields/new',
                        onApproveTemplateField
                    )
                }
            )" class="ui green button"><i class="add icon"></i> Nuova campo</button>  
    
</div>
{* fine tastoni *}

<div class="ui header">Campi configurati</div>
<div id="tabulator_tplfields" style="margin: 3px;"></div>


<div class="ui header">Altri campi disponibili per il template</div>
{foreach key=key key=key item=item from=$source_colums}
    {assign var="current_id" value="modaladdcolumn"|cat:$record_code|cat:$key}
    <div style="margin:1px;">
        <button onclick="
            modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/sysfields/new?template_code={$record_code}&dbfield={$key}&field_code={$record_code}_{$key}',
                'large', 
                onHideTemplateField, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/sysfields/new',
                        onApproveTemplateField
                    )
                }
            )" class="ui green button"><i class="add icon"></i> Aggiungi</button> {$key}<br>
        
    </div>
{foreachelse}
<div>Sorgente non valida.</div>
{/foreach}