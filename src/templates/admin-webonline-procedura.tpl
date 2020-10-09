{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script language="JavaScript" type="text/javascript">
$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '/admin/webonline/procedura/{$record_code}/',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"procedura"}');
});

function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}
</script>
{/block}


{block name="content"}
<div style="margin: 20px 0px;">

    <div class="ui header">Procedura: <span class="ui orange">{$record_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        <a class="item" data-tab="procedura">Procedura</a>
        <a class="item" data-tab="parametri">Parametri</a>
        <a class="item" data-tab="auths">Auths</a>
    </div>
    
    <div class="ui bottom attached tab segment" data-tab="procedura">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="parametri">

    </div>
    
    
    <div class="ui bottom attached tab segment" data-tab="auths">

    </div>
    

</div>
{/block}


















{block name="contentxxx"}

{literal}
<script language="JavaScript" type="text/javascript">
$(function(){
    // Accordion
    $("#accordion").accordion({ header: "h3", heightStyle: 'fill', clearStyle: true, autoHeight: false });
});
</script>
{/literal}

{******************************************************************************************************
* TOOLBAR
******************************************************************************************************}
<div id="toolbar">
	<div class="tb_item_r"><button>Indietro</button></div>

	<div class="tb_item_r"><button class="button" type="submit">Associa gruppo</button></div>
    
    <div class="tb_item_r"><button class="button" type="submit">Aggiungi parametro</button></div>
</div>

{******************************************************************************************************
* ACCORDION
******************************************************************************************************}
<div style="clear:both; padding:10px;">
<div id="accordion">
	<h2>Gestione PROCEDURA</h2>
	<div>
		<h3><a href="#">Dati procedura</a></h3>
		<div>
			<button class="button" type="submit">Modifica</button>
		</div>
	</div>

	
	{******************************************************************************************************
	* PARAMETRI
	******************************************************************************************************}
	<div>
		<h3><a href="#">Parametri associati alla procedura</a></h3>
		<div>

{foreach name=i key=key item=item from=$parametri}
	{if $smarty.foreach.i.first}
	<table cellspacing='0' cellpadding="5">
	<tr>
    <td></td>
		<td class='a_azzurro'>&nbsp;&nbsp;&nbsp;&nbsp;</td>

		<td class='n_azzurro centrato grassetto'>Ordine</td>
		<td class='n_azzurro centrato grassetto'>Parametro</td>
		<td class='n_azzurro centrato grassetto'>Descrizione</td>
		<td class='n_azzurro centrato grassetto'>Tipo</td>
		<td class='n_azzurro centrato grassetto'>Opzionale</td>
		<td class='n_azzurro centrato grassetto'>Help breve</td>
		<td class='n_azzurro centrato grassetto'>Help lungo</td>
		<td class='n_azzurro centrato grassetto'>Invisibile</td>
		
    <td class='n_azzurro centrato grassetto'>Tabella</td>
		<td class='n_azzurro centrato grassetto'>Distinto</td>
		<td class='n_azzurro centrato grassetto'>Campo valore</td>
		<td class='n_azzurro centrato grassetto'>Campo descrizione</td>
		<td class='n_azzurro centrato grassetto'>Ordinamento</td>
		<td class='n_azzurro centrato grassetto'>Filtro</td>
		<td class='n_azzurro centrato grassetto'>Default</td>
		<td class='n_azzurro centrato grassetto'>SP</td>
		<td class='n_azzurro centrato grassetto'>Nome</td>
		<td class='n_azzurro centrato grassetto'>Parametri</td>
		<td class='p_azzurro'>&nbsp;&nbsp;&nbsp;&nbsp;</td>
	</tr>
	{/if}
  
	{cycle assign="riga" values='light,dark'}

	<tr>
		<td><form name="frmModificaParametro{$smarty.foreach.i.index}" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="MODIFICA PARAMETRO" />
				<input type="hidden" name="code" value="{$item.code}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="classe" value="MetaParametro" />
				<input type="hidden" name="link_ok" value="admin/{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="admin/{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="admin/{$pagina.corrente}" />

				<button class="button" type="submit">Modifica</button>
		</form></td>
    
    <td><form name="frmEliminaParametro{$smarty.foreach.i.index}" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="ELIMINA PARAMETRO" />
				<input type="hidden" name="code" value="{$item.code}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="elimina" value="1" />
				<input type="hidden" name="classe" value="MetaParametro" />
				<input type="hidden" name="link_ok" value="admin/{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="admin/{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="admin/{$pagina.corrente}" />

				<button class="button" type="submit">Elimina</button>
		</form></td>

    <td class="bg_{$riga}white centrato grassetto">{$item.ordine}</td>
		<td class="bg_{$riga}white sx grassetto">{$item.codparametro}</td>
		<td class="bg_{$riga}white sx">{$item.descrizione|default:"nessuna anagrafica correlata"}</td>
		<td class="bg_{$riga}white centrato grassetto">{$item.tipo}</td>
		<td class="bg_{$riga}white centrato grassetto">{$item.opzionale}</td>
		<td class="bg_{$riga}white sx note">{$item.help_breve}</td>
		<td class="bg_{$riga}white sx note">{$item.help_lungo}</td>
		<td class="bg_{$riga}white sx">{$item.invisibile}</td>
		
    <td class="bg_{$riga}white sx">{$item.tabella_rif}</td>
		<td class="bg_{$riga}white sx">{$item.distinto}</td>
		<td class="bg_{$riga}white sx">{$item.campo_valore}</td>
		<td class="bg_{$riga}white sx">{$item.campo_descrizione}</td>
		<td class="bg_{$riga}white sx">{$item.ordinamento}</td>
		<td class="bg_{$riga}white sx">{$item.filtro}</td>
		<td class="bg_{$riga}white sx">{$item.valore_default}</td>
		
    <td class="bg_{$riga}white sx">{$item.sp}</td>
		<td class="bg_{$riga}white sx">{$item.nomesp}</td>
		<td class="bg_{$riga}white sx">{$item.parametrisp}</td>
		<td>&nbsp;</td>

	</tr>

{if $smarty.foreach.i.last}
	</table>
{/if}

{foreachelse}
<p>Nessun parametro richiesto.</p>
{/foreach}
		</div>
	</div>

  {******************************************************************************************************
	* GRUPPI
	******************************************************************************************************}
	<div>
		<h3><a href="#">Gruppi associati alla procedura</a></h3>
		<div>

{foreach name=i key=key item=item from=$gruppi}
	{if $smarty.foreach.i.first}
	<table cellspacing='0' cellpadding="5">
	<tr>
		<td class='a_azzurro'>&nbsp;&nbsp;&nbsp;&nbsp;</td>

		<td class='n_azzurro centrato grassetto'>ID</td>
		<td class='n_azzurro centrato grassetto'>Codice</td>
		<td class='n_azzurro centrato grassetto'>Gruppo</td>
		<td class='n_azzurro centrato grassetto'>Tipo</td>
		<td class='p_azzurro'>&nbsp;&nbsp;&nbsp;&nbsp;</td>
	</tr>
	{/if}

	{cycle assign="riga" values='light,dark'}

	<tr class="">
		<td><form name="frmEliminaGruppo{$smarty.foreach.i.index}" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="ELIMINA ASSOCIAZIONE GRUPPO" />
				<input type="hidden" name="code" value="{$key}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="elimina" value="1" />
				<input type="hidden" name="classe" value="MetaRelazione" />
				<input type="hidden" name="link_ok" value="admin/{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="admin/{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="admin/{$pagina.corrente}" />

				<button class="button" type="submit">Elimina</button>
		</form></td>

    <td class="bg_{$riga}white centrato grassetto">{$item.ident}</td>
		<td class="bg_{$riga}white sx grassetto">{$item.code}</td>
		<td class="bg_{$riga}white sx">{$item.label|default:"nessuna anagrafica correlata"}</td>
		<td class="bg_{$riga}white centrato grassetto">{$item.tipo}</td>
		<td>&nbsp;</td>

	</tr>

{if $smarty.foreach.i.last}
	</table>
{/if}

{foreachelse}
<p>Nessun gruppo associato alla procedura.</p>
{/foreach}
		</div>
	</div>

  
</div>
</div>
{/block}