<script>
var {$tabulator_name};
$(function(){
    {$tabulator->display("{$tabulator_name}", "false", 15, "rowClick", false, '{$APP.url}/{$template->code()}/update-sorting')}
    
    
    
    
});
function rowClick(e, row) {
    /*var code = row.getData()['{$relation->dbfieldMaster()}'];
    modal_page_new(
        '{$code|md5}', 
        '/modal/{$code|md5}/template/{$template->code()}/update/'+code, 
        'large', 
        onHideRecordsetColumn, 
        function() {
            sendFormTemplate(
                '{$code|md5}',
                '/modal/template/{$template->code()}/update/'+code,
                onApproveRecordsetColumn
            )
        }
    );*/
}
function onHideRecordsetColumn() {
    //var url = "{$APP.url}/sysrecordsets/update/{$record_code}?tab=columns";
    //redirect(url);
}
function onApproveRecordsetColumn() {
    console.log('onApproveRecordsetColumn');
    var url = "{$APP.url}/{$template->code()}/update/{$record_code}?tab={$relation->templateSlave()->code()}";
    redirect(url);
}






function func{$id}OnHide () {
    console.log("------- on hide -------");
    console.log($("#modal{$id}container").parent().attr('id'));
    console.log("{$id}");
    console.log("{$REQUEST->uri()}");
    //reload($("#modal{$id}container").parent().attr('id'), "{$REQUEST->uri()}");
    
    redirect('{$refresh_uri}');
}

</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    {assign var="current_id" value="modaladdcolumn"|cat:$record_code}
    {*<button class="ui green button" onclick="modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/{$relation->templateSlave()->code()}/new?{$relation->dbfieldMaster()}={$record_code}',  {_* &{$relation->dbfieldMaster()}={$record_code}_ *_}
                'large', 
                onHideRecordsetColumn, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/{$relation->templateSlave()->code()}/new',
                        onApproveRecordsetColumn
                    )
                }
            )"><i class="add icon"></i> Associa nuovo</button>  *}
    
    
    <a class="ui green button" onclick="modal_page_new(
                'aaa{$id}', 
                '/modal/relation/{$relation->get('relation_code')}/new/master/{$record_code}', 
                'longer', 
                func{$id}OnHide
            );">Associa</a>
</div>
{* fine tastoni *}

URL nuova associazione: /modal/relation/{$relation->get('relation_code')}/new/master/{$record_code}
<div style="clear:both;"></div>

<div class="ui header">Associazioni attive {$REQUEST->uri()}</div>
<div id="{$tabulator_name}" style="margin: 3px;"></div>


