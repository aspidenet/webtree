{extends file="template-private.tpl"}

{block name="html_head_extra"}
<script src="https://semantic-ui.com/javascript/library/tablesort.js"></script>

<script language="JavaScript" type="text/javascript">
$(function(){
    $('table').tablesort();
});
</script>
{/block}



{block name="content"}
{literal}
<!-- JAVASCRIPT -->
<SCRIPT LANGUAGE="JavaScript">
<!-- Begin
function setForm(myform, azione) {
  myform.azione.value = azione;
	//alert(myform.azione.value);//form.myform.azione.value = azione;
}
// End -->
</SCRIPT>

<style>
	.panel_button {
		text-align:center;
		border: 0px solid white;
		font-size:1.2em;
		font-weight:bold;
	}
    a {
        color: black;
	}
    a:hover {
        color: teal;
	}
    p { padding-top: 12px; }
</style>
{/literal}

<br />
<br />
<br />
<br />
<center>

	<table border="0" cellspacing="5" cellpadding="2">
		<tr>
            {foreach item=item from=$configurazione}
			<td class="ui segment panel_button"><a href="{$item.link}"><i class="{$item.icona} huge icon"></i><p>{$item.nome}</p></a></td>
            {/foreach}
			<td class="ui segment panel_button"><a href="{$APP_BASE_URL}"><i class="left arrow huge icon"></i><p>Indietro</p></a></td>
		</tr>
	</table>


<br />
<br />

</center>
<br />
<br />
<br />
<br />
{/block}