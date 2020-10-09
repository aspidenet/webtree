{extends file="template-modal-page.tpl"}

{block name="modal_content"}
<script>


$(document).ready(function() { 

});

    
function applicaFiltro() {
    $(".ok.filtro.button").click();
}
</script>


    {foreach name="t" key="key" item="item" from=$differences}

        
        {if $smarty.foreach.t.first}<table class="ui celled striped table">
        <thead>
            <th>Server corrente</th>
            <th>Sorgente</th>
        </thead>
        <tbody>
        {/if}
           
        <tr class="{if $item.diff}negative{else}positive{/if}">
            <td>{$item.target}</td>
            <td>{$item.source}</td>
        </tr>
        
        {if $smarty.foreach.t.last}
        </tbody>
        </table>
        {/if}
    {foreachelse}
    <p>Nessuna differenza.</p>
    {/foreach}
     
{/block}

{block name="modal_actions_footer"}
<button class="ui ok filtro button" style="display:none;">
    <i class="checklist icon"></i> OK
</button> 
{*<button class="ui primary button" onclick="applicaFiltro();">
    <i class=" icon"></i> Applica
</button> *}
<button class="ui grey cancel button">
    <i class="close icon"></i> Chiudi
</button> 
{/block}