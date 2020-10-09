{extends file="template-public.tpl"}


{block name="html_head_extra"}



    <script src="{$STATIC_URL}/jquery.backstretch.min.js" type="text/javascript"></script>

<style type="text/css">
    body {
      background: #DADADA url('{$STATIC_URL}/img/4.jpg') repeat center center;
      background-size: cover;
    }
    .body1 { background-image: url('{$STATIC_URL}/img/1.jpg'); }
    .body2 { background-image: url('{$STATIC_URL}/img/2.jpg'); }
    .body3 { background-image: url('{$STATIC_URL}/img/3.jpg'); }
    .body4 { background-image: url('{$STATIC_URL}/img/4.jpg'); }
    
    body > .grid {
      height: 100%;
    }
    .image {
      margin-top: -100px;
    }
    .column {
      max-width: 450px;
    }
    #btnLogin {
        color: white;
        //background: var(--colorPrimary) !important;
        background: #4b8df8 !important;
        -webkit-border-radius: 0px;
        -moz-border-radius: 0px;
        border-radius: 0px;
    }
    .ui.image.header {
        //color: var(--colorPrimary) !important;
    }
</style>
<script>
var tid, i=1;
var images = [
  "{$STATIC_URL}/img/1.jpg",
  "{$STATIC_URL}/img/2.jpg",
  "{$STATIC_URL}/img/3.jpg",
  "{$STATIC_URL}/img/4.jpg",
];
function shuffleArray(array) {
                for (var i = array.length - 1; i > 0; i--) {
                    var j = Math.floor(Math.random() * (i + 1));
                    var temp = array[i];
                    array[i] = array[j];
                    array[j] = temp;
                }
                return array;
            }

$(document)
    .ready(function() {
        //tid = setInterval(timerfunc, 5000);
        
        $.backstretch(shuffleArray(images), {
                fade: 1000,
                duration: 8000
            }
        );
            
            
        $('.ui.form')
        .form({
          fields: {
            uname: {
              identifier  : 'uname',
              rules: [
                {
                  type   : 'empty',
                  prompt : "Inserisci il tuo username"
                }
              ]
            },
            passwd: {
              identifier  : 'passwd',
              rules: [
                {
                  type   : 'empty',
                  prompt : 'Inserisci la password'
                },
                {
                  type   : 'length[8]',
                  prompt : 'La password deve essere di almeno 8 caratteri'
                }
              ]
            }
          },
        onSuccess: function(event, fields) {
            event.preventDefault();
            $.ajax({
                type: 'post',
                url: '/login',
                data: $('form').serialize(),
                success: function () {
                    //"ok" label on success.
                    //$('#successLabel').css("display", "block");
                    console.log("success");
                }
            })
            .done(function( data ) {
                console.log(data);
                if (data.trim() == 'OK') {
                    window.location = "/";
                }
                else if (data == 'KO') {
                    $('.ui.error.message').html("Errore nel login");
                    $('.ui.form').addClass('error'); //response.msg
                }
                else {
                    var msg = JSON.parse(data);
                    if (msg['result']) {
                        window.location = msg['customs']['url'];
                    }
                    else
                        ShowMessage(msg, false);
                }
            });      
        }
        });
    
    
        $(document).keypress(function(event){
            var keycode = (event.keyCode ? event.keyCode : event.which);
            if (keycode == '13'){
                $("#btnLogin").click();
            }
        });
        
        $("#uname").focus();
    });
    
function timerfunc() {
    //document.body.style.backgroundImage = "url('" + images[i] + "')";
    var prev_class = "body"+(i);
    
    i = i + 1;
    if (i > images.length) {
        i =  1;
    }
    var next_class = "body"+(i);
    console.log(prev_class);
    console.log(next_class);
    $(document.body).addClass(next_class, 2000);
    $(document.body).removeClass(prev_class, 2000);
    
}
</script>
{/block}

{block name="html_body"}

<div class="ui middle aligned center aligned grid">
    <div class="column">
    
        
    
    
        <form class="ui large form" method="POST" style="background: #333; opacity: 0.7; padding: 30px; margin: 15px;">
        
            <img src="{$STATIC_URL}/img/webtree-logo.png" class="image"><br><br>
        
          <div class="ui stacked seg333ment">
          
          <div class="" style="color:#eee; text-align:left; font-family:'Open Sans', sans-serif; text-align:left !important; font-size:1.3em; margin: 20px;">
            Accedi a {$APPNAME} {if $TEST}{$RIBBON}{/if}
          </div>
        
            <div class="field">
              <div class="ui left icon input">
                <i class="user icon"></i>
                <input type="text" name="uname" id="uname" placeholder="Nome utente" style="-webkit-border-radius: 0px;
-moz-border-radius: 0px;
border-radius: 0px;">
              </div>
            </div>
            <div class="field">
              <div class="ui left icon input">
                <i class="lock icon"></i>
                <input type="password" name="passwd" placeholder="Password" style="-webkit-border-radius: 0px;
-moz-border-radius: 0px;
border-radius: 0px;">
              </div>
            </div>
            
            <div style="text-align:right;">
                <button type="button" id="btnLogin" class="ui left aligned  submit button">Login</button>
            </div>
          </div>

          <div class="ui error message">Login fallita!</div>

        </form>
        <br>

        {*
        <div class="ui message">
          Non hai un account? <a href="/registrati">Registrati</a>
        </div>

        <div class="ui message">
          Hai dimenticato la password? <a href="/recupera-password">Recuperala</a>
        </div>
        
        <div class="center aligned ">
        Ritorna a <a href="/">Home</a>
        </div>
        *}
        
        <div class="copyright">
            <span style="color:white; text-shadow: 1px 1px black;">2020 &copy; powered by </span><a href="http://www.idearespa.eu/" target="_blank">IDEARE</a>
        </div>
    
    </div>
</div>
{/block}
