{extends file="template-private.tpl"}

{block name="content"}
<script type="text/javascript">
$(document).ready(function() {

});
</script>

<div class="heading">
    <h2>Oooops!</h2>
</div>




<div class="ui icon message">
  <i class="exclamation triangle icon"></i>
  <div class="content">
    <!--div class="header">
      404 Pagina non trovata
    </div-->
    <p>Si è verificato un errore inaspettato. Perché non provi a ricaricare la pagina? O se il problema persiste, contattaci. </p>
    <p><i>An unexpeted error seems to have occurred. Why not try refreshing your page? Or you can contact us if the problem persists.</i></p>
    <a href="mailto:{$EMAIL_SUPPORT}">{$EMAIL_SUPPORT}</a>
  </div>
</div>










{/block}