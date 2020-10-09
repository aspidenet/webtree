{extends file="template-private.tpl"}

{block name="page_content"}
<style>
	.panel_button {
		text-align:center;
		border: 0px solid white;
		font-size:1.2em;
		font-weight:bold;
        margin: 10px;
	}
    a {
        color: black;
        text-decoration: none;
	}
    a:hover {
        color: blue;
        text-decoration: none;
	}
    p { padding-top: 12px; }
</style>

<div class="ui grid">
    <div class="one wide column">
        {foreach key="key" item="item" from=$configurazione}
        <div class="ui  panel_button">
        
            <a href="{$item.link}">
            
                <i class="{$item.icona} large icon" title="{$item.nome}"></i>
            
            </a>
        
        </div>
        {/foreach}
    </div>
    <div class="fifteen wide column">
    {block name="config-content"}
    {/block}
    </div>
</div>
{/block}
