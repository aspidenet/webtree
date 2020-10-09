
{**}
{if $count > 0 AND $count < 1000}
<div class="tb_item_r">
	<form action="pdf.php" method="POST">
		<button type="submit" class="ui basic button" title="Esporta in formato PDF"><i class="icon file pdf outline"></i> Esporta in PDF</button>
	</form>
</div>
{/if}
{if $count > 0}
<div class="tb_item_r">
	<form action="esporta.php?ex=csv&mod={$modulo_code}" method="POST">
		<button type="submit" class="ui basic button" title="Esporta in formato CSV."><i class="icon file text outline"></i> Esporta in CSV</button>
	</form>
</div>
{/if}
{if $count > 0 AND $count < 4000}
<div class="tb_item_r">
	<form action="esporta.php?ex=xls&mod={$modulo_code}" method="POST">
		<button type="submit" class="ui basic button" title="Esporta in formato Excel 97/2003 (XLS)"><i class="icon file excel outline"></i> Esporta in XLS</button>
	</form>
</div>
{/if}
<div class="tb_item_r">
	<form action="{$target_page}" method="POST">
		<button type="submit" class="ui basic button" name="btnIndietro" title="Indietro"><i class="icon left arrow"></i> Indietro</button>
	</form>
</div>

<!--style>
td, form { border: 1px solid red; margin: 0px; padding: 0px; }
</style-->

{*if $pagine>1}
<div style="clear:both; max-width:100%;">
{section name=l loop=$pagine}

	{if $smarty.section.l.first}
	<table cellspacing='0' cellpadding="1" style="width: 100%;">
    <tr>
	{elseif $smarty.section.l.index mod 30 == 0}
		</tr><tr>
	{/if}

        <td class="centrato">
			{if $pagina != $smarty.section.l.index}<form id="VaiAllaPagina{$smarty.section.l.index}" name="VaiAllaPagina{$smarty.section.l.index}" method="POST" action="{$target_page}">
				<input type="hidden" name="fase" value="3" />
				<input type="hidden" name="pagina" value="{$smarty.section.l.index}" />
				<button type="button" class="ui basic button" title="Cambia pagina" onclick="OnVaiAllaPagina_Click('VaiAllaPagina{$smarty.section.l.index}');" style="margin:0px; padding:6px;">{$smarty.section.l.index + 1}</button>
			</form>
            {else}<form><button class="ui teal button" style="margin:0px; padding:6px;">{$pagina+1}</button></form>{/if}
		</td>
	{if $smarty.section.l.last}
		</tr></table>
	{/if}
{/section}
</div>
{/if*}


<div class="ui pagination menu">
{if $pagine>1 && $pagine <= 20}
    {section name=l loop=$pagine}
        {assign var="page_number" value=$smarty.section.l.index + 1}
        <a class="{if $pagina == $smarty.section.l.index}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina={$smarty.section.l.index}', 'risultati_estrazione');">{$page_number}</a>
    {/section}
{elseif $pagine>1}
        <a class="{if $pagina == 0}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina=0', 'risultati_estrazione');">1</a>
    
    {if $pagina < 7}
        {section name=l start=1 loop=10}
            {assign var="page_number" value=$smarty.section.l.index + 1}
            <a class="{if $pagina == $smarty.section.l.index}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina={$smarty.section.l.index}', 'risultati_estrazione');">{$page_number}</a>
        {/section}
        <div class="disabled item">...</div>
    {elseif $pagina > $pagine -5}
        
        <div class="disabled item">...</div>
        {section name=l start=$pagine-9 loop=$pagine-1}
            {assign var="page_number" value=$smarty.section.l.index + 1}
            <a class="{if $pagina == $smarty.section.l.index}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina={$smarty.section.l.index}', 'risultati_estrazione');">{$page_number}</a>
        {/section}
        
    {else}   
        <div class="disabled item">...</div>
        {section name=l start=$pagina-5 loop=$pagina}
            {assign var="page_number" value=$smarty.section.l.index + 1}
            <a class="{if $pagina == $smarty.section.l.index}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina={$smarty.section.l.index}', 'risultati_estrazione');">-{$page_number}</a>
        {/section}
        {section name=l start=$pagina loop=$pagina+6}
            {assign var="page_number" value=$smarty.section.l.index + 1}
            <a class="{if $pagina == $smarty.section.l.index}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina={$smarty.section.l.index}', 'risultati_estrazione');">+{$page_number}</a>
        {/section}
        <div class="disabled item">...</div>
    {/if}
    
        <a class="{if $pagina == $pagine-1}active{/if} item" onclick="ReloadDIV('{$target_page}', 'fase=3&pagina={$pagine-1}', 'risultati_estrazione');">{$pagine}</a>
{/if}
</div>


<br />

{******************************************************************************}
{foreach name=i key=offset item=record from=$records}
	{if $smarty.foreach.i.first}
	<div style="clear:both; overflow-x:scroll;">
	<table class="ui striped stackable celled  very compact table">
    <thead>
		<tr>
			<th class=''>&nbsp;&nbsp;&nbsp;</td>
		{foreach name="c" key="nome" item="item" from=$record}
            {$X->writeHead($nome)}
		{/foreach}
		</tr>
	</thead>
    <tbody>
	{/if}
	
	{assign var="colore" value="white"}
	{assign var="forecolore" value="nero"}
	{if isset($record.wmflag_controllo)}
		{if $record.wmflag_controllo == 1}
			{assign var="colore" value="yellow"}
			{assign var="forecolore" value="nero"}
		{elseif $record.wmflag_controllo == 2}
			{assign var="colore" value="red"}
			{assign var="forecolore" value="bianco"}
		{elseif $record.wmflag_controllo == 3}
			{assign var="colore" value="gray"}
			{assign var="forecolore" value="bianco"}
		{elseif $record.wmflag_controllo == 4}
			{assign var="colore" value="black"}
			{assign var="forecolore" value="bianco"}
		{else}
			{assign var="colore" value="white"}
			{assign var="forecolore" value="nero"}
		{/if}
	{/if}
    
	<tr>
		<td><span class="ui teal circular label" style="font-size:0.7em;">{$offset+1}</span></td>
		{foreach name="c" key="key" item="campo" from=$record}
		
			{*if $tipi_campi[$key|lower] == "numero"}{assign var="allineamento" value="dx"}
			{elseif $tipi_campi[$key|lower] == "data"}{assign var="allineamento" value="centrato"}
			{else}{assign var="allineamento" value="sx"}
			{/if}  
			
			
			{if $tipi_campi[$key|lower] == "data"}
            <td class='bg_{$riga}{$colore} {$forecolore} {$allineamento} note'>{$campo|date_format:"%d/%m/%Y"}</td>
			{elseif $key != "wmflag_controllo"}
			<td class='bg_{$riga}{$colore} {$forecolore} {$allineamento} note'>{$X->checkLink($campo, $key)}</td>
			{/if*}
            
            
            {$X->writeValue($campo, $key, '')}
            
		{/foreach}
	</tr>
	
	{if $smarty.foreach.i.last}
    </tbody>
    </table>
    </div>
	{/if}
{foreachelse}
<h2>Nessun record presente.</h2>
{/foreach}
{******************************************************************************}
</center>