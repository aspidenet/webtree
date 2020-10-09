{extends file="template-private.tpl"}

{block name="page_content"}
<script language="JavaScript" type="text/javascript">
$(function(){
});

function importRecord(table, key) {
    $.ajax({
        type: "GET",
        url: '{$APP_BASE_URL}/sys/sync/import/tables/'+table+'/'+key,
        success: function () {
            console.log("success");
        }
    })
    .done(function( data ) {
        console.log(data);
        key = key.replace('+', '');
        //return false;
        if (data == 'OK') {
            $("#td_"+table+"_"+key).html('<i class="green large smile icon"></i>');
        }
        else if (data == 'KO') {
            $("#td_"+table+"_"+key).html('<i class="red large angry icon"></i>');
        }
        else {
            var msg = JSON.parse(data);
            ShowMessage(msg, false, function() { 
                return true;
            });
        }
    });  
}

</script>
<style>
    p { padding-top: 12px; }
    
    .source_value { border: 2px solid green; padding: 2px 10px; }
    .target_value { border: 2px solid red; padding: 2px 10px; }
</style>

<center>

    {foreach name="t" key="table" item="item" from=$differenze}
    <h2>{$table}</h2>
    <div style="overflow-x: auto;">
        {foreach name="c" key="key" item="diff" from=$item}
        
            {if $smarty.foreach.c.first}<table class="" border="1">
            <thead></thead>
            <tbody>
            {/if}
            
            {cycle values="#99ccff,#ffcc99" assign="bgcell"}
            
            <tr>
                <th rowspan="3" style="background:{$bgcell};">{$key}</th>
        
            {foreach key="col" item="value" from=$diff.new}
                <th>{$col}</th>
            {foreachelse}
                {foreach key="col" item="value" from=$diff.old}
                    <th>{$col}</th>
                {/foreach}
            {/foreach}
            
                <th rowspan="3" style="background:{$bgcell};">{$key}</th>
            </tr>
            
            
            <tr>
            {foreach key="col" item="value" from=$diff.new}
                <td class="source_value">{$value}</td>
            {/foreach}
                <td style="border:0px;" id="td_{$table}_{$key|replace:'+':''}">
                    <button class="ui basic button" title="Importa record" type="button" 
                            onclick="importRecord('{$table}', '{$key}');"><i class="icon download"></i></button>
                </td>
            </tr>
            
            <tr>
            {foreach key="col" item="value" from=$diff.old}
                <td class="target_value">{$value}</td>
            {/foreach}
            </tr>
            
            {if $smarty.foreach.c.last}
            </tbody>
            </table>
            <p><span class="source_value">SORGENTE</span> <span class="target_value">LOCALE</span> {/if}
        {foreachelse}
        <p>Nessuna differenza.</p>
        {/foreach}
    </div>
    {/foreach}






</center>
{/block}