{extends file="template-modal-page.tpl"}


    
{block name="modal_content"}

        <form class="ui form">
            
            <div class="ui header center aligned" id="testo">XXX {$testo} {$NOW}</div>
            <div>{$REQUEST->uri()}</div>
            
            {* tastoni *}
            {if $url|count_characters}
            <div style="margin: 0.5em 0; border: 1px solid orange;">
                <button class="ui button" type="button" onclick="modal_page_new('{$id}', '{$url}', 'long', func{$id}OnHide);">Apri Test</button>
                <button class="ui button" type="button" onclick="parent();">Parent</button>
            </div>
            {/if}
            {* fine tastoni *}
        </form>


{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
