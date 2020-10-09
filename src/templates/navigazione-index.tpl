{extends file="template-private.tpl"}


{block name="content"}
{literal}
<!-- JAVASCRIPT -->
<SCRIPT LANGUAGE="JavaScript">
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
			<td class="ui segment panel_button"><a href="{$APP.url}/elenco/USER"><i class="user huge icon"></i><p>Utenti</p></a></td>
			<td class="ui segment panel_button"><a href="{$APP.url}/elenco/GROUP"><i class="users huge icon"></i><p>Gruppi</p></a></td>
 
			<td class="ui segment panel_button"><a href="{$APP_BASE_URL}/"><i class="left arrow huge icon"></i><p>Indietro</p></a></td>
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