{extends file="template-private.tpl"}


{block name="content"}

<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '/admin/config/users/{$action}/{$record_code}',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"user"}');
});

function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}
</script>


<div style="margin: 20px 0px;">

    <div style="text-align:right;">
        <a class="ui grey button" href="{$APP_BASE_URL}/admin/config/users/list">Indietro</a>
    </div>

    <div class="ui header">User: <span class="ui orange">{$record_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        <a class="item" data-tab="user">User</a>
        <a class="item" data-tab="registry">Registry</a>
        <a class="item" data-tab="groups">Groups</a>
        <a class="item" data-tab="auths">Auths</a>
    </div>
    
    <div class="ui bottom attached tab segment" data-tab="user">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="registry">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="groups">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="auths">

    </div>
    

</div>
{/block}