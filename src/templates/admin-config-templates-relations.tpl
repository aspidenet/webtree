<script>
$(function(){
    {$tabulator_rsrelations->display("tabulator_tplrelations", "false", 5, "rowClick", false, '/admin/config/sysrelations/update-sorting')}
});
function rowClick(e, row) {
    var code = row.getData()['relation_code'];
    console.log(code);
    console.log(row.getData());
    modal_page_new(
        '{$record_code|md5}', 
        '/modal/{$record_code|md5}/template/sysrelation/update/'+code, 
        'large', 
        onHideTemplateRelation, 
        function() {
            sendFormTemplate(
                '{$record_code|md5}',
                '/modal/template/sysrelation/update/'+code,
                onApproveTemplateRelation
            )
        }
    );
}
function onApproveTemplateRelation() {
    var url = "{$return_url}";
    redirect(url);
}
function onHideTemplateRelation() {
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    {assign var="current_id" value="modaladdrelation"|cat:$record_code}
    <button onclick="modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/sysrelation/new?master_code={$record_code}&return_url={$return_url_encoded}',
                'large', 
                onHideTemplateRelation, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/sysrelation/new',
                        onApproveTemplateRelation
                    )
                }
            )" class="ui green button"><i class="add icon"></i> Nuova relazione</button>  
</div>
{* fine tastoni *}

<div class="ui header">Relazioni configurate</div>
<div id="tabulator_tplrelations" style="margin: 3px;"></div>
