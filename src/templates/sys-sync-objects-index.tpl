{extends file="template-private.tpl"}

{block name="content"}
<script language="JavaScript" type="text/javascript">
var dbname = '{$dbname}';
var items = [
    {foreach item="item" from=$objects}
    '{$item.name}',
    {/foreach}
];

$(function(){
    $('.custom.dropdown').dropdown({
        onChange: function(text, value) {
            window.location = '/sys/sync/objects/'+text;
        }
    });
    
    items.forEach(function(entry) {
        $.ajax({
            type: 'post',
            url: '/sys/sync/objects/'+dbname+'.'+entry,
            success: function () {
                
            }
        })
        .done(function( data ) {
            console.log(data);
            if (data.trim() == 'OK') {
                $("#icon_"+entry).removeClass("yellow").addClass("green");
            }
            else if (data == 'KO') {
                $("#icon_"+entry).removeClass("yellow").addClass("red");
            }
            else {
                //alert(data);
            }
        });      
    });
    
});

function showDiff(name) {
    var url = "/sys/sync/objects/diff/"+dbname+'.'+name;
    modal_page_new("diff", url, "overlay fullscreen", function() { }, function() {  });
}

</script>
<style>
</style>

<center>
    <br>
    <div class="custom ui selection icon dropdown">
    <i class="database icon"></i>
        <input type="hidden" name="custom" value="{$dbname}">
        <i class="dropdown icon"></i>
        <div class="default text">Web3</div>
        <div class="menu">
            <div class="item" data-value="web3">Web3</div>
            <div class="item" data-value="consolidamento_web3">Consolidamento</div>
        </div>
    </div>
                
    {foreach name="t" key="key" item="item" from=$objects}

        
        {if $smarty.foreach.t.first}<table class="ui striped table">
        <thead>
            <th colspan="2">TYPE</th>
            <th>NAME</th>
            <th></th>
            <th></th>
        </thead>
        <tbody>
        {/if}
           
        <tr>
            <td>{$item.type}</td>
            <td>{$item.type_desc}</td>
            <td>{$item.name}</td>
            <td><i class="yellow circle icon" id="icon_{$item.name}"></i></td>
            <td><button class="ui button" onclick="showDiff('{$item.name}');">Vedi</button></td>
        </tr>
        
        {if $smarty.foreach.t.last}
        </tbody>
        </table>
        {/if}
    {foreachelse}
    <p>Nessun oggetto.</p>
    {/foreach}

</center>
{/block}