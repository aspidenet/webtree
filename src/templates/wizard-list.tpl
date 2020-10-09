{*extends file="template-private.tpl"*}
{extends file="wizard-config-template.tpl"}

{block name="html_head_extra"}

{/block}


{block name="config-content"}

<div style="margin: 10px 0px;">
    
    <div style="text-align:right;">
        <a class="ui blue button" onclick="modal_page_new('{$hashing}', '{$APP_BASE_URL}/modal/wizard/new/{$wizard_code}', 'overlay fullscreen', reload{$hashing}Tabulator);"title="Crea un nuovo record">Nuovo</a>
        <a class="ui grey button" href="{$APP_BASE_URL}/wizard/config">Indietro</a>
    </div>

    <div class="ui header">{$wizard->label()}</div>
    
    <div style="clear:both; width:100%;" id="content_top_limit"></div>
    <div id="tabulator_{$hashing}" style="margin: 3px;"></div>

</div>











<script>
var top_div = $('#content_top_limit').offset().top;
var bottom_div = $('#content_bottom_limit').offset().top;
var tabulator_height = (bottom_div-top_div-60);

{$tabulator->display("tabulator_"|cat:$hashing, "tabulator_height", 20, "wizard_list_row_select_"|cat:$hashing, false)}
    
    
$(document).ready(function() {
    
});


function wizard_list_row_select_{$hashing}(e, row) {
    var id = row.getData()['{$template_dbkey}'];
    redirect('{$APP_BASE_URL}/wizard/update/{$wizard_code}/' + id);
}
function reload{$hashing}Tabulator() {
    tabulator_{$hashing}.setData();
}
</script>

{/block}