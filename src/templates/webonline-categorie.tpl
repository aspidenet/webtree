{extends file="template-private.tpl"}

{block name="content"}

<style>

</style>


<div id="wolmenu">
    
    <div class="ui pagination menu">
        <a class="{if $tipo == 'all'}active{/if} item" href="{$APP.url}/all" title="Tutte le procedure"><i class="globe icon"></i> Tutte</a>
        <a class="{if $tipo == 'X'}active{/if} item" href="{$APP.url}/X" title="Web Online"><i class="database icon"></i> Analisi Excel, CSV, PDF</a>
        {*<a class="{if $tipo == 'S'}active{/if} item" href="{$APP.url}/S" title="Report"><i class="print icon"></i> Report</a>*}
        <a class="{if $tipo == 'D'}active{/if} item" href="{$APP.url}/D" title="Dashboard"><i class="chart bar icon"></i> Dashboard</a>
        {*<a class="{if $tipo == 'M'}active{/if} item" href="{$APP.url}/M" title="Documentazione"><i class="book icon"></i> Documentazione</a>*}
    </div>
  
    <div id="toolbar" style="padding: 1.5em;">
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
  
    <br>
  
    <div style="clear:both;">
    {foreach item=item from=$categorie}


        <a class="header" href="{$APP.url}/procedure/{$item.code}/{$tipo}">
            <div class="ui segment">
                <i class="big {$item.icon|default:'tags'} middle aligned icon"></i>
                <span style="font-size: 1.4em;">{$item.categoria}</span>
            </div>
        </a>
      

    {foreachelse}
        Nessuna voce disponibile.
    {/foreach}

    </div>
</div>

{/block}
