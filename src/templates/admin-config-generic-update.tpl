{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '{$APP.url}/{$template->code()}/{$action}/{$record_code}',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"template"}');
});

function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}
</script>
{/block}


{block name="content"}
<div style="margin: 20px 0px;">

    <div style="text-align:right;">
        <a class="ui grey button" href="{$APP_BASE_URL}{$APP.url}/{$template->code()}/list">Indietro</a>
    </div>

    <div class="ui header">GENERIC Template: <span class="ui orange">{$record_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        <a class="item" data-tab="template">Template</a>
        {foreach item=item from=$template->relations()}
        <a class="item" data-tab="{$item.relation_code}">{$item.label0}</a>
        {/foreach}
        {*<a class="item" data-tab="auths">Auths</a>*}
    </div>
    
    <div class="ui bottom attached tab segment" data-tab="template">

    </div>
    
    
    {foreach item=item from=$template->relations()}
    <div class="ui bottom attached tab segment" data-tab="{$item.relation_code}">

    </div>
    {/foreach}
    
    
    
    
    
    <div class="ui bottom attached tab segment" data-tab="auths">

    </div>
    

</div>
{/block}