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
 
 Der vil specielt blive lagt vægt på konverteringen fra  MSSQL Server til PostgreSQL, 
 men andre datakilder vil også blive beskrevet

Hvor det er muligt, vil dette dokument blot henvise til andre hjemmesider for de forskellige operationer. 
(I stil med *ikke* at genopfinde den dybe tallerken og det varme vand).
I skrivende stund er disse hjemmesider "up to date" og retvisende. Dette kan ikke garanteres ud i al fremtid.

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


## Installation og opsætning af ogr2ogr vha. OsGeo4W 


## Brug af ogr2ogr til konvertering af spatielle data mellem forskellige formater. 

### Klargøring (opsætning af environment variables og path i .cmd fil.

### ogr2ogr kommando grundlæggende parametre

>ogr2ogr [--help-general] [-skipfailures] [-append | -upsert] [-update]
>        [-select field_list] [-where restricted_where|@filename]
>        [-progress] [-sql <sql statement>|@filename] [-dialect dialect]
>        [-preserve_fid] [-fid FID] [-limit nb_features]
>        [-spat xmin ymin xmax ymax] [-spat_srs srs_def] [-geomfield field]
>        [-a_srs srs_def] [-t_srs srs_def] [-s_srs srs_def] [-ct string]
>        [-f format_name] [-overwrite] [[-dsco NAME=VALUE] ...]
>        dst_datasource_name src_datasource_name
>        [-lco NAME=VALUE] [-nln name]
>        [-nlt type|PROMOTE_TO_MULTI|CONVERT_TO_LINEAR|CONVERT_TO_CURVE]
>        [-dim XY|XYZ|XYM|XYZM|2|3|layer_dim] [layer [layer ...]]
>
>        # Advanced options
>        [-gt n]
>        [[-oo NAME=VALUE] ...] [[-doo NAME=VALUE] ...]
>        [-clipsrc [xmin ymin xmax ymax]|WKT|datasource|spat_extent]
>        [-clipsrcsql sql_statement] [-clipsrclayer layer]
>        [-clipsrcwhere expression]
>        [-clipdst [xmin ymin xmax ymax]|WKT|datasource]
>        [-clipdstsql sql_statement] [-clipdstlayer layer]
>        [-clipdstwhere expression]
>        [-wrapdateline] [-datelineoffset val]
>        [[-simplify tolerance] | [-segmentize max_dist]]
>        [-makevalid]
>        [-addfields] [-unsetFid] [-emptyStrAsNull]
>        [-relaxedFieldNameMatch] [-forceNullable] [-unsetDefault]
>        [-fieldTypeToString All|(type1[,type2]*)] [-unsetFieldWidth]
>        [-mapFieldType type1|All=type2[,type3=type4]*]
>        [-dateTimeTo UTC|UTC(+|-)HH|UTC(+|-)HH:MM]]
>        [-fieldmap identity | index1[,index2]*]
>        [-splitlistfields] [-maxsubfields val]
>        [-resolveDomains]
>        [-explodecollections] [-zfield field_name]
>        [-gcp ungeoref_x ungeoref_y georef_x georef_y [elevation]]* [-order n | -tps]
>        [[-s_coord_epoch epoch] | [-t_coord_epoch epoch] | [-a_coord_epoch epoch]]
>        [-nomd] [-mo "META-TAG=VALUE"]* [-noNativeData]

- PostgreSQL som modtager
- Datakilder
  - MSSQL Server
  - GeoPackage
  - MapInfo
  - Shape
  - WFS

- Projection valg -i
- Schema valg
- Overskrivning / opdatering af data
- Tilføjelse af af adm data (ogr select)
- Tuning af kommando med buffer

## Opsætning af Scheduler til automatisk kørsel af ogr2ogr script
- Opsætning af Scheduler via kommandlinjen. 
## Logning af forespørgsler
- Ændringer i PostgreSQL opsætning
- Konvertering af csv fil til tabel inkl. rollover af logning
- Opsætning af Schedule
## Sikkerhedsopsætning i PostgreSQL.
- Roller i PostgreSQL - ressourceroller og brugerroller.
- Eksempel Script  
## Forskelle på Windows miljø og Linux miljø 


