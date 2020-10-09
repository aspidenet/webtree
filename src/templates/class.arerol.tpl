<script>
    
$(document).ready(function() {
    $(".ui.dropdown").dropdown();
});


</script>

--- AAA --- {$parent}

{foreach key=key item=field from=$template->getFields()}

    {if $key|upper == 'US_AREROL_US_AREUTE_ID'}
        US_AREROL_US_AREUTE_ID
        {*
        <select class="ui fluid search dropdown" multiple="" name="{$key|lower}" id="{$key|upper}">
        {foreach item=item key=key from=$arevis}
        <option value="{$key}">{$item}</option>
        {/foreach}
        </select>
        *}
        
        <div class="ui multiple fluid search selection dropdown">
            <!-- This will receive comma separated value like OH,TX,WY !-->
            <input name="{$key|lower}" type="hidden">
            <i class="dropdown icon"></i>
            <div class="default text"></div>
            <div class="menu">
                {foreach item=item key=k from=$arevis}
                <div class="item" data-value="{$k}">{$item}</div>
                {/foreach}
            </div>
        </div>
    {else}        
        {$field->display("I", null)}
    {/if}
{/foreach}



<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>