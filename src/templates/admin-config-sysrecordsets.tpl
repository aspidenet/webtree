{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '/admin/config/sysrecordsets/{$action}/{$record_code}',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"recordset"}');
});

function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}
</script>
{/block}


{block name="content"}
<div style="margin: 20px 0px;">

    <div style="text-align:right;">
        <a class="ui grey button" href="{$APP_BASE_URL}/admin/config/sysrecordsets/list">Indietro</a>
    </div>

    
    <div class="ui header">{$tab} Template: <span class="ui orange">{$template_code|upper}</span>    Oggetto: {$record_code|upper}</div>

    <div class="ui top attached tabular menu">
        <a class="item" data-tab="recordset">Recordset</a>
        <a class="item" data-tab="columns">Columns</a>
        <a class="item" data-tab="auths">Auths</a>
    </div>
    
    <div class="ui bottom attached tab segment" data-tab="recordset">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="columns">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="auths">

    </div>
    

</div>
{/block}