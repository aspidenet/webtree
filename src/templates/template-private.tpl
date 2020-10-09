{extends file="template-init.tpl"}


{block name="html_head_extra"}

{/block}


{block name="html_head_default_style"}
<style type="text/css">
.invisible { display: none !important; }
</style>
<script>
$(document).ready(function() {

    // fix menu when passed
    $('.masthead').visibility({
        once: false,
        onBottomPassed: function() {
            $('.fixed.menu').transition('fade in');
        },
        onBottomPassedReverse: function() {
            $('.fixed.menu').transition('fade out');
        }
    });

    // create sidebar and attach to menu open
    $('.ui.sidebar')
        .sidebar({
            // Overlay will mean the sidebar sits on top of your content
            transition: 'overlay'
        })
        .sidebar('attach events', '.toc.item');
  
    $('.ui.dropdown').dropdown();
});
    
    
function sync_submit(url, form_id, target_obj) {
    console.log("Submit "+form_id+"!");
    $.ajax({ // create an AJAX call...
        data: $('#'+form_id).serialize(), // get the form data
        type: $('#'+form_id).attr('method'), // GET or POST
        url: url, //$(this).attr('action'), // the file to call
        success: function(response) { // on success..
            console.log("success");
            $(target_obj).html(response); // update the DIV
        }
    });
    return false; // cancel original event to prevent form submitting
}
</script>
{/block}

{block name="html_head_extra"}

{/block}

{block name="html_body"}


<!-- Sidebar Menu -->
<div class="ui {if $HOMEPAGE|default:false}visible{/if} vertical inverted black sidebar menu">
    <div style="padding:6px 3px; text-align:center;">
        <img src="{$STATIC_URL}/img/logo_sidebar.png" style="height: 50px;"/>
    </div>
    
    <br>
    <div style="padding:5px 30px; color: var(--colorPrimary);">Welcome {$operatore->get("nome")|ucwords}</div>
    <br>
    
    <a class="active item" href="{$APP_BASE_URL}/">{$APPNAME} <i class="home icon"></i></a>
    
    {foreach name=macro item=item key=key from=$session->menu()}
    <div class="item">
        <div class="header">{$item.title}</div>
        <div class="menu">
            {foreach name=moduli item=modulo key=codice from=$item.items}
            <a class="item" href="{$APP_BASE_URL}{$modulo.link}">
                {$modulo.title}
                <i class="{$modulo.image} icon"></i>
            </a>
            {/foreach}
        </div>
    </div>
    {/foreach}
    
    
    {if $operatore->admin()}
    <a class="{if $REQUEST_URI == '{$APP_BASE_URL}/admin'}active{/if} item" href="{$APP_BASE_URL}/admin"><i class="icon settings"></i> Amministrazione</a>
    {/if}

    <a class="item" href="{$APP_BASE_URL}/logout">Esci <i class="power icon"></i></a>
</div>
    {block name="custom_sidebars"}{/block}


<div style="border-top: 0px solid teal; width:100%; z-index:99; position:absolute; bottom:0px;" id="content_bottom_limit"></div>
    
<!-- Page -->
<div id="page" class="pusher">
    {block name="page_superheader"}{/block}
    
    {block name="page_header"}
    <div id="page_header" class="ui">
        {block name="header"}
      
      
        
        
        {if $TEST}
        <div role="alert" class="ribbon">{$RIBBON}</div>
        {/if}       
        <header id="web3header">
            <div class="ui container masthead">
            
                <div class="ui large secondary menu">
                    <a class="header-logo-link" href="/">
         
                        <img src="{$STATIC_URL}/img/logo_sidebar.png" style="height: 50px;" />
                    </a>
                    
                    <a class="left item" style="color:white; font-size:1.3em; font-weight:bold;">
                      {$APPNAME}
                    </a>

                    <a class="right toc item" style="color:white;">
                      <i class="sidebar big icon"></i>
                    </a>
                    
                </div>
            </div>
        </header>

      
      
      
      
        {/block}
    </div>
    {/block}
  
    <!-- Page Contents -->
    <div id="page_content" class="ui">
    {block name="page_content"}
        <div class="ui container" style="">
        {block name="content"}
        {/block}
        </div>
    {/block}
    </div>
  
  
    <!-- Page Footer -->
    {block name="page_footer"}
    <footer id="web3footer">
        <div class="web3footer footer-closure">
            <div class="ui container">
            {$now|date_format:"%Y"} | Web3 | Aspide.net
            </div>
        </div>
    </footer>
    {/block}
</div>
{/block}
