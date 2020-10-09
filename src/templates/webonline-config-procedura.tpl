{extends file="panel_manager.tpl"}

{block name="content"}

{literal}
<script language="JavaScript" type="text/javascript">
$(function(){
    $('.menu .item')
      .tab()
    ;
});
</script>
{/literal}


{******************************************************************************************************
* TOOLBAR
******************************************************************************************************}
<div id="toolbar">
    {if $metaprocedura->get('tipo') == 'X'}
        <div class="tb_item"><form name="frmNuovoParametro" method="POST" action="../oggetto.php">
            <input type="hidden" name="titolo" value="NUOVO PARAMETRO" />
            <input type="hidden" name="code" value="" />
            <input type="hidden" name="padre" value="" />
            <input type="hidden" name="relazione" value="" />
            <input type="hidden" name="classe" value="MetaParametroLight" />
            <input type="hidden" name="link_ok" value="{$MODULO_URL}{$pagina.corrente}" />
            <input type="hidden" name="link_fail" value="{$MODULO_URL}{$pagina.corrente}" />
            <input type="hidden" name="link_indietro" value="{$MODULO_URL}{$pagina.corrente}" />
            
            <input type="hidden" name="pc" value="1" />
            <input type="hidden" name="pn0" value="code_sp" />
            <input type="hidden" name="pv0" value="{$metaprocedura->code()}" />

            <button class="ui basic button" type="submit"><i class="add icon"></i> Aggiungi parametro</button>
		</form></div>
    {/if}

	<div class="tb_item"><form name="frmAggiungiGruppo" action="associa_record.php" method="POST">
		<input type="hidden" name="relazione" value="GRUPPO-PROCEDURA" />
		<input type="hidden" name="figlio" value="{$metaprocedura->code()}" />
		<input type="hidden" name="classe" value="MetaGruppo" />
		<button class="ui basic button" type="submit"><i class="add icon"></i> Associa gruppo</button>
	</form></div>
	<div class="tb_item">{$history->buttonIndietro()}</div>
</div>


<div class="ui header" style="clear:both; ">
    <h2>{if $metaprocedura->get('tipo') == 'X'}Esportazione Excel, CSV, PDF
        {elseif $metaprocedura->get('tipo') == 'S'}Report
        {elseif $metaprocedura->get('tipo') == 'M'}Documento
        {/if}</h2>
</div>

<div class="ui top attached tabular menu">
  <a class="active item" data-tab="tab_procedura">Propriet&agrave;</a>
  {if $metaprocedura->get('tipo') == 'X'}
  <a class="item" data-tab="tab_parametri">Parametri di filtro</a>
  {/if}
  <a class="item" data-tab="tab_gruppi">Gruppi in cui &egrave; visibile</a>
</div>


{******************************************************************************************************
* ACCORDION
******************************************************************************************************}

    <div class="ui bottom attached active tab segment" data-tab="tab_procedura">
		<div>
			{$metaprocedura->display("", "", "", true)}

			<form name="frmModifica" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="Modifica" />
				<input type="hidden" name="code" value="{$metaprocedura->code()}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="classe" value="MetaProceduraLight" />
				<input type="hidden" name="link_ok" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="{$MODULO_URL}{$pagina.corrente}" />

				<button class="ui basic button" type="submit"><i class="write icon"></i> Modifica</button>
			</form>
		</div>
	</div>

	{if $metaprocedura->id()}
	{******************************************************************************************************
	* PARAMETRI
	******************************************************************************************************}
	<div class="ui bottom attached tab segment" data-tab="tab_parametri">
		<div>

