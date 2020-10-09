{extends file="template-modal.tpl"}
    
{block name="content"}

<script>
$(document).ready(function() {
    var top_div = $('#content_top_limit_form_select').offset().top;
    var bottom_div = $('#content_bottom_limit_form_select').offset().top;
    
    $("#example-table").tabulator({
        //height:(bottom_div-top_div-50), // set height of table (in CSS or here), this enables the Virtual DOM and improves render speed dramatically (can be any valid css height value)
        layout:"fitData", //fitData, fitDataFill, fitColumns
        columns:[ //Define Table Columns
            
            {foreach name="c" key="key" item="campo" from=$record}
		
                { title:"{$key}", field:"{$key|lower}", headerFilter:true },
                
            {/foreach}
            
        ],
        /*rowClick:function(e, row){ //trigger an alert message when the row is clicked
            //alert("Row " + row.getData().id + " Clicked!!!!");
            //console.log(row.getData());
            var classe = '{$classe}';
            var code = row.getData()['{$campo_chiave}'];
            document.location = "{$ROOT_URL}{$APP.url}/wizard/"+classe+'/'+code;
        },*/
        selectable:true,
        ajaxFiltering:true,
        ajaxSorting:true,
        pagination:"remote", //enable remote pagination
        ajaxURL:"{$ROOT_URL}{$APP.url}/json/wizard-{$wizard_code}/relation-{$relation_code}/new/list", //set url for ajax request
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
    
});
</script>



<form id="frmNewAssociations">
    



</form>




<div style="margin: 0.5em 0; border: 0px solid teal;">

    <div style="clear:both; width:100%;" id="content_top_limit_form_select"></div>


    <div id="example-table" style="margin: 3px;"></div>

</div>
{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
