
<script>
var tabulator_webonline;
var allData;
$(document).ready(function() {
    var top_div = 0; //$('#content_top_limit').offset().top;
    var bottom_div = $('#content_bottom_limit').offset().top;
    
    tabulator_webonline = new Tabulator("#example-table", {
        height:(bottom_div-top_div-250), // set height of table (in CSS or here), this enables the Virtual DOM and improves render speed dramatically (can be any valid css height value)
        layout:"fitData", //fitData, fitDataFill, fitColumns
        columns:[ //Define Table Columns
            
            {foreach name="c" key="key" item="campo" from=$record}
            
                {assign var="sorter" value=$tipi_campi[$key|lower]}
                {assign var="align" value="left"}
                {assign var="formatter" value=""}
                {assign var="header" value=""}
                {if $tipi_campi[$key|lower] == "integer"}
                    {assign var="sorter" value="number"}
                    {assign var="align" value="right"}
                    {assign var="formatter" value=", formatter:function(cell, formatterParams){ return parseInt(cell.getValue()); }"}
                {elseif $tipi_campi[$key|lower] == "number"}
                    {assign var="sorter" value="number"}
                    {assign var="align" value="right"}
                    {assign var="formatter" value=", formatter:function(cell, formatterParams){ return Number(cell.getValue()).toLocaleString(undefined, { minimumFractionDigits: 2 }); }"}
                {elseif $tipi_campi[$key|lower] == "datetime"}
                    {assign var="sorter" value="date"}
                    {assign var="align" value="right"}
                    {assign var="formatter" value=", formatterParams:{ inputFormat:'YYYY-MM-DD', outputFormat:'DD/MM/YYYY', invalidPlaceholder:'(invalid date)', }"}
                    {assign var="header" value=", headerFilter:dateFilterEditor, headerFilterFunc:dateFilterFunction "}
                
                {/if}
		
                { title:"{$key}", field:"{$key|lower}", headerFilter:true, sorter:"{$sorter}", align:"{$align}" {$formatter} {$header}},
                
            {/foreach}
            
        ],
        //rowClick:function(e, row){ //trigger an alert message when the row is clicked 
        //},
        ajaxFiltering:true,
        ajaxSorting:true,
        pagination:"remote", //enable remote pagination
        ajaxURL:"{$APP.url}/api", //set url for ajax request
        ajaxParams:{ token:"{$token}" }, //set any standard parameters to pass with the request
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
    

    //trigger download of data.xlsx file
    /*$("#download-xlsx").click(function (e) {
        tabulator_webonline.download("xlsx", "webonline.xlsx", { sheetName:"WebOnline" });
    });*/
    /*$("#download-xlsx").click(function (e) {
        e.stopPropagation();
        e.preventDefault();
        $.ajax({
            url: "{$APP.url}/api?token={$token}&page=1&size=1000000",
        }).done(function (result_json) {
            //result_data = JSON.parse(result_json);
            alert("Data result");
            // store the whole data into a global variable
            allData = result_json;//.data;
            console.log(allData);
            tabulator_webonline.download("xlsx", "webonline.xlsx", { sheetName:"WebOnline" });
        });
    });*/

    //trigger download of data.pdf file
    $("#download-pdf").click(function(){
        tabulator_webonline.download("pdf", "webonline.pdf", {
            orientation:"landscape", //set page orientation 
            title:"Report", //add title to report
        });
    });

});


//custom header filter
var dateFilterEditor = function(cell, onRendered, success, cancel, editorParams){

	var container = $("<span></span>")
	//create and style input
	var start = $("<input type='date' placeholder='Start'/>");
	var end = $("<input type='date' placeholder='End'/>");

	container.append(start).append(end);

	var inputs = $("input", container);


	inputs.css({
		"padding":"4px",
		"width":"50%",
		"box-sizing":"border-box",
	})
	.val(cell.getValue());

	function buildDateString(){
		return {
			start:start.val(),
			end:end.val(),
		};
	}

	//submit new value on blur
	inputs.on("change blur", function(e){
		success(buildDateString());
	});

	//submit new value on enter
	inputs.on("keydown", function(e){
		if(e.keyCode == 13){
			success(buildDateString());
		}

		if(e.keyCode == 27){
			cancel();
		}
	});

	return container[0];
}

//custom filter function
function dateFilterFunction(headerValue, rowValue, rowData, filterParams){
    //headerValue - the value of the header filter element
    //rowValue - the value of the column in this row
    //rowData - the data for the row being filtered
    //filterParams - params object passed to the headerFilterFuncParams property

   	var format = filterParams.format || "DD/MM/YYYY";
   	var start = moment(headerValue.start);
   	var end = moment(headerValue.end);
   	var value = moment(rowValue, format)
   	if(rowValue){
   		if(start.isValid()){
   			if(end.isValid()){
   				return value >= start && value <= end;
   			}else{
   				return value >= start;
   			}
   		}else{
   			if(end.isValid()){
   				return value <= end;
   			}
   		}
   	}

    return false; //must return a boolean, true if it passes the filter.
}



</script>


<a id="download-xlsx" class="ui basic button" href="{$APP.url}/export/xlsx?token={$token}&page=1&size=1000000">XLSX download</a>
{*<button id="download-xlsx" class="ui basic button" type="button">XLSX download integ</button>*}
<button id="download-pdf" class="ui basic button" type="button">PDF download</button>

<div id="example-table"></div>