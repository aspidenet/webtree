{extends file="template-modal.tpl"}

{block name="html_head_extra"}
<link href="{$STATIC_URL}/assets/library/tabulator.min.css" rel="stylesheet" />
<!--link href="{$STATIC_URL}/assets/library/tabulator_semantic-ui.min.css" rel="stylesheet" /-->
<!--link href="{$STATIC_URL}/assets/library/tabulator_bootstrap.min.css" rel="stylesheet" /-->

<script src="{$STATIC_URL}/assets/library/jquery-ui.min.js"></script>
<script src="{$STATIC_URL}/assets/library/tabulator.min.js"></script>
<script src="{$STATIC_URL}/assets/library/xlsx.full.min.js"></script>

{/block}
    
{block name="content"}

<script>
$(document).ready(function() {
    
    var url = "{$APP_BASE_URL}/wizard/{$wizard_code}/new";
    var modal_show = false;
    
    // Inviamo il form
    $('#frmModalWizardTemplate').submit(function(event){
        event.preventDefault();
        console.log("------------------- frmModalWizardTemplate -------------------");
        //return;
        $.ajax({
            type: "POST",
            url: "{$APP_BASE_URL}/wizard/{$wizard_code}/new/{$index_pos}/{$relation.slave_code}",
            data: $('#frmModalWizardTemplate').serialize(),
            success: function () {
                console.log("success #frmModalWizardTemplate");
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
            if (data == 'OK') {
                modal_popup_url(url);
                return true;
            }
            else if (data == 'KO') {
                var msg = JSON.parse('{ "description":"Errore non specificato." }');
                ShowMessage(msg, false);
                return false;
            }
            else {
                var msg = JSON.parse(data);
                ShowMessage(msg, false, function() { 
                    if (msg.level == "INFO") {
                        $('#modal_form_wizard_template').modal('hide');
                        modal_popup_url(url);
                        return true;
                    }
                    else if (msg.level == "WARNING") {
                        $("#frmModalWizardTemplate input[name='ignore_warning']").val('S');
                        $("#frmModalWizardTemplate").submit();
                    }
                });
            }
        });   
        //return false;
    });
    
    // Genero il form dinamicamente
    $('.ui.form.template').submit(function(event){
        event.preventDefault();
        $.ajax({
            type: 'post',
            url: "{$APP_BASE_URL}/wizard/template/{$relation.slave_code}/new",
            data: $(this).serialize(),
            success: function () {
                //"ok" label on success.
                //$('#successLabel').css("display", "block");
                console.log("Post success .ui.form.template");
            }
        })
        .done(function( data ) {
            //console.log(data);
            $('#modal_form_wizard_template .content').html(data);
            if (modal_show == false) {
                $('#modal_form_wizard_template')
                    .modal({
                        allowMultiple: true,
                        inverted: false,
                        closable  : false,
                        onApprove : function() { 
                            event.preventDefault();
                            if ($("#frmModalWizardTemplate")[0].checkValidity() == false) {
                                alert("KO");
                                console.log($("#frmModalWizardTemplate").serialize());
                                return false;
                            }
                            
                            console.log("form frmModalWizardTemplate submit");
                            $("#frmModalWizardTemplate").submit();
                            return false; // not hide
                        },
                        onShow: function() {
                            console.log('modal_form_wizard_template::onShow');
                            modal_show = true;
                        }
                    });
            }
            $('#modal_form_wizard_template')
                .modal('show');
        });   
    });
    
    $('#btnAssociaEsistente').submit(function(event){
        event.preventDefault();
        $.ajax({
            type: 'post',
            url: '{$APP_BASE_URL}/wizard/template/{$relation.slave_code}/list',
            data: $(this).serialize(),
            success: function () {
                //"ok" label on success.
                //$('#successLabel').css("display", "block");
                console.log("Post success #btnAssociaEsistente");
            }
        })
        .done(function( data ) {
            //console.log(data);
            $('#modal_form_wizard_template .content').html(data);
            $('#modal_form_wizard_template')
                .modal({
                    allowMultiple: true,
                    inverted: false,
                    closable  : false,
                    onApprove : function() { /*$("#frmTemplate").submit()*/
                        var selectedData = $("#example-table").tabulator("getSelectedData"); //get array of currently selected data.
                        console.log(selectedData);
                        
                        event.preventDefault();
                        console.log("form new relations submit");
                        //return;
                        $.ajax({
                            type: "POST",
                            url: "{$APP_BASE_URL}/wizard-{$wizard_code}/new/{$index_pos}/{$relation.slave_code}",
                            data: { data: selectedData },
                            success: function () {
                                console.log("success");
                            }
                        })
                        .done(function( data ) {
                            console.log(data);
                            //return false;
                            if (data == 'OK') {
                                modal_popup_url(url);
                                //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
                                //ShowMessage(msg, false, function() { window.location = ""; });
                            }
                            else if (data == 'KO') {
                                var msg = JSON.parse('{ "description":"Errore non specificato." }');
                                ShowMessage(msg, false);
                            }
                            else {
                                var msg = JSON.parse(data);
                                ShowMessage(msg, false, function() { modal_popup_url(url); });
                            }
                        });   
        
        
        
                    }
                })
                .modal('show');
        });   
    });   
    
    $('#btnProsegui').submit(function(event){
    
        event.preventDefault();
        console.log("btnProsegui submit");
        //return;
        $.ajax({
            type: "POST", 
            url: "{$APP_BASE_URL}/wizard/{$wizard_code}/new/pass/{$index_pos}",
            data: $('#btnProsegui').serialize(),
            success: function () {
                console.log("btnProsegui success");
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
            if (data == 'OK') {
                modal_popup_url(url);
                //var msg = JSON.parse('{ "description":"Dato salvato con successo." }');
                //ShowMessage(msg, false, function() { window.location = ""; });
            }
            else if (data == 'KO') {
                var msg = JSON.parse('{ "description":"Errore non specificato." }');
                ShowMessage(msg, false);
            }
            else {
                var msg = JSON.parse(data);
                ShowMessage(msg, false, function() { modal_popup_url(url); });
            }
        });   
        
    });  
});

function sendModalWizardTemplate() {

}
</script>




<div style="margin: 0.5em 0; border: 0px solid teal;">

    {* tastoni *}
    <div style="float: left; margin: 0.5em 0; border: 1px solid orange;"><!-- onclick="$('#frmTemplate').submit();" -->
        {if $relation.cardinality_max > $records|count}
        <form class="ui form template" style="float: left;">
            <button class="ui green button" type="submit">Crea nuovo <i class="add icon"></i></button>    
        </form>
        <form class="ui form" style="float: left;" id="btnAssociaEsistente">
            <button class="ui green button" type="submit">Associa esistente <i class="linkify icon"></i></button>      
        </form>
        {/if}
        <form class="ui form" style="float: left;" id="btnProsegui">
            <button class="ui green button" type="submit">Prosegui <i class="right arrow icon"></i></button>    
        </form>
    </div>
    {* fine tastoni *}
        
    <div style="clear:both;">
        

        <div class="ui header center aligned">{$relation.label0}</div>
        
        {*
        <h4>Oggetti nuovi</h4>
        {foreach key=key item=item from=$records}
            <i class="icon {$template->icon()}"></i> {$item->label()}<br>
        {foreachelse}
            Nessun record.
        {/foreach}

        <h4>Oggetti linkati</h4>
        {foreach key=key item=item from=$linkeds}
            <i class="icon {$template->icon()}"></i> {$item}<br>
        {foreachelse}
            Nessun record.
        {/foreach}
        *}
        
        
        
        
        
        
        <table class="ui striped stackable celled padded table">
            <thead>
                <tr>
                    <th class="collapsing">Azioni</th>
                    <th>Oggetti nuovi</th>
                </tr>
            </thead>
            <tbody>
            
            {foreach key=key item=item from=$records}
                <tr>
                    <td class="center aligned"><i class="icon trash alternate"></i></td>
                    <td><i class="icon {$template->icon()}"></i> {$item->label()}</td>
                </tr>
            {foreachelse}
                <tr class="warning"><td colspan="20">Nessun oggetto.</td></tr>
            {/foreach}
            
            </tbody>
        </table>
        
        
        <table class="ui striped stackable celled padded table">
            <thead>
                <tr>
                    <th class="collapsing">Azioni</th>
                    <th>Oggetti linkati</th>
                </tr>
            </thead>
            <tbody>
            
            {foreach key=key item=item from=$linkeds}
                <tr>
                    <td class="center aligned"><i class="icon trash alternate"></i></td>
                    <td><i class="icon {$template->icon()}"></i> {$item}</td>
                </tr>
            {foreachelse}
                <tr class="warning"><td colspan="20">Nessun oggetto.</td></tr>
            {/foreach}
            
            </tbody>
        </table>


    </div>
    
</div>



<div class="ui modal" id="modal_form_wizard_template">
    {*<div class="ui icon header">
        <i class="announcement icon"></i>
        <span id="message_title"></span>
    </div>*}
    <form id="frmModalWizardTemplate" class="ui form" method="POST">
        <input type="hidden" name="ignore_warning" value="N" />

        <div class="scrolling content"></div>
        
        <div class="actions" style="padding: 10px; text-align:right;" id="content_bottom_limit_form_select">
            <button type="button" class="ui green ok inverted button" id="btnModalWizardTemplate">
                <i class="checkmark icon"></i> Salva
            </button>
            <div class="ui red cancel inverted button">
                <i class="remove icon"></i> Annulla
            </div>
        </div>
    </form>
</div>


{/block}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
