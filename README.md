# Postgres & ogr2ogr workshop.

Workshop til opsætning af PostgreSQL, ogr2ogr osv.

Denne workshop vil beskrive opgaver vedrørende:

 - Installation og opsætning af Postgres på en Windows server.
 - Installation og opsætning af ogr2ogr vha. OsGeo4W 
 - Brug af ogr2ogr til konvertering af spatielle data mellem forskellige formater. 
 - Opsætning af Scheduler til automatisk kørsel af ogr2ogr script 
 - Logning af forespørgsler
 - Sikkerhedsopsætning i PostgreSQL.  
 - Forskelle på Windows miljø og Linux miljø 

Det allerførste råd: Hvis man blot lejlighedviss kal konvertere en enkelt fil eller tabel: Brug QGIS til dette formål. 
ogr2ogr er et kommandolinje værktøj som kan bruges til en meget lang række 
spatielle konverterings ogaver - og derfor kan være komplekst (og frustrerende  ) at bruge

Men hvis du har et konverterings job, som skal repeteres og automatiseres, er ogr2ogr det ideelle
værktøj til denne slag opgaver.

## Installation af PostgreSQL på Windows server.

Vi går ud fra at have en Windows baseret server til rådighed; med adgang til denne via RDP (Remote Desktop) 
samt have "Local Admin" rettigheder tilknyttet det username vi bruger til adgangen.  Vejledningen kan selvfølgelig også bruges til installation på den lokale pc.

De næste skridt udføres efter logon på Windows server vha. RDP med vores priviligerede username

 - Download af Postgres installationsfil fra EnterpriseDB web site:
https://www.enterprisedb.com/downloads/postgres-postgresql-downloads  
I kolonne "Windows x86-64" på hjemmesiden findes den ønskede version og denne downloades. Den seneste version af Postgres er pt. ver. 15.2

 - Initiel installation. Følg vejledning: https://manifold.net/doc/mfd9/install_postgresql.htm . Man skal være opmæksom på: 
   - Installationsfilen hedder sandsynligvis noget andet end det navn, som er angivet på hjemmesiden.
   - Placering af data directory (dvs. mappe, som Postgres vil placere database dat i). Dette vil normalt blive en undermappe i C:\"Programmer\Postgres\". 
Men man kan - om ønsket - allerede nu vælge en anden placering af data, således programemr og data adskilles. 
   - Password til "postgres" superuser. Dette password skal opfylde normale sikkerhedskrav til priviligerede konti, da "postgres" kontoen giver adgang til *alle* funktioner og *alle* tabeldata i databasesystemet.
   - Portnummer: Normalt vil installationen automatisk vælge port 5432. Men hvis denne er optaget, vil installationen vælge næste ledige portnummer. 

 - Opsætning af net adgang til PostgreSQL: Ved en standard installation af PostgreSQL vil Postgres kun kunne tilgåes lokalt, dvs. af programmer installeret
 på samme maskine som Postgres er installaeret på. 
 Så ved en *server* installation skal man sørge for, at Postgres kan kommunikere med andre programmer via nettet.
 (Hvis PostgreSQL kun skal bruges som et lokal data repository er det ikke nødvendigt med de efterfølgende operationer)

    - Firewall opsætning: https://manifold.net/doc/mfd9/open_a_firewall_port_for_postgresql.htm
    - Postgres kommunikationsopsætning: https://manifold.net/doc/mfd9/enable_network_access_to_postgresql.htm

 - Opsætning af PGAdmin: Administrationsværktøjet PGAdmin er installeret samtidig med PostgreSQl. Men det kræver et par ekstra opsætninger for at fungere korrekt. Følg denne vejledning:
https://github.com/Skadesokonomi/Installation#ops%C3%A6tning-af-pgadmin4-administrationsv%C3%A6rkt%C3%B8j (Kun afsnit "Opsætning af PGAdmin4 administrationsværktøj")

 - Tuning af Postgres: Ved en standard installation er PostgreSQL sat meget "konservativt" op. Det vil sige, 
