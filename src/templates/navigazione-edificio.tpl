<h2>{$template->label()}</h2>

<table class="ui definition collapsing table">
<thead>
</thead>
<tbody>
    {foreach name="c" key="key" item="campo" from=$record}
    <tr>
        <td class="collapsing">{$X->writeHead($key)}</td>
        {$X->writeValue($campo, $key, $riga)}
    </tr>    
    {/foreach}
</tbody>
</table>

{if isset($foto)}
<h2>Foto</h2>
<img src="{$foto}" />
{/if}

<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
//google.load('visualization', '1', { 'packages':['corechart','table','imagechart'] });
//google.setOnLoadCallback(Init);
google.charts.load('current', { packages: ['corechart'] });
google.charts.setOnLoadCallback(init);

$(function(){
   
});
var chart, chart2;

function init() {
    disegnaQuadranteNavigazioneEdificiDDU();
    drawChart();
}

// ***********************************************************************************
// QUADRANTE CDC EDIFICI
// ***********************************************************************************
function disegnaQuadranteNavigazioneEdificiDDU() {
    var jsondata = $.ajax({
        url: "/dashboard-funzionamento/json/1110001/{$record_code}",
        dataType:"json",
        async: false
    }).responseText;
    data = new google.visualization.DataTable(jsondata);
    chart = new google.visualization.ColumnChart(document.getElementById('quadrante_navigazione_edifici_ddu'));
    
    var options = {
        title : "DDU",
        vAxis: { title: "Superfici (mq)" },
        hAxis: { title: "DDU" },
        chartArea: { left:160,width:"60%",height:"65%" },
        height:400,
        tooltip: { textStyle:  {  fontSize: 9, bold: false } },
        legend: { textStyle:  {  fontSize: 9, bold: false } }
    };
    
    //google.visualization.events.addListener(chart, 'select', selectHandlerCdcEdificiDDU);
    chart.draw(data, options);
}
function drawChart() {

    var jsondata = $.ajax({
        url: "/dashboard-funzionamento/json/pie/1110001/{$record_code}",
        dataType:"json",
        async: false
    }).responseText;
    data2 = new google.visualization.DataTable(jsondata);
    chart2 = new google.visualization.PieChart(document.getElementById('quadrante_navigazione_edifici_ddu_torta'));
    

    var options = {
        title : "DDU",
        vAxis: { title: "Superfici (mq)" },
        hAxis: { title: "DDU" },
        chartArea: { left:160,width:"60%",height:"65%" },
        height:400,
        tooltip: { textStyle:  {  fontSize: 9, bold: false } },
        legend: { textStyle:  {  fontSize: 9, bold: false } },
        //sliceVisibilityThreshold: .2
    };

      chart2.draw(data2, options);
    }

</script>

<h2>Distribuzione DDU nell'edificio</h2>
<div id="quadrante_navigazione_edifici_ddu" style="border:0px solid blue;"></div>
<div id="quadrante_navigazione_edifici_ddu_torta" style="border:0px solid red;"></div>