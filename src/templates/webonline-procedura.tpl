{extends file="template-private.tpl"}

{block name="page_content"}

<!--script type="text/javascript" src="https://oss.sheetjs.com/js-xlsx/xlsx.full.min.js"></script-->

<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/1.3.5/jspdf.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.0.5/jspdf.plugin.autotable.js"></script>


<!--script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/locale/it.js"></script-->

<link rel="stylesheet" href="{$STATIC_URL}/multiple-select.min.css">
<script src="{$STATIC_URL}/multiple-select.min.js"></script>


<script language="JavaScript" type="text/javascript">
var mostra=1;
function OnEseguiProcedura_Click() {
    target = document.getElementById("risultati_estrazione");
    target.innerHTML = "<span class='grassetto' style='padding:100px;'>Attendere...</span>";
    
    $('#modal_results')
        .modal({
            inverted: false,
            closable  : false,
          })
        .modal('show');
            
    sync_submit('{$target_page}', 'frmProcedure1', target);
     
    //$('#frmProcedure1').submit();
}
    
    
/*function MostraNascondiParametri() {
    var options = {};
    if (mostra == 1) {
        $( "#corpo_parametri" ).hide( "blind", options, 500 );
        mostra = 0;
        $( "#titolo_parametri_mostra" ).text('(mostra)');
    }
    else {
        $( "#corpo_parametri" ).show( "blind", options, 500 );
        mostra = 1;
        $( "#titolo_parametri_mostra" ).text('(nascondi)');
    }
}*/
function OnVaiAllaPagina_Click(nomeform) {
    target = document.getElementById("risultati_estrazione");
    sync_submit('{$target_page}', nomeform, target);
}

$(document).ready(function() {
    //$( "#accordion" ).accordion();

    if ({$numero_parametri} == 0) {
        OnEseguiProcedura_Click();
        //MostraNascondiParametri();
        //$( "#accordion" ).accordion('close', 0);
    }
    
    $('#frmProcedure1').submit(function() { // catch the form's submit event
        //console.log("Submit!");
        //console.log($(this).serialize());
        $.ajax({ // create an AJAX call...
            data: $(this).serialize(), // get the form data
            type: $(this).attr('method'), // GET or POST
            url: $(this).attr('action'), // the file to call
            success: function(response) { // on success..
                $('#risultati_estrazione').html(response); // update the DIV
            }
        });
        return false; // cancel original event to prevent form submitting
    });
    
    $(".search.selection.dropdown").dropdown({
        ignoreCase: true,
        match: 'both',
        fullTextSearch: true
    });
    
    $('select').multipleSelect({
        minimumCountSelected: 10,
        filter: true
    });
});
</script>

<center>

