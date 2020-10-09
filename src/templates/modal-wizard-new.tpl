{extends file="template-modal-page.tpl"}

{block name="html_head_extra"}
{/block}

{block name="modal_actions"}
{/block}

{block name="modal_actions_footer"}
<button class="ui blue disabled save_wizard button" id="save_wizard" onclick="wizard_new_save();" title="Memorizza tutto su disco">
    <i class="checkmark icon"></i> Salva
</button> 
<button class="ui grey cancel cancel_wizard button" id="cancel_wizard" onclick="wizard_new_cancel();" title="Annulla tutto">
    <i class="close icon"></i> Annulla
</button> 
{/block}



{block name="modal_content"}
<script language="JavaScript" type="text/javascript">
var current_tab = {$tab|default:"0"};

$(function(){
    $('.tabular.menu .item').tab({
        cache: false,
        evaluateScripts : true,
        auto    : true,
        path    : '{$APP_BASE_URL}/modal/wizard/new/{$wizard_code}/',
        ignoreFirstLoad: false,
        alwaysRefresh: true
    })
    .tab('change tab', '{$tab|default:"0"}');
});

function nextTab() {
    var next_tab = current_tab + 1;
    refreshTab(next_tab);
}
                        
function refreshTab(name) {
    $('.tabular.menu .item').tab('change tab', name);
}


function wizard_new_save() {
    console.log("wizard_new_save");
    //return;
    $.ajax({
        type: "POST",
        url: "{$APP_BASE_URL}/wizard/{$wizard_code}/save",
        success: function () {
            console.log("success");
        }
    })
    .done(function( data ) {
        console.log(data);
        //return false;
        if (data == 'OK') {
            window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
            //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
            //ShowMessage(msg, false, function() { window.location = ""; });
        }
        else if (data == 'KO') {
            var msg = JSON.parse('{ "description":"Errore non specificato." }');
            ShowMessage(msg, false);
        }
        else {
            var msg = JSON.parse(data);
            ShowMessage(msg, false, function() { 
                if (msg.level == "INFO") {
                    if (msg.customs) {
                        if (msg.customs.url) {
                            window.location = msg.customs.url;
                            return true;
                        }
                    }
                    window.location = "{$APP_BASE_URL}/wizard/list/{$wizard_code}";
                }
            });
        }
    });   
    return false;
}
    
    
    
function wizard_new_cancel() {
    
    $.ajax({
        type: "POST",
        url: "{$APP_BASE_URL}/wizard/{$wizard_code}/cancel",
        success: function () {
            console.log("success");
        }
    })
    .done(function( data ) {
        console.log(data);
        //return false;
        if (data == 'OK') {
            //window.location = "{$APP_BASE_URL}/wizard/{$wizard_code}/list";
            //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
            //ShowMessage(msg, false, function() { window.location = ""; });
            $('#modal_wizard_page').modal('hide');
        }
        else if (data == 'KO') {
            var msg = JSON.parse('{ "description":"Errore non specificato." }');
            ShowMessage(msg, false);
        }
        else {
            var msg = JSON.parse(data);
            ShowMessage(msg, false, function() { 
                //window.location = "{$APP_BASE_URL}/wizard/list/{$wizard_code}";
                $('#modal_wizard_page').modal('hide');
            });
        }
    });   
    
}
</script>


<div style="margin: 10px 0px;">

    <div class="ui header">Wizard: <span class="ui orange">{$wizard_code|upper}</span></div>

    <div class="ui top attached tabular menu">
        {foreach item="item" key="key" from=$tabs}
        <a class="item disabled" data-tab="{$key}">{$item}</a>
        {/foreach}
    </div>
    
    {foreach item="item" key="key" from=$tabs}
        <div class="ui bottom attached tab segment" data-tab="{$key}"></div>
    {/foreach}
    

</div>
{/block}