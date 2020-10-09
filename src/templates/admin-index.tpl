{extends file="template-private.tpl"}

{block name="html_head_extra"}

<script language="JavaScript" type="text/javascript">
$(function(){
});
</script>
{/block}


{block name="content"}

<style>

    
    .ui.cards > .card > .image { padding: 10px; }
</style>

<br />
<br />
<br />
<br />
<center>





<div class="ui link five stackable cards">
    {foreach key="key" item="item" from=$configurazione}
    <a class="card" href="{$item.link}">
        <div class="image">
            <i class="{$item.icona} huge icon"></i>
        </div>
        <div class="content">
            <div class="header">{$item.nome}</div>
        </div>
    </a>
    {/foreach}
</div>


</center>
<br />
<br />
<br />
<br />
{/block}