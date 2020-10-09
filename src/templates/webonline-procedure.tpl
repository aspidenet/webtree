{extends file="template-private.tpl"}

{block name="content"}

<style>
/*a {
    color: black;
}
a:hover {
    color: olive !important;
}*/
</style>

<div class="ui center aligned pagination menu">
    <a class="{if $tipo == 'all'}active{/if} item" href="{$APP.url}/procedure/{$categoria}/all" title="Tutte le procedure"><i class="globe icon"></i> Tutte</a>
    <a class="{if $tipo == 'X'}active{/if} item" href="{$APP.url}/procedure/{$categoria}/X" title="Web Online"><i class="database icon"></i> Analisi Excel, CSV, PDF</a>
    {*<a class="{if $tipo == 'S'}active{/if} item" href="{$APP.url}/procedure/{$categoria}/S" title="Report"><i class="print icon"></i> Report</a>*}
    <a class="{if $tipo == 'D'}active{/if} item" href="{$APP.url}/procedure/{$categoria}/D" title="Dashboard"><i class="chart bar icon"></i> Dashboard</a>
    {*<a class="{if $tipo == 'M'}active{/if} item" href="{$APP.url}/procedure/{$categoria}/M" title="Documentazione"><i class="book icon"></i> Documentazione</a>*}
</div>

<div style="clear:both;">
    {if $show_indietro}
	<div class="tb_item_r">
        <form>
            <button type='button' name='btnIndietro' class="button" onclick="window.location='categorie.php';">Indietro</button>
        </form>
    </div>
    {/if}
</div>

  
<div id="toolbar" style="padding: 1.5em; float: left;">
    <div id="btn_breadcrumb" class="tb_item" style="padding: 10px 14px;">
        <div class="ui breadcrumb">
            <a class="section" href="{$APP.url}">{$APP.title}</a>
            {foreach name=b key=key item=item from=$breadcrumbs.list}
                <i class="right angle icon divider"></i>
                {if $key == $breadcrumbs.current}
                <div class="active section">{$item}</div>
                {else}
                <a class="section" href="{$breadcrumbs['url'][$key]}">{$item}</a>
                {/if}
            {/foreach}
        </div>
    </div>
</div>



  

<div style="clear:both;">
    {foreach item=item key=key from=$procedure}
            
        {assign var="target" value=""}
        {assign var="bg" value="#FFF"}
        {if $item.tipo == 'X'}
            {assign var="link_procedura" value="/procedura/"|cat:$key}
            {assign var="bg" value="#FFF"}
            {assign var="icon" value="database"}
        {elseif $item.tipo == 'M'}
            {assign var="link_procedura" value=$ROOT_DIR|cat:$item.codice}
            {assign var="target" value=" target='_blank' "}
            {assign var="bg" value="#E4DDEB"}
            {assign var="icon" value="book"}
        {elseif $item.tipo == 'D'}
            {assign var="link_procedura" value=$item.codice}
            {assign var="target" value=" target='_blank' "}
            {assign var="bg" value="#EBDDDD"}
            {assign var="icon" value="chart bar"}
        {elseif $item.tipo == 'R'}
            {assign var="link_procedura" value=$item.codice}
            {assign var="target" value=" target='_blank' "}
            {assign var="bg" value="#E4EBDD"}
            {assign var="icon" value="print"}
        {else}
            {assign var="link_procedura" value=$ROOT_DIR}
            {assign var="bg" value="#E4EBDD"}
            {assign var="icon" value="database"}
        {/if}
            
        <div class="ui icon message" style="background:{$bg};">
            <a href="{if $item.tipo != 'D'}{$APP.url}{/if}{$link_procedura}" {$target}><i class="huge {*if $item.path_icona}{$item.path_icona}{else}database{/if*}{$icon} icon"></i></a>
            <div class="content">
                <div class="header"><a href="{if $item.tipo != 'D'}{$APP.url}{/if}{$link_procedura}" {$target}><h3>{$item.descrizione}</h3></a></div>
                <p><b>ID interno: {$item.id}</b><br>
                    {$item.help}
                    {if $operatore->admin()}<br><em>{$item.codice}</em>{/if}
                </p>
                {*<p>{$item.tipo}</p>
                <p>{$link_procedura}</p>*}
            </div>
        </div>
            
        
      

    {foreachelse}
        Nessuna procedura disponibile per l'utente.
    {/foreach}
</div>    

{/block}

