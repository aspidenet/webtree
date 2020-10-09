{extends file="template-private.tpl"}

{block name="html_head_extra"}

<style>

</style>

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
<center>





<div class="ui link five stackable cards">
    {foreach name=macro item=item key=key from=$session->menu()}
        {foreach name=moduli item=modulo key=codice from=$item.items}
    <a class="card" href="{$APP_BASE_URL}{$modulo.link}">
        <div class="image">
            <i class="{$modulo.image} huge icon"></i>
        </div>
        <div class="content">
            <div class="header">{$modulo.title}</div>
        </div>
    </a>
        {/foreach}
    {/foreach}
</div>


</center>
<br />
<br />
<br />
<br />

{/block}