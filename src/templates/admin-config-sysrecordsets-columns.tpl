<script>
var tabulator_rscolumns;
$(function(){
    {$tabulator_rscolumns->display("tabulator_rscolumns", "false", 15, "rowClick", false, '/admin/config/sysrecordsets/update-sorting')}
});
function rowClick(e, row) {
    var code = row.getData()['column_code'];
    //modal_popup_url('/wizard/syscolumns/update/'+code, onApproveRecordsetColumn);
    modal_page_new(
        '{$code|md5}', 
        '/modal/{$code|md5}/template/syscolumns/update/'+code, 
        'large', 
        onHideRecordsetColumn, 
        function() {
            sendFormTemplate(
                '{$code|md5}',
                '/modal/template/syscolumns/update/'+code,
                onApproveRecordsetColumn
            )
        }
    );
}
function onHideRecordsetColumn() {
    //var url = "/admin/config/sysrecordsets/update/{$record_code}?tab=columns";
    //redirect(url);
}
function onApproveRecordsetColumn() {
    console.log('onApproveRecordsetColumn');
    var url = "/admin/config/sysrecordsets/update/{$record_code}?tab=columns";
    redirect(url);
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    {assign var="current_id" value="modaladdcolumn"|cat:$record_code}
    <button onclick="modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/syscolumns/new?recordset_code={$record_code}&column_code={$record_code}_',
                'large', 
                onHideRecordsetColumn, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/syscolumns/new',
                        onApproveRecordsetColumn
                    )
                }
            )" class="ui green button"><i class="add icon"></i> Nuova colonna</button>  
    
</div>
{* fine tastoni *}

<div class="ui header">Colonne configurate</div>
<div id="tabulator_rscolumns" style="margin: 3px;"></div>


<div class="ui header">Altre colonne nel recordset disponibili</div>
{foreach key=key key=key item=item from=$source_colums}
    {assign var="current_id" value="modaladdcolumn"|cat:$record_code|cat:$key}
    <div style="margin:1px;">
        <button onclick="
            modal_page_new(
                '{$current_id|md5}',
                '/modal/{$current_id|md5}/template/syscolumns/new?recordset_code={$record_code}&dbcolumn={$key}&column_code={$record_code}_{$key}',
                'large', 
                onHideRecordsetColumn, 
                function() {
                    sendFormTemplate(
                        '{$current_id|md5}',
                        '/modal/template/syscolumns/new',
                        onApproveRecordsetColumn
                    )
                }
            )" class="ui green button"><i class="add icon"></i> Aggiungi</button> {$key}<br>
        
    </div>
{foreachelse}
<div>Sorgente non valida.</div>
{/foreach}