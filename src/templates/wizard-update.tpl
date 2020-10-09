{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '{$APP_BASE_URL}/wizard/update/{$wizard_code}/{$record_code}',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"0"}');
});

function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}
</script>
{/block}


{block name="content"}

<div style="margin: 10px 0px;">

    <div style="text-align:right;">
        <a class="ui grey button" href="{$APP_BASE_URL}/wizard/list/{$wizard_code|upper}">Indietro</a>
    </div>

    <div class="ui header">Wizard: <span class="ui orange">{$wizard_code|upper}</span> Record: <span class="ui orange">{$record_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        {foreach item="item" key="key" from=$tabs}
        <a class="item" data-tab="{$key}">{$item}</a>
        {/foreach}
    </div>
    
    {foreach item="item" key="key" from=$tabs}
        <div class="ui bottom attached tab segment" data-tab="{$key}"></div>
    {/foreach}
    

</div>
{/block}