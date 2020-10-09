<script>
var tabulator_params;
$(function(){
    {$tabulator_params->display("tabulator_params", "false", 5, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['code'];
    console.log(code);
    console.log(row.getData());
    modal_page_new(
        '{$record_code|md5}', 
        '/modal/{$record_code|md5}/template/metaparams/update/'+code, 
        'large', 
        onHideProcedureParam, 
        function() {
            sendFormTemplate(
                '{$record_code|md5}',
                '/modal/template/metaparams/update/'+code,
                onApproveProcedureParam
            )
        }
    );
}
function onApproveProcedureParam() {
    var url = "{$return_url}";
    redirect(url);
}
function onHideProcedureParam() {
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    {assign var="current_id" value="modaladdrelation"|cat:$record_code}
    <button onclick="modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/metaparams/new?code_procedure={$record_code}&return_url={$return_url_encoded}',
                'large', 
                onHideProcedureParam, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/metaparams/new',
                        onApproveProcedureParam
                    )
                }
            )" class="ui green button"><i class="add icon"></i> Nuovo parametro</button>  
</div>
{* fine tastoni *}

<div class="ui header">Parametri</div>
<div id="tabulator_params" style="margin: 3px;"></div>
