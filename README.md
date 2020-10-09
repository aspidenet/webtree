# Webtree

**Webtree** è un portale web e permette la navigazione tra i dati che un ente vuole pubblicare (internamente o esternamente). Se internamente, è possibile profilare gli utenti in modo da poter visualizzare solo una parte dei dati (quelli di competenza) e solo un sottoinsieme delle funzioni disponibili.
L'utilizzo tipico di Webtree è il seguente: si creano delle stored procedure sul database in modo da accedere ai dati voluti; si pubblicano le stored procedure su Webtree configurando alcune schermate nel menu amministrazione; infine si danno i permessi agli utenti o gruppi di utenti in modo che possano richiedere queste estrazioni dati e visualizzarle.
Webtree è inoltre un framework per realizzare applicazioni a sé stanti (scrivendo codice PHP/Javascript e realizzando pagine extra).

## Pre-requisiti
Webtree è una webapp e come tale necessita di un webserver funzionante, PHP ed un database (il codice sorgente è scritto per Microsoft SQL Server ma con piccolissime correzioni è possibile usare qualsiasi database in quanto il codice usato è SQL standard al 99%).
Supponiamo che il webserver sia Apache, sia già istallato e configurato insieme a PHP e al database.

## Istallazione

Copiare i sorgenti in una cartella del server (PATH-WEBTREE). 
Istallare Composer e i seguenti pacchetti: klein, smarty e adodb. Dopo l'istallazione dei package composer, nella cartella di istallazione assieme alle sottocartelle html, src e template_c comparirà anche vendor.
Abilitare, se già non fosse abilitato, il modulo di Apache mod_rewrite.
Creare in Apache un Virtualhost che punti alla cartella PATH-WEBTREE/html (html è la cartella che contiene le pagine pubbliche della webapp).
Infine, sempre nel Virtualhost appena creato, inserire la seguente direttiva:

    <Directory PATH-WEBTREE/html>
        RewriteEngine on
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteRule . index.php [L]
    </Directory>
    
Sul database, lanciare lo script che crea le tabelle (src/dbscript.sql).

## Configurazione
Rinominare il file src/customs-dist.inc.php in src/customs.inc.php.
In questo file sono presenti le costanti che la webapp utilizzerà.

- APPNAME: nome dell'applicazione. (Webtree)
- BASE_DIR: path della cartella dei sorgenti. Coincide con PATH-WEBTREE.
- APP_BASE_URL: è il path relativo tra il dominio e la root (/) della app. Se l'URL della app fosse per esempio: webtree.DOMINIO/ questo valore deve essere vuoto. Se invece l'URL fosse DOMINIO/altropath/webtree/ allora questo parametro deve essere impostato a "/altropath/webtree".

- DB_TYPE: driver del database. E' un valore tra quelli supportati dalla libreria ADODB che viene utilizzata per accedere ai dati. Maggiori informazioni a riguardo su [ADODB](http://adodb.org) e su [Microsoft PHP driver per SQL Server](https://docs.microsoft.com/it-it/sql/connect/php/microsoft-php-driver-for-sql-server?view=sql-server-2017).
- DB_HOST_SERVER: indirizzo del server database. Il suo formato (IP o nome dell'istanza) dipende dalla configurazione del driver per accedere al database.
- DB_USERNAME: nome dell'utente per accedere al database. Deve essere codificato in base64.
- DB_PASSWORD: password dell'utente per accedere al database. Deve essere codificata in base64.
- DB_NAME: nome del database dove sono state create le tabelle tramite lo script src/dbscript.sql.