at den bruger meget få ressourcer og kan arbejde på selv meget "små"  pc'er. Dette betyder så til gengæld, at PostgreSQL
 arbejder væsentligt langsommere end den er i stand til på den specifikke pc. For at få PostgreSQL til at yde sit bedste, bør installationen "tunes" ved at ændre på en række 
 PostgreSQL paramatre, som bestemmer CPU og hukommelsesforbrug. Denne process kan være en kompleks og langvarig affære . Men man kan foretage en "Rough and ready" tuning af PostgreSQL
 parametre ved at følge anvisningerne på følgende hjemmeside: https://pgtune.leopard.in.ua/

 - Installation af PGAdmin på laptop: Genbrug installationsfilen fra EnterpriseDB, men fjern alle installationselementer udover PGAdmin

## ogr2ogr til konvertering af spatielle data mellem forskellige formater. 
ogr2ogr er et kommandolinje program som er i stand til at både læse fra og skrive "simple features" (geodata med attributter) ud i dusinvis af forskellige formater, men i 
denne workshop fokuserer vi primært på at skrive data til PostgreSQL og hente data fra en række meget benyttede dataformater
(Primært MSSQL Server) 

I forbindelse med oversættelsen kan ogr2ogr endvidere forskellige delopgaver, såsom udvælgelse baseret på spatielle og/eller attributværdier, kolonnevalg samt ændring af projektion under oversættelsen.

### Installation og opsætning.

Hvis du har installeret QGIS på din pc, har du allerede installeret ogr2ogr. Du kan umiddelbart starte med at bruge ogr2ogr ved at søge "OSGeo4W Shell" i Windows programsøger. Dette program starter en DOS kommandlinje op, hvrod der umidsdelbart er adgang til ogr2ogr

En anden metode er at downloade OsGeo4W installer fra QGIS.ORG's hjemmeside https://qgis.org/en/site/forusers/alldownloads.html#osgeo4w-installer og start den op 
Vælg "Express Install" og afkrydse "GDAL", når du skal vælge installationspakker.

Denne hurtige installation medtager dog ikke alle drivere. Så hvis der mangler en driver efter "Express Install" kan man med fordel benytte installationsværktøjet igen og denne gang bruge "Advanced Install", sektion "Libs" for at installere ekstra drivere.

Hvis du har brug for de absolut nyeste og evt. beta udgaver af GDAL/OGR kan du benytte flg. hjemmeside: https://www.gisinternals.com/ og downloade herfra.

Hvis du skal bruge ogr2ogr i et DOS script, kræver skal man have div. path environment variable på plads, før ogr2ogr kan fungere.  

Eksempel på nødvendige kommandoer i en .cmd-fil, som skal udføre ogr2ogr
```
set OSGEO4W_ROOT=c:\OSGeo4W
set path=%OSGEO4W_ROOT%\bin;%OSGEO4W_ROOT%\apps\proj-dev\bin;%OSGEO4W_ROOT%\apps\gdal-dev\bin;%WINDIR%\system32;%WINDIR%;%WINDIR%\system32\WBem
SET PROJ_LIB=%OSGEO4W_ROOT%\share\proj
SET PGCLIENTENCODING=WIN-1252
REM ogr2ogr...... kommandolinje for ogr2ogr
```
Et godt råd ved udfærdigelse at scripts: Genbrug virkende eksempler. Man vil - erfaringsmæssigt - lave masser af fejl ved "nyprogrammering". 
Hvis man skal starte helt forfra: Først skriv den mest simple kommandolinje, som klarer arbejdet; derefter forfin denne, fungerende kommando med ekstra qualifiers 


### ogr2ogr kommando grundlæggende parametre

