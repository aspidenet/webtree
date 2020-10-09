{extends file="webonline-config-panel.tpl"}

{block name="content"}

{if $pagina.sezione == 'X'}{assign var="titolo_nuovo" value="Nuova esportazione"}
{elseif $pagina.sezione == 'S'}{assign var="titolo_nuovo" value="Nuovo report"}
{elseif $pagina.sezione == 'M'}{assign var="titolo_nuovo" value="Nuovo documento"}
{/if}

{*<div id="toolbar">
	<div class="tb_item">
		<form name="frmNuovaProcedura" method="POST" action="../oggetto.php">
			<input type="hidden" name="titolo" value="{$titolo_nuovo}" />
			<input type="hidden" name="code" value="" />
			<input type="hidden" name="padre" value="" />
			<input type="hidden" name="relazione" value="" />
			<input type="hidden" name="classe" value="MetaProceduraLight" />
			<input type="hidden" name="link_ok" value="{$MODULO.url}procedura.php?code=%CODEOGGETTO%" />
			<input type="hidden" name="link_fail" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />
			<input type="hidden" name="link_indietro" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />
            
			<input type="hidden" name="pc" value="1" />
			<input type="hidden" name="pn0" value="tipo" />
			<input type="hidden" name="pv0" value="{$pagina.sezione}" />

			<button class="ui basic button" type="submit"><i class="add icon"></i> {$titolo_nuovo}</button>
		</form>
	</div>
	<div class="tb_item">
		{$history->buttonIndietro()}
	</div>
</div>

<div style="clear:both; border-bottom: 2px solid teal;"></div>*}


<div style="overflow-x: scroll;">
<table class="ui striped stackable celled very compact table datatable">
	<thead>
        <tr>
            <th colspan="6">
                  <div class="ui LEFT floated pagination menu">
                    <a class="{if $pagina.sezione == 'X'}active{/if} item" href="procedure.php?tab=X" title="Web Online"><i class="database icon"></i> Esportazioni Excel, CSV, PDF</a>
                    <a class="{if $pagina.sezione == 'S'}active{/if} item" href="procedure.php?tab=S" title="Report"><i class="print icon"></i> Report</a>
                    <a class="{if $pagina.sezione == 'M'}active{/if} item" href="procedure.php?tab=M" title="Documentazione"><i class="book icon"></i> Documentazione</a>
                  </div>
            </th>
        </tr>
        <tr class="">
            <th colspan="99">
                <div style="float: left;">
                    <form name="frmNuovaProcedura" method="POST" action="../oggetto.php">
                        <input type="hidden" name="titolo" value="{$titolo_nuovo}" />
                        <input type="hidden" name="code" value="" />
                        <input type="hidden" name="padre" value="" />
                        <input type="hidden" name="relazione" value="" />
                        <input type="hidden" name="classe" value="MetaProceduraLight" />
                        <input type="hidden" name="link_ok" value="{$MODULO.url}procedura.php?code=%CODEOGGETTO%" />
                        <input type="hidden" name="link_fail" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />
                        <input type="hidden" name="link_indietro" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />
                        
                        <input type="hidden" name="pc" value="1" />
                        <input type="hidden" name="pn0" value="tipo" />
                        <input type="hidden" name="pv0" value="{$pagina.sezione}" />

                        <button class="ui basic button" type="submit"><i class="add icon"></i> {$titolo_nuovo}</button>
                    </form>
                </div>
                <div style="float: right;"><a href="index.php" class="ui basic button"><i class="icon left arrow"></i> Indietro</a></div>
            </th>
        </tr>
        <tr class="">
            <th colspan="99" class="ui header center aligned">Web Online</th>
        </tr>
        <tr>
            <th class="collapsing">ID</th>
            <th class="">Azioni</th>
            <th class="">Categoria</th>
            <th class="">{if $pagina.sezione == 'X'}Esportazione Excel, CSV, PDF
                {elseif $pagina.sezione == 'S'}Report
                {elseif $pagina.sezione == 'M'}Documento
                {/if}</th>
            <th class="">Descrizione / Help in linea</th>
            <th class="collapsing center aligned">Nr. param.</th>
        </tr>
    </thead>
    <tbody>
    
    
{foreach name=e item=item key=key from=$procedure}
	{if $smarty.foreach.e.first}
	
    {/if}

		<tr>
			<td>{$item.ident}</td>
            <td>
                <div style="float: left;">
                    <a href="{$APP_BASE_URL}{$APP.url}/procedura/{$item.code}" class="ui basic button"><i class="write icon" title="Modifica"></i></a>
                </div>
                <div style="float: left;">
                    <form name="frmNuovaProcedura" method="POST" action="../oggetto.php">
                        <input type="hidden" name="titolo" value="Elimina" />
                        <input type="hidden" name="code" value="{$item.code}" />
                        <input type="hidden" name="padre" value="" />
                        <input type="hidden" name="elimina" value="1" />
                        <input type="hidden" name="classe" value="MetaProceduraLight" />
                        <input type="hidden" name="link_ok" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />
                        <input type="hidden" name="link_fail" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />
                        <input type="hidden" name="link_indietro" value="{$MODULO.url}procedure.php?tab={$pagina.tab}" />

                        <button class="ui basic button" type="submit" title="Elimina"><i class="remove icon"></i></button>
                    </form>
                </div>
            </td>
            <td>{$item.label_categoria}</td>
			<td>{$item.label0}<br>
                <i><span style="font-size:0.9em; color:teal;">{$item.sp}</span></i></td>
            <td>{if $item.help_lungo0|count_characters>0}{$item.help_lungo0|escape:'html'}{else}-{/if}</td>
			<td class="center aligned">{$item.paramcount}</td>
		</tr>

	{if $smarty.foreach.e.last}
		
	{/if}

{foreachelse}
<tr>
    <td></td>
	<td colspan="20">Nessuna procedura esistente.</td>
</tr>
{/foreach}
    </tbody>
</table>
</div>

</center>

{/block}