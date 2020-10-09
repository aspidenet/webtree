{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '/admin/config/systemplates/{$action}/{$record_code}',
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
        <a class="ui grey button" href="{$APP_BASE_URL}/admin/config/systemplates/list">Indietro</a>
    </div>

    <div class="ui header">Template: <span class="ui orange">{$record_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        <a class="item" data-tab="template">Template</a>
        <a class="item" data-tab="fields">Fields</a>
        <a class="item" data-tab="relations">Relations</a>
        <a class="item" data-tab="auths">Auths</a>
    </div>
    
    <div class="ui bottom attached tab segment" data-tab="template">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="fields">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="relations">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="auths">

    </div>
    

</div>
{/block}