{extends file="template-private.tpl"}

{block name="content"}
<script>

var tabulator_users;
$(function(){
    {$tabulator->display("tabulator_users", "false", null, "rowClick")}
});
function rowClick(e, row) {
    var code = row.getData()['username'];
    var url = '/admin/config/users/update/'+code;
    //modal_popup_url(, onHideTemplateField);
    redirect(url);
}
function onHideTemplateField() {
    var url = "/admin/config/users/list";
    redirect(url);
    //tabulator_users.setData();
}
function onHideTemplateNew() {
    console.log("config-users-list::onHideTemplateNew()");
    
}
function onApproveTemplateNew() {
    console.log("config-users-list::onApproveTemplateNew()");
    var url = "/admin/config/users/list";
    redirect(url);
    //tabulator_users.setData();
    return false;
}
</script>



{* tastoni *}
<div id="toolbar" style="padding-top: 0.5em;">
    
    <div class="ui stackable two column grid">
        <div class="column">
            
            
            {assign var="current_id" value="userfdkjfijiwerjjdf"}
            <button onclick="modal_page_new(
                        '{$current_id|md5}',
                        '{$APP_BASE_URL}/modal/wizard/new/users',
                        'large', 
                        onHideTemplateNew, 
                        onApproveTemplateNew
                    )" class="ui green button"><i class="add icon"></i> Nuovo utente</button> 
            
            
            
        </div>
        <div class="right aligned column">
            <a class="ui grey button" href="{$APP_BASE_URL}/admin">Indietro</a>
        </div>
    </div>
    
</div>
{* fine tastoni *}

<div class="ui header">{$template->label()}</div>
<div id="tabulator_users" style="margin: 3px;"></div>


{/block}