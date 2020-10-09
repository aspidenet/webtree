<!DOCTYPE html>
<html>
<head>
{block name="html_head"}
    <!-- Standard Meta -->
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">

    <!-- Site Properties -->
    <title>{if $TEST}TEST {/if}{$APPNAME}</title>

    <link rel="shortcut icon" type="image/ico" href="{$STATIC_URL}/img/favicon.ico"/>
    <script language="JavaScript" type="text/javascript" src="{$STATIC_URL}/jquery.js"></script>

    <link href="https://fonts.googleapis.com/css?family=Montserrat|Open+Sans" rel="stylesheet"> 
    
    {* FOMANTIC UI
    <link rel="stylesheet" type="text/css" href="{$STATIC_URL}/semantic-dist/semantic.min.css">
    <script src="{$STATIC_URL}/semantic-dist/semantic.min.js"></script>
    *}
    
    <script src="{$STATIC_URL}/jquery-ui.min.js"></script>
    
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.css">
    <script src="https://cdn.jsdelivr.net/npm/fomantic-ui@2.8.4/dist/semantic.min.js"></script>
    
    {* MOMENT
    <script type="text/javascript" src="{$STATIC_URL}/moment-with-locales.min.js"></script>
    *}
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.26.0/moment-with-locales.min.js"></script>
    
    {* TABULATOR
    <link href="{$STATIC_URL}/tabulator-dist/css/tabulator.min.css" rel="stylesheet">
    <script type="text/javascript" src="{$STATIC_URL}/tabulator-dist/js/tabulator.min.js"></script>
    <script type="text/javascript" src="{$STATIC_URL}/tabulator-dist/js/jquery_wrapper.min.js"></script>

    <link href="{$STATIC_URL}/tabulator-dist/css/semantic-ui/tabulator_semantic-ui.min.css" rel="stylesheet">
    *}
    <link href="https://unpkg.com/tabulator-tables@4.7.1/dist/css/tabulator.min.css" rel="stylesheet">
    <script type="text/javascript" src="https://unpkg.com/tabulator-tables@4.7.1/dist/js/tabulator.min.js"></script>
    

    
    <script>
    function ShowMessage(msg, closeable=true, funcOK=function() {}, funcKO=function() {}) {
        // TODO Check msg format
        $('#modal_message .content').html("<p>"+msg.description+"</p>");
        //$('#modal_message #message_title').html(msg.title);
        if (msg.level == "WARNING") {
            $('#modal_message_si_button').css({ 'display':'initial' });
            $('#modal_message_no_button').css({ 'display':'initial' });
            $('#modal_message_ok_button').css({ 'display':'none' });
            $('#modal_message .content').append("<p>Vuoi proseguire?</p>");
        }
        else {
            $('#modal_message_si_button').css({ 'display':'none' });
            $('#modal_message_no_button').css({ 'display':'none' });
            $('#modal_message_ok_button').css({ 'display':'initial' });
        }
        $('#modal_message')
            .modal({
                allowMultiple: true,
                inverted: false,
                closable  : closeable,
                onApprove : funcOK,
                onDeny : funcKO
              })
            .modal('show');
    }
    function navigate(href, newTab) {
        var a = document.createElement('a');
        a.href = href;
        if (newTab) {
            a.setAttribute('target', '_blank');
        }
        a.click();
    }
    
    $(document).ready(function() {
        $('select.dropdown').dropdown();
        $('.ui.dropdown').dropdown();
        $('.ui.calendar').calendar({ 
            type: 'date',
            firstDayOfWeek: 1,
            text: {
                days: ['D', 'L', 'M', 'M', 'G', 'V', 'S'],
                months: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'],
                monthsShort: ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'],
                today: 'Oggi',
                now: 'Ora',
                am: 'AM',
                pm: 'PM'
            },
            monthFirst: false,
            /*formatter: {
                date: function (date, settings) {
                    if (!date) return '';
                    var day = date.getDate();
                    var month = date.getMonth() + 1;
                    var year = date.getFullYear();
                    return day + '/' + month + '/' + year;
                }
            }*/
            formatter: {
                date: function (date, settings) {
                    if (!date) return '';
                    var day = date.getDate() + '';
                    if (day.length < 2) {
                        day = '0' + day;
                    }
                    var month = (date.getMonth() + 1) + '';
                    if (month.length < 2) {
                        month = '0' + month;
                    }
                    var year = date.getFullYear();
                    return day + '/' + month + '/' + year;
                }
            }
        });
        $('.ui.calendar.yearfirst').calendar({ 
            type: 'date',
            startMode: 'year',
            firstDayOfWeek: 1,
            text: {
                days: ['D', 'L', 'M', 'M', 'G', 'V', 'S'],
                months: ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'],
                monthsShort: ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'],
                today: 'Oggi',
                now: 'Ora',
                am: 'AM',
                pm: 'PM'
            },
            monthFirst: false,
            formatter: {
                date: function (date, settings) {
                    if (!date) return '';
                    var day = date.getDate() + '';
                    if (day.length < 2) {
                        day = '0' + day;
                    }
                    var month = (date.getMonth() + 1) + '';
                    if (month.length < 2) {
                        month = '0' + month;
                    }
                    var year = date.getFullYear();
                    return day + '/' + month + '/' + year;
                }
            }
        });
        
        
        
        

        $('.cerca.nazioni').search({
            apiSettings: {
                url: '/json/nazioni/{ query }'
            },
            onSelect: function (result,response) {
                //console.log(result);
                //console.log(response);
                $("#modal_place_nazione_codice").val(result.value);
                if (result.value == 'IT') {
                    $("#row_comune").css({ "display":"block" });
                    $("#row_localita_estera").css({ "display":"none" });
                }
                else {
                    $("#row_comune").css({ "display":"none" });
                    $("#row_localita_estera").css({ "display":"block" });
                }
                return true;
            },
            fields: {
                results : 'results',
                title   : 'name',
                value   : 'value',
                //url     : 'html_url'
            },
            minCharacters : 2
        }); 
        
        
        $('.cerca.comuni').search({
            apiSettings: {
                url: 'json/comuni/{ query }'
            },
            onSelect: function (result,response) {
                //console.log(result);
                //console.log(response);
                $("#modal_place_comune_codice").val(result.value);
                return true;
            },
            fields: {
                results : 'results',
                title   : 'name',
                value   : 'value',
                //url     : 'html_url'
            },
            minCharacters : 2,
            selectFirstResult: true
        });
    
    
        $('.ui.search.dropdown').dropdown({
            fullTextSearch: 'exact'
        });
        
        
        $('.ui.form.oggetto').submit(function(event){
            event.preventDefault();
            $.ajax({
                type: 'post',
                url: '../oggetto.php',
                data: $(this).serialize(),
                success: function () {
                    //"ok" label on success.
                    //$('#successLabel').css("display", "block");
                    console.log("Post success");
                }
            })
            .done(function( data ) {
                //console.log(data);
                $('#modal_form .content').html(data);
                $('#modal_form')
                    .modal({
                        allowMultiple: true,
                        inverted: false,
                        closable  : false,
                        //onApprove : function() { $("#frmOggetto").submit() }
                    })
                    .modal('show');
            });   
        });
    
    }); // fine OnReady.
    
    function modal_popup_url(url, onhide=function() {}) {
    
        $('#modal_wizard_page .content').load(url);
        $('#modal_wizard_page')
                    .modal({
                        inverted: false,
                        allowMultiple: true,
                        closable  : true,
                        //onApprove : function() { $("#frmOggetto").submit() }
                        onHide: onhide
                    })
                    .modal('show');
    }
    function redirect(url) {
        window.location = url;
    }
    
    
    
    
    
    
    function reload(id, url) {
        $('#'+id).html('<div class="ui text loader">Loading</div>');
        $('#'+id).load(url);
    }


    function modal_page_new(id, url, size, onHideFunc, onApproveFunc) {
        //var modal = $(".ui.modal.page").clone().appendTo('body');
        //modal.attr("id", id);
        console.log("modal_page_new: "+id);
        var ok_func = false;
        
        if (onApproveFunc === undefined) {
            onApproveFunc = function() { };
        }
        else
            console.log("onApproveFunc indicato");
        
        $('body').append('<div class="ui '+size+' modal page" id="'+id+'"><div class="ui text loader">Loading</div></div>');
        $('#'+id).load(url);
        $('#'+id)
            .modal({
                inverted: false,
                allowMultiple: true,
                closable  : false,
                onApprove : function(element) { console.log('modal approve ' + id); onApproveFunc(); return false; },
                onDeny: function(element) { console.log('modal deny ' + id);},
                onHide: function(element) { console.log('modal hide ' + id); onHideFunc(); },
                onHidden: function() { 
                    console.log('modal hidden ' + id); 
                    if (ok_func)
                        onApproveFunc();
                    //$('body').detach('#'+id);
                    //$('body').remove('#'+id);
                    $('#'+id).remove();
                }
                
            })
            .modal('setting', 'transition', 'vertical flip')
            .modal('show');
    }

    function modal_page_close(id) {
        console.log("modal_page_close: "+id);
        $('#'+id).modal('hide');
        //$('body').detach('#'+id);
        //$('body').remove('#'+id);
    }
    

    
    function sendFormTemplate(modal_id, url, customFunction) {
        console.log("sendFormTemplate(): form submit #frmModalTemplate"+modal_id);
        console.log(url);
        //return false; //stopPropagation
        $.ajax({
            type: "POST",
            url: url,
            data: $('#frmModalTemplate'+modal_id).serialize(),
            success: function () {
                console.log("success "+modal_id);
            }
        })
        .done(function( data ) {
            console.log(data);
            //return false;
            if (data == 'OK') {
                modal_popup_url(url, returnToUrl);
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
                        console.log(msg);
                        if (customFunction !== undefined) 
                            customFunction();
                        
                        modal_page_close(modal_id);
                        return true;
                    }
                    else if (msg.level == "WARNING") {
                        $("#frmModalTemplate"+modal_id+" input[name='ignore_warning']").val('S');
                        //$("#frmModalTemplate"+modal_id).submit();
                        sendFormTemplate(modal_id, url, customFunction);
                    }
                });
            }
        });   
    }
    
    
    
    </script>
    
    
    <link rel="stylesheet" type="text/css" href="{$STATIC_URL}/css/style.css" />
    
    {block name="html_head_default_style"}
    {/block}
  
    {block name="html_head_extra"}
    {/block}
    
{/block}
</head>
<body>
{block name="html_body"}
{/block}



<div class="ui modal" id="modal_wizard_page">
  <div class="scrolling content"></div>
</div>

<div class="ui modal" id="modal_form">
  {*<div class="ui icon header">
    <i class="announcement icon"></i>
    <span id="message_title">{$APPNAME}</span>
  </div>*}
  <div class="scrolling content"></div>
</div>


<div class="ui modal" id="modal_message">
    <div class="ui block header center aligned" style="color:white; background:var(--colorPrimaryDark); padding: 5px;">
        <i class="announcement large icon"></i> {$APPNAME}
    </div>
    <div class="content">
        Messaggio
    </div>
    <div class="actions">
        <div class="ui primary ok  button" id="modal_message_ok_button" style="">
            <i class="checkmark icon"></i> OK
        </div>
        <div class="ui green ok inverted button" id="modal_message_si_button" style="display: none;">
            <i class="checkmark icon"></i> SI
        </div>
        <div class="ui red cancel inverted button" id="modal_message_no_button" style="display: none;">
            <i class="remove icon"></i> NO
        </div>
    </div>
</div>



</body>
</html> 