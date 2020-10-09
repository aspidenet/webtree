{extends file="template-private.tpl"}

{block name="html_head_extra"}

<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '/admin/config/procedures/{$action}/{$record_code}',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"procedure"}');
});

function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}
</script>
{/block}


{block name="content"}
<div style="margin: 20px 0px;">

    <div style="text-align:right;">
        <a class="ui grey button" href="{$APP_BASE_URL}/admin/config/procedures/list">Indietro</a>
    </div>

    <div class="ui header">Procedura: <span class="ui orange">{$record_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        <a class="item" data-tab="procedure">Procedura</a>
        <a class="item" data-tab="params">Parametri</a>
    </div>
    
    <div class="ui bottom attached tab segment" data-tab="procedure">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="params">

    </div>
    

</div>
{/block}