{foreach name=i key=key item=item from=$parametri}
	{if $smarty.foreach.i.first}
	<table class="ui striped stackable celled  very compact table">
    <thead>
        <tr class="">
            <th class="collapsing"></th>
            <th class="collapsing"></th>
            <th class="collapsing">Ordine</th>
            <th class="collapsing">Nome</th>
            <th class="collapsing">Parametro</th>
            {*<th>Descrizione</th>*}
            <th class="collapsing">Tipo</th>
            <th class="collapsing"><span title="Opzionale">Opz.</span></th>
            <th class="">Help breve</td>
            <th class="">Help lungo</td>
            {*<th class="collapsing">Invisibile</td>
            
            <th class="collapsing">Tabella</th>
            <th class="collapsing">Distinto</th>
            <th class="collapsing">Campo valore</th>
            <th class="collapsing">Campo descrizione</th>
            <th class="collapsing"><span title="Ordinamento">Ord.</span></th>
            <th class="collapsing">Filtro</th>
            <th class="collapsing">Default</th>
            <th class="collapsing">SP</th>
            <th class="collapsing">Nome</th>
            <th class="collapsing">Parametri</th>*}
        </tr>
    </thead>
    <tbody>
	{/if}
  
	{cycle assign="riga" values='light,dark'}

	<tr>
		<td><form name="frmModificaParametro{$smarty.foreach.i.index}" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="MODIFICA PARAMETRO" />
				<input type="hidden" name="code" value="{$item.code}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="classe" value="MetaParametroLight" />
				<input type="hidden" name="link_ok" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="{$MODULO_URL}{$pagina.corrente}" />

				<button class="ui basic button" type="submit"><i class="icon write"></i></button>
		</form></td>
    
        <td><form name="frmEliminaParametro{$smarty.foreach.i.index}" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="ELIMINA PARAMETRO" />
				<input type="hidden" name="code" value="{$item.code}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="elimina" value="1" />
				<input type="hidden" name="classe" value="MetaParametroLight" />
				<input type="hidden" name="link_ok" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="{$MODULO_URL}{$pagina.corrente}" />

				<button class="ui basic button" type="submit"><i class="icon remove"></i></button>
		</form></td>

        <td class="bg_{$riga}white centrato grassetto">{$item.ordine}</td>
		{*<td class="bg_{$riga}white sx grassetto">{$item.codparametro}</td>*}
        <td class="bg_{$riga}white centrato grassetto">{$item.nome}</td>
		<td class="bg_{$riga}white sx">{$item.descrizione|default:""}</td>
		<td class="bg_{$riga}white centrato grassetto">{$item.tipo}</td>
		<td class="bg_{$riga}white centrato grassetto">{$item.opzionale}</td>
		<td class="bg_{$riga}white sx note">{$item.help_breve}</td>
		<td class="bg_{$riga}white sx note">{$item.help_lungo}</td>
		{*<td class="bg_{$riga}white sx">{$item.invisibile}</td>
		
        <td class="bg_{$riga}white sx">{$item.tabella_rif}</td>
		<td class="bg_{$riga}white sx">{$item.distinto}</td>
		<td class="bg_{$riga}white sx">{$item.campo_valore}</td>
		<td class="bg_{$riga}white sx">{$item.campo_descrizione}</td>
		<td class="bg_{$riga}white sx">{$item.ordinamento}</td>
		<td class="bg_{$riga}white sx">{$item.filtro}</td>
		<td class="bg_{$riga}white sx">{$item.valore_default}</td>
		
        <td class="bg_{$riga}white sx">{$item.sp}</td>
		<td class="bg_{$riga}white sx">{$item.nomesp}</td>
		<td class="bg_{$riga}white sx">{$item.parametrisp}</td>*}

	</tr>

{if $smarty.foreach.i.last}
    </tbody>
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
	<div class="ui bottom attached tab segment" data-tab="tab_gruppi">
		<div>

{foreach name=i key=key item=item from=$gruppi}
	{if $smarty.foreach.i.first}
	<table class="ui striped sortable stackable celled padded table">
    <thead>
        <tr>
            <th class="collapsing"></th>
            <th class="collapsing">ID</th>
            <th>Gruppo</th>
        </tr>
    </thead>
    <tbody>
	{/if}

	{cycle assign="riga" values='light,dark'}

	<tr class="">
		<td><form name="frmEliminaGruppo{$smarty.foreach.i.index}" method="POST" action="../oggetto.php">
				<input type="hidden" name="titolo" value="ELIMINA ASSOCIAZIONE GRUPPO" />
				<input type="hidden" name="code" value="{$key}" />
				<input type="hidden" name="padre" value="" />
				<input type="hidden" name="relazione" value="" />
				<input type="hidden" name="elimina" value="1" />
				<input type="hidden" name="classe" value="SYSRelazione" />
				<input type="hidden" name="link_ok" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_fail" value="{$MODULO_URL}{$pagina.corrente}" />
				<input type="hidden" name="link_indietro" value="{$MODULO_URL}{$pagina.corrente}" />

				<button class="ui basic button" type="submit"><i class="icon remove"></i> Elimina</button>
		</form></td>

    <td class="bg_{$riga}white centrato grassetto">{$item.ident}</td>
		<td class="bg_{$riga}white sx">{$item.label|default:"nessuna anagrafica correlata"}</td>
	</tr>

{if $smarty.foreach.i.last}
    </tbody>
	</table>
{/if}

{foreachelse}
<p>Nessun gruppo associato alla procedura.</p>
{/foreach}
		</div>
	</div>
{/if}
  
{/block}