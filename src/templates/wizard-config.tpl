{extends file="template-private.tpl"}

{block name="html_head_extra"}

<script language="JavaScript" type="text/javascript">
$(function(){
});
</script>
{/block}


{block name="content"}

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
        color: olive;
	}
    p { padding-top: 12px; }
</style>

<br />
<br />
<br />
<br />
<center>

            
	<table border="0" cellspacing="5" cellpadding="2">
		<tr>
			{foreach key="key" item="item" from=$configurazione}
			<td class="ui segment panel_button"><a href="{$item.link}"><i class="{$item.icona} huge icon"></i><p>{$item.nome}</p></a></td>
            {/foreach}
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