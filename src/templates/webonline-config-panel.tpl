{extends file="template-private.tpl"}

{*block name="html_head_extra"}
<script src="https://semantic-ui.com/javascript/library/tablesort.js"></script>

<script language="JavaScript" type="text/javascript">
$(function(){
    $('table').tablesort();
});
</script>
{/block*}


{block name="page_content"}
<div class="ui grid">
    <div class="two wide column"><div style="padding:0.5em;">
        <div class="ui compact vertical labeled icon menu">
           {foreach item=item from=$configurazione}
            <a class="item" href="{$item.link}">
                <i class="{$item.icona} huge icon"></i>
                {$item.nome}
            </a>
            {/foreach}
          
        </div>
    </div></div>



    <div class="fourteen wide column">
        <div style="padding:0.5em;">
    {block name="content"}
    {/block}
        </div>
    </div>
</div>

{/block}