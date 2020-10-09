
<div class="ui header left aligned">{$template->label()}</div>
        
{foreach key=key item=item from=$template->getFields()}
    {$item->display("I", $record[$item->dbfield()|lower])}
{foreachelse}
<div>Template sconosciuto, nessun campo inserito.</div>
{/foreach}