Fra hjemmesiden for ogr2ogr https://gdal.org/programs/ogr2ogr.html
```
ogr2ogr [--help-general] [-skipfailures] [-append | -upsert] [-update]
        [-select field_list] [-where restricted_where|@filename]
        [-progress] [-sql <sql statement>|@filename] [-dialect dialect]
        [-preserve_fid] [-fid FID] [-limit nb_features]
        [-spat xmin ymin xmax ymax] [-spat_srs srs_def] [-geomfield field]
        [-a_srs srs_def] [-t_srs srs_def] [-s_srs srs_def] [-ct string]
        [-f format_name] [-overwrite] [[-dsco NAME=VALUE] ...]
        dst_datasource_name src_datasource_name
        [-lco NAME=VALUE] [-nln name]
        [-nlt type|PROMOTE_TO_MULTI|CONVERT_TO_LINEAR|CONVERT_TO_CURVE]
        [-dim XY|XYZ|XYM|XYZM|2|3|layer_dim] [layer [layer ...]]

        # Advanced options
        [-gt n]
        [[-oo NAME=VALUE] ...] [[-doo NAME=VALUE] ...]
        [-clipsrc [xmin ymin xmax ymax]|WKT|datasource|spat_extent]
        [-clipsrcsql sql_statement] [-clipsrclayer layer]
        [-clipsrcwhere expression]
        [-clipdst [xmin ymin xmax ymax]|WKT|datasource]
        [-clipdstsql sql_statement] [-clipdstlayer layer]
        [-clipdstwhere expression]
        [-wrapdateline] [-datelineoffset val]
        [[-simplify tolerance] | [-segmentize max_dist]]
        [-makevalid]
        [-addfields] [-unsetFid] [-emptyStrAsNull]
        [-relaxedFieldNameMatch] [-forceNullable] [-unsetDefault]
        [-fieldTypeToString All|(type1[,type2]*)] [-unsetFieldWidth]
        [-mapFieldType type1|All=type2[,type3=type4]*]
        [-dateTimeTo UTC|UTC(+|-)HH|UTC(+|-)HH:MM]]
        [-fieldmap identity | index1[,index2]*]
        [-splitlistfields] [-maxsubfields val]
        [-resolveDomains]
        [-explodecollections] [-zfield field_name]
        [-gcp ungeoref_x ungeoref_y georef_x georef_y [elevation]]* [-order n | -tps]
        [[-s_coord_epoch epoch] | [-t_coord_epoch epoch] | [-a_coord_epoch epoch]]
        [-nomd] [-mo "META-TAG=VALUE"]* [-noNativeData]
```
Som det ses er der rig lejlighed til at tage fejl ! Og ovenstående inkluderer end ikke de mange forskellige --config, -lco (layer creation options) og -dsco (data set creation oiptions) knyttet til de forskellige datakilder

En minimum kommandolinje med ogr2ogr har følgende udseende: 
```
og2ogr -f format_name dst_datasource_name src_datasource_name [-nln name] [layer [layer ...]]
```
[...] betyder, at denne tekstdel i nogle tilfælde kan undværes.

Vi gennemgår kommadolinjen med en række eksempler, som løbende udvider brugen af ogr2ogr's mange faciliteter.

### PostgreSQL som modtager (destination datasource)

