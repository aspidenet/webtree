{extends file="template-modal.tpl"}
    
{block name="content"}

<script>
$(document).ready(function() {
    
});
</script>




<div style="margin: 0.5em 0; padding: 1em; border: 0px solid teal;">

    
        <input type="hidden" name="template_code" value="{$template->code()}" />

        <div class="ui header center aligned">{$template->label()}</div>
        {foreach key=key item=item from=$fields}

            {$item->display("I")}

        {/foreach}

</div>
{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
