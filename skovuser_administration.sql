/*

   Dette script illustrerer muligheden for at administrere database til på *schema* niveau
   Dvs., man opretter schemaer, hvor tabeller placeres efter funktion/sikkerhedsniveau. 
   Brugere tildeles så adgangsrettigheder på basis af deres rolle i organisationen.
   
   Denne metoder gør administration af sikkerhed til de enkelte tabeller meget nemmere:
   En ny tabel placeres i det relevante schema, hvorved tabellen får en stadard sikkerheds
   niveau svarernde til schemaets. Så man slipper for rolle administration på tabel niveau.

   (Man skal selvfølgelig tænke grundigt mht. den initielle opsætning af schemaer - YMMV) 

   Eksemplet arbejder med to specifikke schemaer i database "skov": 

   -- "data" som indeholder tabeller, der skal opdateres af en række brugere, f.eks. ved 
      grøn registrering i felten   

   -- "opslag" som indeholder opslags lister/tabeller som skal kunne læses af alle brugere, men 
      *kun* redigeres af administratorer.

   Til dette formål oprettes så 3 ressource roller uden login rettigheder men med forskellige
   rettigheder i schemaerne.       

   -- skov_reader        : Kan læse data fra alle schemaer i databasen, men ikke opdatere data; 
      benyttes til analyse brugere 

   -- skov_datawriter    : Kan læse data fra alle schemaer i databasen og skrive i schema "data";
      benyttes til "data indsamlere"

   -- skov_administrator : Har alle rettigheder inkl. oprettelse af nye schemaer; opdatering af 
      opslagstabeller osv.

   Slutteligt oprettes personlige brugerkonti (roller med login rettighed samt INHERIT) som tildeles
   medlemsskab til de forskellige ressource roller
   
   Copyright 2022: Bo Victor Thomsen, AestasGIS
   
*/

-- Dette script skal køres af en Postgres superuser, f.eks. user "postgres"

-- Husk at ændre database navn "skov" til det korrekte database navn

-- Opret refererede schemaer - Just in case...
CREATE SCHEMA IF NOT EXISTS data;
CREATE SCHEMA IF NOT EXISTS opslag;

-- Opret ressourcegrupper. 
-- Husk at disse roller administres på database *server* niveau, ikke database niveau, 
-- så de deles af alle databaser på server. Så pas på navne sammenfald. 
CREATE ROLE skov_reader        NOINHERIT; -- kan læse data fra alle schemaer i databasen
CREATE ROLE skov_datawriter    NOINHERIT; -- kan læse data fra alle schemaer i databasen og skrive i schema "data"
CREATE ROLE skov_administrator NOINHERIT; -- har alle rettigheder inkl. oprettelse af nye schemaer

-- Fjern alle standard rettigheder fra schemaer, inkl. schema "public" from role "PUBLIC"
REVOKE ALL ON SCHEMA public, data, opslag FROM PUBLIC;
REVOKE ALL ON DATABASE skov FROM PUBLIC;  

-- Tildel rettigheder til de forskellige ressourcegrupper

-- Adgang til database
GRANT CONNECT, TEMP ON DATABASE skov TO skov_reader, skov_datawriter;
GRANT ALL ON DATABASE skov TO skov_administrator;

-- Adgang til schemaer for read gruppe
GRANT USAGE ON SCHEMA public, data, opslag TO skov_reader, skov_datawriter;

-- Administrator får alle rettigheder
GRANT ALL ON SCHEMA public, data, opslag TO skov_administrator;

-- Alle rettigheder tildeles på *schema* niveau. Dette simplificeres administrationen voldsomt.
-- Administrator skal kun en gang tage stilling til sikkerhedsniveau for den enkelte tabel
-- og derefter placere denne i det relevante schema 

-- Læse rettigheder for read og datawriter gruppe på alle schemaer.
GRANT SELECT  ON ALL TABLES    IN SCHEMA public, data, opslag TO skov_reader, skov_datawriter;
GRANT SELECT  ON ALL SEQUENCES IN SCHEMA public, data, opslag TO skov_reader, skov_datawriter;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public, data, opslag TO skov_reader, skov_datawriter;


