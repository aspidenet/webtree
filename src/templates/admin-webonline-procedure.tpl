{extends file="template-private.tpl"}

{block name="content"}

<script language="JavaScript" type="text/javascript">
$(function(){
});
function onHideNewProcedure() {
    var url = "/admin/webonline/procedure";
    redirect(url);
}
</script>


{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <button onclick="modal_popup_url('/admin/template/METAPROCEDURES/new', onHideNewProcedure)" class="ui green button"><i class="add icon"></i> Nuova procedura</button>   
    <button onclick="modal_popup_url('/wizard/metaprocedures/new?return_url={$return_url_encoded}', onHideNewProcedure)" class="ui green button"><i class="add icon"></i> Nuova procedura</button>   
    
</div>
{* fine tastoni *}


<div style="clear:both;"></div>

<center>

<h2>Elenco procedure {$application}</h2>
<br>

<table cellspacing='2'>
	<tr>
		<td class="bottone_lettera {if $pagina.sezione == 'X'} bl_current{/if}"><a href="procedure.php?tab=X" title="Procedure di estrazione dati">X</a></td>
		<td class="bottone_lettera {if $pagina.sezione == 'S'} bl_current{/if}"><a href="procedure.php?tab=S" title="Stampe">S</a></td>
		<td class="bottone_lettera {if $pagina.sezione == 'D'} bl_current{/if}"><a href="procedure.php?tab=D" title="Dashboard">D</a></td>
		<td class="bottone_lettera {if $pagina.sezione == 'M'} bl_current{/if}"><a href="procedure.php?tab=M" title="Manualistica/documentazione">M</a></td>
		<!--td class="bottone_lettera {if $pagina.sezione == 'R'} bl_current{/if}"><a href="procedure.php?tab=R" title="Procedure di estrazione in lettura">R</a></td>
		<td class="bottone_lettera {if $pagina.sezione == 'W'} bl_current{/if}"><a href="procedure.php?tab=W" title="Procedure di estrazione da prenotare">W</a></td-->
		<td class="bottone_lettera {if $pagina.sezione == 'T'} bl_current{/if}"><a href="procedure.php?tab=T" title="Tabelle">T</a></td>
	</tr>
</table>

<br />

<center>
{assign var="categoria_precedente" value=""}
{foreach name=e item=item key=key from=$procedure}
	{if $smarty.foreach.e.first}
	<table cellspacing='0' cellpadding="2">
	{/if}

	{if $item.label_categoria != $categoria_precedente OR $smarty.foreach.e.first}
		<tr>
			<td></td>
		</tr>
		<tr>
			<td></td>
			<td class="ui-widget-header-blu ui-corner-all centrato" colspan="2">{$item.label_categoria}</td>
		</tr>
		
		<tr>
			<td></td>
			<td class='intestazione_minuta bg_blu bianco centrato ui-corner-left'>Cod.</td>
			<td class='intestazione_minuta bg_blu bianco sx ui-corner-right'>Titolo procedura</td>
			
		</tr>
	{/if}
		{cycle assign="riga" values='bg_bianco,bg_darkwhite'}
		<tr>
			<td>{if $item.help_lungo0|count_characters>0}
        <img src='images/info24.png' width="24" height="24" title="{$item.help_lungo0|escape:'javascript'}">{/if}</td>
			<td class="{$riga}">{$item.ident}</td>
			<td class="{$riga} sx grassetto">{$item.label0}{if $operatore->admin()}<br><span class="note arancio">{$item.sp}</span>{/if}</td>
			<td><a href="{$WOLPATH}/procedura/{$item.code}" class="ui button">Modifica</a></td>
		</tr>

	{assign var="categoria_precedente" value=$item.label_categoria}

	{if $smarty.foreach.e.last}
		</table>
	{/if}

{foreachelse}
<h2>Nessuna procedura esistente.</h2>
{/foreach}
</center>

<hr>

<div style="clear:both;">
    {foreach item=item key=key from=$procedure}
            
        {assign var="target" value=""}
        {assign var="bg" value="#FFF"}
        {if $item.tipo == 'X'}
            {assign var="link_procedura" value="/procedura/"|cat:$key}
            {assign var="bg" value="#FFF"}
            {assign var="icon" value="database"}
        {elseif $item.tipo == 'M'}
            {assign var="link_procedura" value=$ROOT_DIR|cat:$item.codice}
            {assign var="target" value=" target='_blank' "}
            {assign var="bg" value="#E4DDEB"}
            {assign var="icon" value="book"}
        {elseif $item.tipo == 'D'}
            {assign var="link_procedura" value=$ROOT_DIR|cat:"dashboard/"|cat:$item.codice}
            {assign var="target" value=" target='_blank' "}
            {assign var="bg" value="#EBDDDD"}
            {assign var="icon" value="chart bar"}
        {elseif $item.tipo == 'R'}
            {assign var="link_procedura" value=$item.codice}
            {assign var="target" value=" target='_blank' "}
            {assign var="bg" value="#E4EBDD"}
            {assign var="icon" value="print"}
        {else}
            {assign var="link_procedura" value=$ROOT_DIR}
            {assign var="bg" value="#E4EBDD"}
            {assign var="icon" value="database"}
        {/if}
            
        <div class="ui icon message" style="background:{$bg};">
            <a href="{$WOLPATH}/procedura/{$item.code}" {$target}><i class="huge {*if $item.path_icona}{$item.path_icona}{else}database{/if*}{$icon} icon"></i></a>
            <div class="content">
                <div class="header"><a href="{$ROOT_URL}{$APP.url}{$link_procedura}" {$target}><h3>{$item.descrizione}</h3></a></div>
                <p><b>ID interno: {$item.id}</b><br>
                    {$item.help}</p>
                <p>{$item.codice}</p>
                {*<p>{$link_procedura}</p>*}
            </div>
        </div>
            
        
      

    {foreachelse}
        Nessuna procedura disponibile per l'utente.
    {/foreach}
</div> 


{/block}