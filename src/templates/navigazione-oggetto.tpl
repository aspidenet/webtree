{extends file="template-private.tpl"}

{block name="page_content"}


<div id="toolbar" style="padding-top: 0.5em;">
    <div id="btn_breadcrumb" class="tb_item" style="padding: 10px 14px;">
        <div class="ui breadcrumb">
            <a class="section" href="{$APP.url}">Naviga</a>
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

<div style="clear:both;" class="ui grid">
    <div class="two wide column"><div style="padding:0.5em;">
    
        {*<form name="frmIndietro" method="GET" action="{$APP.url}"><input type="hidden" name="indietro" value="1" />
            <button class="ui basic fluid button" type="submit" title="Ritorna alla pagina precedente."><i class='left arrow icon'></i> Indietro</button>
        </form>*}
        
        {foreach name="r" item="relazione" from=$relazioni_padre}
        <div style="margin-bottom: 5px !important;">
            <a class="ui primary fluid button" href="{$APP.url}/relazione/{$relazione.relation_code}/{$chiave}">{$relazione.label_figlio}</a>
        </div>
        {/foreach}
        
    </div></div>



    <div class="fourteen wide column">
    {block name="content"}
    
        

        <div style="clear:both; padding: 5px;">
        {if isset($classe_template)}
            {$classe_template->displayNavigazione($record, $recordset)}
        {elseif isset($oggetto)}
            <h2>{$oggetto->label()}{*if $pagina.titolo|count_characters > 0}{$pagina.titolo}{/if*}</h2>

            <table class="ui definition collapsing table">
            <thead>
            </thead>
            <tbody>
                {foreach name="c" key="key" item="campo" from=$record}
                <tr>
                    <td class="collapsing">{$X->writeHead($key, $recordset[$key])}</td>
                    {$X->writeValue($campo, $key, $riga)}
                </tr>    
                {/foreach}
            </tbody>
            </table>
            
        {/if}
        </div>
    {/block}
    
    </div>
</div>





{/block}