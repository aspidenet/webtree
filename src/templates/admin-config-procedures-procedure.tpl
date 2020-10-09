<div class="ui header left aligned">

    {$template->label()}
    
    <button onclick="modal_page_new(
                '{$record_code|md5}', 
                '/modal/{$record_code|md5}/template/{$template->code()}/update/{$record_code|upper}', 
                'large', 
                function() { }, 
                function() {
                    sendFormTemplate(
                        '{$record_code|md5}',
                        '/modal/template/{$template->code()}/update/{$record_code|upper}',
                        function() {
                            redirect('');
                        }
                    )
                }
            )" class="ui green button"><i class="write icon"></i> Modifica</button>  

</div>

        
{foreach key=key item=item from=$template->getFields()}
    {$item->display("R", $record[$item->dbfield()])}
{foreachelse}
<div>Template sconosciuto, nessun campo inserito.</div>
{/foreach}