<div class="ui container" style="padding: 1.5em;">
    <div id="btn_breadcrumb" class="tb_item" style="padding: 10px 14px;">
        <div class="ui breadcrumb">
            <a class="section" href="{$APP.url}">{$APP.title}</a>
            {foreach name=b key=key item=item from=$breadcrumbs.list}
                <i class="right angle icon divider"></i>
                {if $key == $breadcrumbs.current}
                <div class="active section">{$item}</div>
                {else}
                <a class="section" href="{$breadcrumbs['url'][$key]}">{$item}</a>
                {/if}
            {/foreach}
        </div>
    </div>


    <div style="clear: both;"></div>
    
   


    <div id="accordion" class="ui accordion">
        
        <div class="active title">
        
            <h3><table cellspacing="0" cellpadding="3">
                <tr>
                    <td class="dx grassetto"><i class="dropdown icon"></i> Titolo procedura: </td>
                    <td class="sx grassetto blu" style="font-size:1.3em;">{$procedura.descrizione}</td>
                </tr>
            </table></h3>
        </div>

        <div id="corpo_parametri" class="active content">

            <h4>Parametri richiesti per l'estrazione</h4>

            <form id="frmProcedure1" name="frmProcedure1" method="POST" action="{$APP.url}/procudura/{$pnum}" class="ui form">

            {foreach name=p item="parametro" key="key" from=$parametri}
                {if $smarty.foreach.p.first}
                <table class='ui definition table'>
                {/if}

                {if $parametro.fl_visible OR $operatore->admin() OR true}
                <tr>
                    <td class="sx collapsing" style="font-size:1.3em;">{$parametro.label0}
                    {if $parametro.help_long|count_characters > 0}
                        <i class="icon large teal info circle" title="{$parametro.help_long|escape:'html'}" alt="info"></i>
                    {/if}
                    </td>
                    <td class="sx">
                    {if $parametro.help_short|count_characters > 0}
                        {$parametro.help_short|escape:'javascript'}<br />
                    {/if}
                    {if $parametro.select_count >= 0}
                        {if $parametro.select_count > 0}
                            {if !$parametro.fl_multiselect}
                            <div class="ui fluid search selection dropdown">
                                <input name="param{$smarty.foreach.p.index}" type="hidden" value="%" />
                                <i class="dropdown icon"></i>
                                <div class="default text">Tutti</div>
                                <div class="menu">
                                    {foreach item="option" key="key_value" from=$parametro.select}
                                    <div class="item" data-value="{$key_value}">{$option.label}</div>
                                    {/foreach}
                                </div>
                            </div>
                            {else}
                            
                            {* VERSIONE SEMANTIC
                            <select class="ui fluid search selection dropdown" id="param{$smarty.foreach.p.index}" name="param{$smarty.foreach.p.index}[]" multiple="multiple">
                                {foreach item="option" key="key_value" from=$parametro.select}
                                <option value="{$key_value}">{$option}</option>
                                {/foreach}
                            </select>
                            *}
                            
                            
                            {* VERSIONE MULTIPLE-SELECT *}
                            <select class="" id="param{$smarty.foreach.p.index}" name="param{$smarty.foreach.p.index}[]" multiple="multiple">
                                {assign var="option_group_code" value=""}
                                {foreach name="ps" item="option" key="key_value" from=$parametro.select}
                                    
                                    {if $parametro.fl_group}
                                        {if $option.group_code != $option_group_code}
                                            {if !$smarty.foreach.ps.first}</optgroup>{/if}
                                        <optgroup label="{$option.group_label}">
                                        {/if}
                                    {/if}
                                    
                                    <option value="{$key_value}">{$option.label}</option>
                                    
                                    
                                    
                                    {if $parametro.fl_group}
                                        {assign var="option_group_code" value=$option.group_code}
                                        {if $smarty.foreach.ps.last}</optgroup>{/if}
                                    {/if}
                                {/foreach}
                            </select>
                            
                            <!--textarea id="sendparam{$smarty.foreach.p.index}" name="param{$smarty.foreach.p.index}"></textarea-->
                            <!--input type="hidden" id="sendparam{$smarty.foreach.p.index}" name="param{$smarty.foreach.p.index}" value="{$parametro.default_value|escape:'javascript'}" /-->
                            <script>
                            $(function() {
                                $('#param{$smarty.foreach.p.index}').multipleSelect({ 
                                    minimumCountSelected: 10,
                                    filter: true,
                                    {if $parametro.fl_group}
                                        multiple: true,
                                        width: 460,
                                        multipleWidth: 55
                                    {/if}
                                });
                                
                            });
                            </script>
                            {/if}
                        {else}
                        <b>Nessun valore selezionabile. Impossibile continuare!</b>
                        {/if}
                    {else} {* if $parametro.select_count == -1 *}
                        <input type="edit" name="param{$smarty.foreach.p.index}" value="{$parametro.default_value}" {if $parametro.type == "datetime"}class="date1"{/if} />
                    {/if}

                    
                    </td>
                </tr>
                {else}
                    <input type="hidden" name="param{$smarty.foreach.p.index}" value="{$parametro.default_value}" />
                {/if}
                <input type="hidden" name="param{$smarty.foreach.p.index}_tipo" value="{$parametro.type}" />
                    
                {if $smarty.foreach.p.last}
                    </table>
                {/if}
                
            {foreachelse}
                <h5>Nessun parametro da valorizzare.</h5>
            {/foreach}

                <input type="hidden" name="fase" value="2" />
                <input type="hidden" name="pnum" value="{$pnum}" />
                <input type="hidden" name="numero_parametri" value="{$numero_parametri}" />
                <input type="hidden" name="ok_salva" id="ok_salva" value="0" />
                <input type="hidden" name="code_salva" id="code_salva" value="" />
                <input type="hidden" name="nome_salva" id="nome_salva" value="" />
                {if $ok_esegui}<button type='button' name='btnSelect' class="ui primary button" onclick="OnEseguiProcedura_Click();"><i class="icon play"></i> Esegui</button>{/if}
                <button type='button' name='btnIndietro' class="ui grey button" onclick="window.history.back();;"><i class="icon left arrow"></i> Indietro</button>
            </form>
        </div>
    </div>
</div>
</center>





<div class="ui overlay fullscreen modal" id="modal_results">
  <div class="ui icon header">
    <span id="message_title">{$procedura.descrizione}</span>
  </div>
  <div class="content">
    <div id="risultati_estrazione"></div>
  </div>
  <div class="actions">
    <div class="ui grey ok button">
      <i class="remove icon"></i>
      Chiudi
    </div>
    <!--div class="ui red cancel inverted button">
      <i class="remove icon"></i>
      NO
    </div-->
  </div>
</div>

{/block}