Et eksempel på den simpleste ogr2ogr kommando, som bruger PostgreSQL som data destination: 
```
ogr2ogr -f "PostgreSQL" pg:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata active_schema=fot" bygninger.tab
```
 1. Der bruges en tab-fil: *bygninger.tab* som inddata (Tab-filer indeholder kun eet lag, så det er ikke nødvendigt at definere et specifikt lagnavn.
 1. Data destination er en PostgreSQL database *-f "PostgreSQL"*
 1. Postgres databaserver og database defineres: 
```
 pg:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata active_schema=fot"
```
 Database server server er placeret på 
 *localhost* og med portnummer *5432*, postgres username er *myuser* og 
 password er *mypassword* og vi arbejder med database *geodata* på serveren. Slutteligt er parameter *active_schema* sat, 
 således ogr2ogr primært vil bruge dette schema når tabelangivelser på kommadolinjen ikke indeholder en specifik schema definition
 1. tabelnavnet bliver databasen er *fot.bygninger*, fordi *active_schema* er sat til "fot". 
 
### Speedup af indlæsning

For mange destination sources gælder det, at indlæsning kan optimeres; eksempelvis for PostgreSQL:
```
ogr2ogr --config PG_USE_COPY YES -gt 100000 -f "PostgreSQL" pg:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata active_schema=fot" bygninger.tab
```
hvor --config PG_USE_COPY YES betyder, at PostgreSQL driversn benytter *COPY...*  i stedet for *INSERT...* til indskrivning af data
og -gt 100000 indskriver op til 100000 poster ad gangen (tællet kan ændres)

Man skal dog være varsom med at bruge *-gt*: Benyttes den sammen med *-skipfailures*, som får  ogr2ogr til at fortsætte efter fejlindlæsning af en post, risikerer man at
ogr2ogr skipper hele bufferen, dvs, den fejlramte post samt 99999 andre poster, som sandsynligvis ikke er fejlbehæftede.


### Garanti for, at alle elementer er af samme type.

Tab-filer (og andre datakilder) skelner ikke mellem simple og mulityper. PostgreSQL accepterer kun een bestemt type pr. tabel. Dette kan give problemer. 
ogr2ogr kan løse dette problem ved at tilføje qualifier *-nlt PROMOTE_TO_MULTI* , som konverterer
 alle ikke-multi elementer til de tilsvarende multi element typer

Hvis der arbejdes med datakilder som tillader forskellige geometritype i samme datakilde - som f.eks tab-filer - kan 
man endvidere benytte *-where* qualifier til at filtre på geometrityper.
``` 
ogr2ogr -nlt PROMOTE_TO_MULTI -where="OGR_GEOMETRY='POLYGON' OR OGR_GEOMETRY='MULTIPOLYGON'" -f "PostgreSQL" pg:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata" bygninger.tab -nln fot.bygninger
```
I PostgreSQL kan man tjekke geometri type i en tabel (pg_schema.pg_table i eksemplet) med følgende:
``` 
SELECT ST_geometrytype(geom), COUNT(*) FROM pg_schema.pg_table GROUP BY 1 ORDER BY 2
``` 


### Styring af projektion 
ogr2ogr har 3 qualifiers til at styre projeksions funktioner 

  1. -a_srs EPSG:25832 : Sætter datasæt i modtagerkilder til at være EPSG:25832 ( i dette tilfælde) uanset om datakilde indeholder en anden (eller ingen) projektionsangivelse. Kan bruges til at rette evt forkte projektionsdefinitioner i datakilder. 
  1. -s_srs EPSG:4326: Sætter datakilde til en bestemt projektion. I dette tilfælde EPSG:42326
  1. -t_srs EPSG:25832: Sætte motager datakilde til en bestemt projektion (EPSG:25832). 
  
Ved brug af både -s_srs og -t_srs med forskellige projektionsdefinitioner vil ogr2ogr foretage en projektions konvertering af data. 
```
ogr2ogr -s_srs EPSG:25832 -t_srs EPSG:4326 -f "PostgreSQL" pg:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata" bygninger.tab -nln fot.bygninger
```
... vil projektions-konvertere datakilde fra EPSG:25832 til EPSG:4326 før data indlæses i PostgreSQL 


### MSSQL Server som datasource

MSSQL Server datakilde definition:
 - SQLServer security:  "MSSQL:server=localhost\sqlexpress;database=geodata;uid=sa;pwd=password;"
 - Integrated security: "MSSQL:server=localhost\sqlexpress;database=geodata;trusted_connection=yes;"

ogr2ogr eksempel fra MSSQL Server til PostgreSQL med SQLServer intergrated security - 

En tabel kopieres fra SQL Server til Postgres og en evt. eksisterende Postgres tabel erstattes (overskrives) helt med en ny tabel
```
ogr2ogr -f "PostgreSQL" -lco OVERWRITE YES -lco SCHEMA=pgschema pg:"pghost port=5432 user=pguser password=pgpassword dbname=pgdatabase" \
"MSSQL:server=msserver;database=msserver;trusted_connection=yes;" "msschema.mstable"
```

En tabel kopieres fra SQL Server til Postgres. Den eksisterende modtagertabel tømmes helt for data og nye data kopieres til den eksistrende tabel. 
Denne kommando fejler, hvis modtagertabel ikke eksisterer.
```
ogr2ogr -f "PostgreSQL" -append -update --config OGR_TRUNCATE YES -nln pgschema.pgtable   pg:"host=pghost port=5432 user=pguser password=pgpassword dbname=pgdatabase" \
"MSSQL:server=msserver;database=msdatabase;trusted_connection=yes;" "msschema.mstable"
```
I begge kommandoer skal *pghost, pgdatabase, pguser, pgpassword, pgschema, pgtable, msserver, msdatabase, msschema og mstable* erstattes af de rigtige værdier for de forskellige informationer
 

### Pitfalls

Der er mange af ogr2ogr qualifiers, som udelukker hinanden, eksempelvis *-spat* og *-where*. Generelt skal alle qualifiers, som begrænser rækker eller kolonner, bruges med varsomhed sammen. 
Der er det bedre direkte af bruge *-sql* og definere filtreringen i SQL. SQL kan også bruges på datakilder som ikke er databaser.

### Brug af ogrinfo

```
 ogrinfo -q -sql "ALTER TABLE pg_schema.pg_table ADD aendringsdato varchar(10) NULL DEFAULT current_date::character varying" PG:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata"
 ogrinfo -q -sql "UPDATE pg_schema.pg_table SET aendringsdato=current_date::character varying" PG:"host=localhost port=5432 user=myuser password=mypassword dbname=geodata"
```
Se i øvrigt multiple eksempler fra : https://github.com/bvthomsen/ogr_scripts

## Logning af forespørgsler

Der er flere måder at enable logning i PostgreSQL. Flertallet kræver installation af en extension. 

Nedenstående metode kræver ingen ekstra installation,  men kræver en række rettelser i *postgres.conf* filen placeret i *data* mappen for PostgreSQL 
- Ændringer i PostgreSQL opsætning. Find nedenstående afsnit i filen og tilpas flg. parametre
```
#------------------------------------------------------------------------------
# ERROR REPORTING AND LOGGING
#------------------------------------------------------------------------------

...#log_directory = 'pg_log' to log_directory = 'pg_log'

...#log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log' to log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'

...#log_statement = 'none' to log_statement = 'all'

...#logging_collector = off to logging_collector = on


log_destination = 'csvlog'                       # 'csvlog' means that data is placed i an csv file

logging_collector = on                           # Required to be on for csvlogs. 

log_statement = 'none';                          # Generally disable logging.
                                                 # Logging will be enbled on a per database basis
		         # to minimize log file size

log_directory = 'pg_log'                         # directory where log files are written,
                                                 # relative to PGDATA

log_filename = 'pglog_%Y_%m_%d.log'              # log file name pattern, per day example
                                                 # "pglog" kan med fordel erstattes med servernavn eller lign.

log_rotation_age = 1d                            # Automatic rotation of logfiles will happen after 1 day		

```

 - Aktivér logning in en specifick database (brug PGAdmin):

```
ALTER DATABASE my_very_important_database SET log_statement = 'all';
```
- Konvertering af csv fil til tabel inkl. rollover af logning

Se eksempel, hvorledes csv files omdannes til tabeller i PostgreSQL vha. ogr2ogr: https://github.com/AestasGIS/Postgres-ogr2ogr-workshop/blob/main/csv2postgres.cmd 

## Opsætning af Scheduler til automatisk kørsel af ogr2ogr script

Der findes en app i kotrolpanelet: "Administration" --> "Opgavestyring" som giver et 
"Peg og klik" brugerflade til styring opgaver. Jeg synes personligt, at det er nemmere 
og mere overskueligt at benytte kommandolinje værktøjet "SCHTASKS"
Se: https://ss64.com/nt/schtasks.html

For at opsætte et dagligt job:
  1. I Start --> Søgefeltet (Skiv for at søge): Led efter "CMD.exe".
  1. Højreklik på øverste (eller eneste) resultat og klik på "Kør som administrator"
  1. Klik på "Ja" for at acceptere at CMD kører med administrator privilegier.
  1. I CMD billedet skrives følgende kommando for at opsætte et daglig job startende kl. 11.00: 

```
SCHTASKS /CREATE /SC DAILY /TN "PG og OGR jobs\Indlæs PG log-fil" /TR "D:\MinMappe\pg_load_log_csv.cmd" /ST 11:00
```
For at opsætte et ugentligt job: Start CMD med administrator privilegie og skriv følgende kommando i CMD dialogen:
```
SCHTASKS /CREATE /SC WEEKLY /D SUN /TN "PG og OGR jobs\Overfør data fra LOIS til PG" /TR "D:\MinMappe\OGR_LOIS_til_PG.cmd" /ST 11:00
```
For at opsætte et ugentligt job: Start CMD med administrator privilegie og skriv følgende kommando i CMD dialogen:
```
SCHTASKS /CREATE /SC WEEKLY /D SUN /TN "PG og OGR jobs\Overfør data fra LOIS til PG" /TR "D:\MinMappe\OGR_LOIS_til_PG.cmd" /ST 11:00
```
Man kan bruge /RU *username* og /RP *password* til at køre et task med en specifik  brugerkonto

For at fjerne et eksisterende jobs: Start CMD med administrator privilegie og skriv følgende kommando i CMD dialogen:
```
SCHTASKS /DELETE /TN /TN "PG og OGR jobs\Overfør data fra LOIS til PG"
```

### Automatiseret overførsler af data fra DataFordeler.

Jeg tænker, at vi alle har en "yndlings prügelknabe" i Datafordeleren. Uanset dette, kan man (hvir man er heldig - det har ikke noget dygtighed at gøre) 
få sat et såkaldt "abonnement" op som eks. hver uge sørger for at stille et opdaterede datasæt til rådighed via ftp.
Disse data kan automatisk indlæses i Postgres med følgende kombination af DOS script oget Python script: 

 - https://github.com/AestasGIS/Postgres-ogr2ogr-workshop/blob/main/tabdir2postgres.cmd
 - https://github.com/AestasGIS/Postgres-ogr2ogr-workshop/blob/main/download_unzip.py
 
For at disse script kan fungere skal der være en QGIS installeret på systemet, der udfører scriptet.

 - i "tabdir2postgres.cmd opsættes alle parametre: Div. username/passwords, div. andre parametre samt placeringen af QGIS. Læs kommentarer i scripts
 - Python scriptet skal der ikke umiddelbart ændres på, hvis man har valgt et abonnement som er nogenlunde ækvivalent med eksemplet (GeoDanmark60_TAB)

NB! Scriptet er absolut "bare bones": Ingen fejlhåndtering og Python koden er ikke alt for køn. Og der bruges ingen, lidt mere avancerede, faciliteter som "Atom feeds" o.lign. 
Det er et download af hele datasamlingen hver uge. Men de 2 scripts demonstrerer, hvorledes man kan opsætte 
en automatiseret download af data fra Datfordeler til en lokal Postgres database.

Man kunne faktisk godt have skrevet ét samlet python script, som håndterede både download, udpakning samt indlæsning i PostgreSQL. 
Dette ville krævet downloads af ekstra Python funktions biblioteker. Så det nuv. eksempel er udformet, således det kun bruger faciliteter/funlktioner, 
som er til rådighed ved en standard installation af QGIS 

Opsætning af Task scheduler kunne have følgende udseende:
```
SCHTASKS /CREATE /SC WEEKLY /D SUN /TN "PG og OGR jobs\Overfør GeoDanmark data fra Datafordeler til PG" /TR "D:\MinMappe\tabdir2postgres.cmd" /ST 11:00
```


## Sikkerhedsopsætning i PostgreSQL.

I dette afsnit gennemgår vi (hurtigt) sikkerhedssystemet i PostgreSQL. Der beskrives en række "do and don't-s" ved sikkerhedsopsætning i PostgreSQL.

Slutteligt er der et komplet eksempel på opsætning, hvorldes man kan gennemføre en fornuftig sikkerheds opsætning i en PostgreSQL database.   

 - Sikkerheds opsætning i Postgres varetages af *roles* eller *roller* på dansk.
 - En rolle er en identitet, som tildeles eller fratages *rettigheder* i databasen. 
 - En rettighed er muligheden for at foretage en eller flere *funktioner* i databasen, f.eks. at kunne udvælge data fra en bestemt tabel. 
 - Man kan tidele rettigheder direkte til en rolle, men man kan også tilmelde en rolle til en anden rolle, således den første rolle arver rettighederne fra rolle nr. 2
 - To typer af roller: interaktive brugere (*WITH LOGIN*) og ressourceroller.
 - Interaktive brugere (repræsenterer dem, der sidder foran skærmen) skabes som ”roller med login rettigheder”.
 - Af historiske årsager kan en rolle med login også kaldes en *user*. De to nedenstående kommandoer giver det samme resultat:

```
CREATE ROLE bo WITH LOGIN PASSWORD 'thomsen' VALID UNTIL ‘2025-01-01' INHERIT -- brug af "role with login";
CREATE USER bo PASSWORD 'thomsen' VALID UNTIL ‘2025-01-01' INHERIT -- brug af "user"; samme resultat;
```
*INHERIT* betyder, at rollen arver rettigheder fra de roller som den interaktive rolle senere meldes ind i. 

 - Ressourcegrupper er roller, som tildeles specifikke rettigheder over for tabeller, schemaer og andre objekter i databasen. 
Ressourcegrupper tildeles *ikke* login rettigheder, men fungerer som ”skabeloner”  eller "profiler" for database adgang til interaktive brugere.

```
CREATE ROLE gisdb_write; 
GRANT CONNECT, TEMP ON DATABASE gisdb TO gisdb_write;
GRANT USAGE ON SCHEMA data, lookup TO gisdb_write;;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA data TO gisdb_write;
GRANT SELECT ON ALL TABLES IN SCHEMA lookup TO gisdb_write;
```
 
Interaktive brugere kan tildeles rettigheder ved at ”melde dem ind” i ressourcegrupper
```
GRANT gisdb_write TO bo;
```
Efter denne *GRANT* kommando har user "bo" fået tildelt (dvs. adderet)  samme rettigheder som rolle "gisdb_write"


Interaktive brugere fratages rettigheder ved at ”melde dem ud”  af ressourcegrupper
```
REVOKE gisdb_write TO bo;
```
###Regler for at lave sikkerhedsopsætning med mindst risiko for at havne på den lukkede afdeling..

 - Lav interaktive roller for brugere uden andre direkte rettigheder
 - Lav ressource grupper uden login rettigheder, men med specifikke rettigheder til objekter i databasen.
 - Tildeling eller fratagelse af rettigheder foretages (kun) ved at melde bruger ind i eller ud af de relevante ressource grupper.
 - Opret schemaer i databasen, som kan bruges til *funktionel* opdeling af tabeller i forskellige grupper (datatabeller, opslagstabeller osv.) 
 - Og tildel så rettigheder på schema niveau, ikke på tabel niveau.

Et real-life script til opsætning af en database efter ovenstående principper: https://github.com/AestasGIS/Postgres-ogr2ogr-workshop/blob/main/skovuser_administration.sql

## Forskelle på Windows miljø og Linux miljø 

TBD
