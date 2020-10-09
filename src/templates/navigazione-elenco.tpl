{extends file="template-private.tpl"}

{block name="html_head_extra"}

{/block}




    
{block name="page_content"}
<style>
.tabulator-headers {
    $backgroundColor:#f00; //change background color of table
}
#tabulator-table-{$hashing} .tabulator-header {
    background-color:#F33;
    padding-bottom: 3px;
}
#tabulator-table-{$hashing} .tabulator-headers {
    background-color:#fff;
    color:#fff;
}
#tabulator-table-{$hashing} .tabulator-col {
    background-color:#2185d0;
    color:#fff;
}
#tabulator-table-{$hashing} .tabulator-header-filter input {
    border: 0px;
    -webkit-border-radius: 3px;
    -moz-border-radius: 3px;
    border-radius: 3px;
}

#tabulator-table-{$hashing} .tabulator-row-odd {
    background-color:#e9f3fc;
}
#tabulator-table-{$hashing} .tabulator-row-even {
    background-color:#bddcf5;
}
/*#tabulator-table-{$hashing} .tabulator-selected {
    background-color:#f88;
}*/
.tabulator .tabulator-header .tabulator-col .tabulator-col-content .tabulator-col-title {
    white-space: normal;
}
</style>

<script>
$(document).ready(function() {
    var top_div = $('#content_top_limit').offset().top;
    var bottom_div = $('#content_bottom_limit').offset().top;
    var tabulator_height = (bottom_div-top_div-60);
    
    {$tabulator->display("tabulator_"|cat:$hashing, "tabulator_height", 100, "rowClickfunc", false)}

});

function rowClickfunc(e, row) { //trigger an alert message when the row is clicked
            //alert("Row " + row.getData().id + " Clicked!!!!");
            //console.log(row.getData());
            var classe = '{$classe}';
            var code = row.getData()['{$campo_chiave}'];
            document.location = "{$APP_BASE_URL}{$APP.url}/oggetto/"+classe+'/'+code;
        }

</script>


{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
        
    <div id="btn_breadcrumb" class="tb_item" style="padding: 10px 14px;">
        <div class="ui breadcrumb">
            <a class="section" href="{$APP_BASE_URL}{$APP.url}">Naviga</a>
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
{* fine tastoni *}

<a id="download-xlsx" class="ui basic button" href="{$tabulator->getExportUrl()}">XLSX download</a>
{*<button class="ui basic button" onclick="ExportCSV();">CSV download</button>*}


<div style="clear:both; width:100%;" id="content_top_limit"></div>


<div id="tabulator_{$hashing}" style="margin: 3px; width:99.5%;"></div>


{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
