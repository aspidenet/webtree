<h2>{$template->label()}</h2>

<table class="ui definition collapsing table">
<thead>
</thead>
<tbody>
    {foreach name="c" key="key" item="campo" from=$record}
    <tr>
        <td class="collapsing">{$X->writeHead($key, $recordset[$key])}</td>
        {$X->writeValue($campo, $key, $riga)}
    </tr>    
    {/foreach}
</tbody>
</table>
