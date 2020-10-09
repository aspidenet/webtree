{*if !$tabulator_height}
var top_div = $('#content_top_limit').offset().top;
var bottom_div = $('#content_bottom_limit').offset().top;
var tabulator_height = bottom_div-top_div-50;
{/if*}

/*$("{$tabulator_selector}").tabulator({ */
{$tabulator_selector} = new Tabulator("#{$tabulator_selector}", {
    height:{$tabulator_height|default:"false"}, // set height of table (in CSS or here), this enables the Virtual DOM and improves render speed dramatically (can be any valid css height value)
    layout:"{$tabulator_layout|default:'fitDataFill'}", //fitData, fitDataFill, fitColumns
    //responsiveLayout:"collapse",
    
    {if $tabulator_title|count_characters}
    columns:[ //Define Table Columns
        {
            title:"{$tabulator_title}",
            columns:[ 
                {foreach name="c" key="key" item="row" from=$tabulator_columns}
            
                    { title:"{$row.title}", field:"{$key|lower}", visible:{$row.visible}, headerFilter:true },
                    
                {/foreach}
            ]
        }
    ],
    {else}
    columns:[ 
        {foreach name="c" key="key" item="row" from=$tabulator_columns}
            { 
                title:"{$row.title}", 
                field:"{$key|lower}", 
                visible:{$row.visible}, 
                headerFilter:true, 
                formatter:"{$row.formatter|default:'plaintext'}" 
                {if $row.formatterParams|count_characters}, formatterParams: {$row.formatterParams}{/if} 
                {if $row.cellClick|count_characters}, cellClick: {$row.cellClick}{/if} 
            },
        {/foreach}
    ],
    {/if}
    {if $tabulator_selectable}
    selectable:true,
    rowSelectionChanged:
        {$row_select_function|default:'function(data, rows){ }'}
    ,
    /*function(data, rows){
        //update selected row counter on selection change
        if (data.length == 0)
            return;
    	console.log(data);
        var selectedData = this.getSelectedData();
    	console.log(selectedData);
        var myJSON = JSON.stringify(selectedData);
        console.log(myJSON);
    },*/
    {else}
    rowClick: //trigger an alert message when the row is clicked
        {$row_click_function|default:'function(e, row){ }'}
    ,
    {/if}
    ajaxFiltering:true,
    ajaxSorting:true,
    pagination:"remote", //enable remote pagination
    ajaxURL:"{$ajax_url}", //set url for ajax request
    ajaxParams:{$ajax_params|default:'{ }'}, //set any standard parameters to pass with the request
    paginationSize:{$tabulator_page_size|default:100}, //optional parameter to request a certain number of rows per page
    paginationSizeSelector:[10, 25, 50, 100, 250],
    //paginationElement:paginationElement,
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
                "page_size":"Record per pagina",
            },
            "headerFilters":{
                "default":"filtro...", //default header filter placeholder text
                "columns":{
                    "name":"filtro...", //replace default header filter text for column name
                }
            }
        }
    },
    placeholder:"Nessun record disponibile.",
    dataLoaded:function(data){
        console.log('dataLoaded');
        //console.log(data);
        //console.log(data.length);
        if (data.length == 0) {
            console.log("Empty");
            //$(".tabulator-header").hide();
            $(".tabulator-footer").hide();
        }
        //else if (data.length == 1) {
        //    $(".tabulator-footer").hide();
        //}
        else{
            $(".tabulator-footer").show();
        }
    },
    {if $tabulator_movable}
    movableRows:true,
    rowMoved:function(row){
        console.log(row);
        //console.log("Row: " + row.getData().id + " has been moved");
        data = {$tabulator_selector}.getData(); //download("json", "data.json");
        console.log(data);
        
        $.ajax({
            type: 'post',
            url: '{$tabulator_movable_url}',
            data: { data : JSON.stringify(data) }, //data.serialize(),
            success: function () {
                console.log("Post success");
            }
        })
        .done(function( data ) {
            {$tabulator_selector}.setData();
        });   
    },
    {/if}
    {*if $operatore->admin()}
    footerElement:"<a href='/admin/config/sysrecordsets/update/PERSONALE' target='_blank'><i class='large icon cogs'></i></a>", //add a custom button to the footer element
    {/if*}
});


{if $operatore->admin()}
$("#{$tabulator_selector}").before("<div style='text-align:right;'>\
    {if $source_config_url|count_characters}\
    <a href='{$source_config_url}' target='_blank'><i class='large icon database'></i></a>\
    {/if}\
    {if $recordset_code|count_characters}\
    <a href='/admin/config/sysrecordsets/update/{$recordset_code}' target='_blank'><i class='large icon tshirt'></i></a>\
    {/if}\
</div>");
{/if}
