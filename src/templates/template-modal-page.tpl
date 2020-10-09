{extends file="template-modal.tpl"}

{block name="html_head_extra"}
{/block}
    
{block name="content"}
<script>
$(document).ready(function() {
    
    
});

</script>

{* serve solo per capire chi è il padre *}
<div id="modal{$id}container" style="color:red;"></div>

{if isset($header)}
<div class="header">
    {$header}
</div>
{/if}

<div class="scrolling content">
{block name="modal_content"}
    
{/block}
</div>

<div class="actions">
{block name="modal_actions_footer"}
{/block}
</div>

{/block}