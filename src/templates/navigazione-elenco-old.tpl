{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script src="{$STATIC_URL}/jquery-ui.min.js"></script>
<link href="{$STATIC_URL}/assets/tabulator/css/tabulator.min.css" rel="stylesheet">
<script type="text/javascript" src="{$STATIC_URL}/assets/tabulator/js/tabulator.min.js"></script>
<script type="text/javascript" src="{$STATIC_URL}/assets/tabulator/js/jquery_wrapper.min.js"></script>

<link href="{$STATIC_URL}/assets/tabulator/css/semantic-ui/tabulator_semantic-ui.min.css" rel="stylesheet">

<script>
$(document).ready(function() {
});

</script>
{/block}




    
{block name="page_content"}

<script>
$(document).ready(function() {
    var top_div = $('#content_top_limit').offset().top;
    var bottom_div = $('#content_bottom_limit').offset().top;
    
    $("#example-table").tabulator({
        height:(bottom_div-top_div-50), // set height of table (in CSS or here), this enables the Virtual DOM and improves render speed dramatically (can be any valid css height value)
        layout:"fitData", //fitData, fitDataFill, fitColumns
        columns:[ //Define Table Columns
            //{ title:"Name", field:"name", width:150 },
            //{ title:"Age", field:"age", align:"left", formatter:"progress" },
            //{ title:"Favourite Color", field:"col" },
            //{ title:"Date Of Birth", field:"dob", sorter:"date", align:"center" },
            
            
            {foreach name="c" key="key" item="campo" from=$record}
		
                { title:"{$key}", field:"{$key|lower}", headerFilter:true },
                
            {/foreach}
            
            
        ],
        rowClick:function(e, row){ //trigger an alert message when the row is clicked
            //alert("Row " + row.getData().id + " Clicked!!!!");
            //console.log(row.getData());
            var classe = '{$classe}';
            var code = row.getData()['{$campo_chiave}'];
            document.location = "{$ROOT_URL}{$APP.url}/oggetto/"+classe+'/'+code;
        },
        ajaxFiltering:true,
        ajaxSorting:true,
        pagination:"remote", //enable remote pagination
        ajaxURL:"{$ROOT_URL}{$APP.url}/api", //set url for ajax request
        ajaxParams:{ token:"ABC123" }, //set any standard parameters to pass with the request
        paginationSize:100, //optional parameter to request a certain number of rows per page
        locale:true,
        langs:{
            "it-it":{
                "columns":{
                    "name":"Nome", //replace the title of column name with the value "Name"
                },
                "ajax":{
                    "loading":"Loading", //ajax loader text
                    "error":"Error", //ajax error text
                },
                "groups":{ //copy for the auto generated item count in group header
                    "item":"item", //the singluar for item
                    "items":"items", //the plural for items
                },
                "pagination":{
                    "first":"Prima", //text for the first page button
                    "first_title":"Prima", //tooltip text for the first page button
                    "last":"Ultima",
                    "last_title":"Ultima",
                    "prev":"Precedente",
                    "prev_title":"Precedente",
                    "next":"Prossima",
                    "next_title":"Prossima",
                },
                "headerFilters":{
                    "default":"filtro...", //default header filter placeholder text
                    "columns":{
                        "name":"filtro...", //replace default header filter text for column name
                    }
                }
            }
        },
    });
    
    //$("#example-table").tabulator("setData","api.php");

});


    /*function ExportCSV() {
        $("#example-table").tabulator("download", "csv", "data.csv");
    }
    function ExportXLSX() {
        $("#example-table").tabulator("download", "xslx", "data.xslx");
    }*/
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

{*<button class="ui basic button" onclick="ExportXLSX();">XLSX download</button>
<button class="ui basic button" onclick="ExportCSV();">CSV download</button>*}


<div style="clear:both; width:100%;" id="content_top_limit"></div>


<div id="example-table" style="margin: 3px;"></div>


{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