-- Alle rettigheder til gruppe administrator i alle schemaer
GRANT ALL ON ALL TABLES    IN SCHEMA public, data, opslag TO skov_administrator;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public, data, opslag TO skov_administrator; 
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public, data, opslag TO skov_administrator;

-- Alle rettigheder til gruppe datawriter i schema "data"
GRANT ALL ON ALL TABLES    IN SCHEMA data TO skov_datawriter;
GRANT ALL ON ALL SEQUENCES IN SCHEMA data TO skov_datawriter; 
GRANT ALL ON ALL FUNCTIONS IN SCHEMA data TO skov_datawriter;

-- Ovenstående kommandoer opsætter sikkerhed for *eksisterende* tabeller i de forskellige schemaer, men
-- hvad med *nye* tabeller, dvs. tabeller der oprettes *efter* de ovenstående grant kommandoer er udført ?
-- Svar: Ved brugen af: ALTER DEFAULT PRIVILEGES IN SCHEMA... kan der opsættes et standard sæt af 
-- rettigheder for tabeller o.a. som tilføjes schemaet.  

-- Læse rettigheder til nye objekter for read og write grupper
ALTER DEFAULT PRIVILEGES IN SCHEMA public, data, opslag GRANT SELECT  ON TABLES    TO skov_reader, skov_datawriter;
ALTER DEFAULT PRIVILEGES IN SCHEMA public, data, opslag GRANT SELECT  ON SEQUENCES TO skov_reader, skov_datawriter;
ALTER DEFAULT PRIVILEGES IN SCHEMA public, data, opslag GRANT EXECUTE ON FUNCTIONS TO skov_reader, skov_datawriter;

-- Alle rettigheder til nye objekter til gruppe adm
ALTER DEFAULT PRIVILEGES IN SCHEMA public, data, opslag GRANT ALL ON TABLES    TO skov_administrator;
ALTER DEFAULT PRIVILEGES IN SCHEMA public, data, opslag GRANT ALL ON SEQUENCES TO skov_administrator; 
ALTER DEFAULT PRIVILEGES IN SCHEMA public, data, opslag GRANT ALL ON FUNCTIONS TO skov_administrator;

-- Alle rettigheder til nye objekter til gruppe datawriter i schema "data"
ALTER DEFAULT PRIVILEGES IN SCHEMA data GRANT ALL ON TABLES    TO skov_datawriter;
ALTER DEFAULT PRIVILEGES IN SCHEMA data GRANT ALL ON SEQUENCES TO skov_datawriter; 
ALTER DEFAULT PRIVILEGES IN SCHEMA data GRANT ALL ON FUNCTIONS TO skov_datawriter;

--- SLUT på Ressource opsætning

--- Oprettelse af eksempel brugere. 
--- * Navne bør ændres til relevante brugernavne
--- * Husk at brugernavne administres på database *server* niveau, ikke database niveau, 

-- Opret 3 eksempel brugere; husk at bruge nøgleordet INHERIT i denne kommando; dette medfører at 
-- bruger automatisk får tildelt rettigheder fra ressourcegrupperne, som brugeren bliver medlem af

-- Bruger "bo" oprettes og tildeles administrator rettigheder til databasen 
-- (afkommentér næste 2 linjer)
CREATE ROLE skov_bo WITH LOGIN PASSWORD 'thomsen' VALID UNTIL '2024-01-01' INHERIT;
GRANT skov_administrator TO skov_bo;

-- Bruger "lene" oprettes og tildeles læse rettigheder til databasen
-- (afkommentér næste 2 linjer)
CREATE ROLE skov_lene WITH LOGIN PASSWORD 'fischer' VALID UNTIL '2024-01-01' INHERIT;
GRANT skov_reader TO skov_lene;

-- Bruger "klaus" oprettes og tildeles læse rettigheder til databasen og skrive rettigheder til schema "data" 
-- (afkommentér næste 2 linjer)
CREATE ROLE skov_klaus WITH LOGIN PASSWORD 'agerskov' VALID UNTIL '2024-01-01' INHERIT;
GRANT skov_datawriter TO skov_klaus;

