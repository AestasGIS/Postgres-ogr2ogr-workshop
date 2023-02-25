/*

   Dette script illustrerer muligheden for at administrere database til på *schema* niveau
   Dvs., man opretter schemaer, hvor tabeller placeres efter funktion/sikkerhedsniveau. 
   Brugere tildeles så adgangsrettigheder på basis af deres rolle i organisationen.
   
   Denne metoder gør administration af sikkerhed til de enkelte tabeller meget nemmere:
   En ny tabel placeres i det relevante schema, hvorved tabellen får en stadard sikkerheds
   niveau svarernde til schemaets. Så man slipper for rolle-administration på tabel niveau.

   (Man skal selvfølgelig tænke grundigt mht. den initielle opsætning af schemaer - YMMV) 

   Eksemplet arbejder med to specifikke schemaer i database "skov": 

   -- "data" som indeholder tabeller, der skal opdateres af en række brugere, f.eks. ved 
      grøn registrering i felten   

   -- "opslag" som indeholder opslags lister/tabeller som skal kunne læses af alle brugere, men 
      *kun* redigeres af administratorer.

   Til dette formål oprettes så 2 ressource roller uden login rettigheder men med forskellige
   rettigheder i schemaerne.       

   -- skov_reader : Kan læse data fra alle schemaer i databasen, men ikke opdatere data; 
      benyttes til analyse brugere 

   -- skov_writer : Kan læse data fra alle schemaer i databasen og skrive i schema "data";
      benyttes til "data indsamlere"
      
   -- skov_owner  : Har alle rettigheder inkl. mulighed oprettelse af nye schemaer og tabeller; 
      opdatering af opslagstabeller osv. Denne rolle skal have login rettigheder, således man kan 
      logge ind vha. Denne rolle benyttes ved oprettelse af de forskellige data- og opslagstabeller. 

   -- Slutteligt oprettes personlige brugerkonti (roller med login rettighed samt INHERIT) som tildeles
      medlemsskab til de forskellige ressource roller
   
   Copyright 2022: Bo Victor Thomsen, AestasGIS
   
*/

-- Dette script skal køres af en Postgres superuser, f.eks. user "postgres"

-- Scriptet kan selvfølgelig bruges til andre databaser; du skal blot ændre på de forskellige schema- og 
-- rolle-referencer. Husk at roller defineres i database *systemet* og ikke til den enkelte database

-- Opret refererede schemaer - Just in case...
CREATE SCHEMA IF NOT EXISTS data;
CREATE SCHEMA IF NOT EXISTS opslag;

-- Opret ressourcegrupper. 
-- Husk at disse roller administres på database *server* niveau, ikke database niveau, 
-- så de deles af alle databaser på server. Så pas på navne sammenfald. 
CREATE ROLE skov_reader NOINHERIT; -- kan læse data fra alle schemaer i databasen
CREATE ROLE skov_writer NOINHERIT; -- kan læse data fra alle schemaer i databasen og skrive i schema "data"

CREATE ROLE skov_owner WITH LOGIN PASSWORD 'skolen' VALID UNTIL '2024-01-01' INHERIT; -- får alle rettigheder inkl. oprettelse af nye schemaer

-- Fjern alle standard rettigheder fra schemaer, inkl. schema "public" from role "PUBLIC"
REVOKE ALL ON SCHEMA public, data, opslag FROM PUBLIC;
REVOKE ALL ON DATABASE skov FROM PUBLIC;  

-- Tildel rettigheder til de forskellige ressourcegrupper

-- Adgang til database
GRANT CONNECT, TEMP ON DATABASE skov TO skov_reader, skov_writer;
GRANT ALL ON DATABASE skov TO skov_owner;

-- Adgang til schemaer for read gruppe
GRANT USAGE ON SCHEMA public, data, opslag TO skov_reader, skov_writer;

-- Administrator får alle rettigheder
GRANT ALL ON SCHEMA public, data, opslag TO skov_owner;

-- Alle rettigheder tildeles på *schema* niveau. Dette simplificeres administrationen voldsomt.
-- Administrator skal kun en gang tage stilling til sikkerhedsniveau for den enkelte tabel
-- og derefter placere denne i det relevante schema 

/* 

-- Dette afsnit skal afkommnteres, hvis der allerede er indlagt tabeller i de to schemaer

-- Læse rettigheder for read og datawriter gruppe på alle schemaer.
GRANT SELECT  ON ALL TABLES    IN SCHEMA public, data, opslag TO skov_reader, skov_writer;
GRANT SELECT  ON ALL SEQUENCES IN SCHEMA public, data, opslag TO skov_reader, skov_writer;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public, data, opslag TO skov_reader, skov_writer;

-- Alle rettigheder til gruppe administrator i alle schemaer
GRANT ALL ON ALL TABLES    IN SCHEMA public, data, opslag TO skov_owner;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public, data, opslag TO skov_owner; 
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public, data, opslag TO skov_owner;

-- Alle rettigheder til gruppe datawriter i schema "data"
GRANT ALL ON ALL TABLES    IN SCHEMA data TO skov_writer;
GRANT ALL ON ALL SEQUENCES IN SCHEMA data TO skov_writer; 
GRANT ALL ON ALL FUNCTIONS IN SCHEMA data TO skov_writer;

*/

/*
-- Ovenstående kommandoer opsætter sikkerhed for *eksisterende* tabeller i de forskellige schemaer, men
   hvad med *nye* tabeller, dvs. tabeller der oprettes *efter* de ovenstående grant kommandoer er udført ?
   Svar: Ved brugen af: ALTER DEFAULT PRIVILEGES IN SCHEMA... kan der opsættes et standard sæt af 
   rettigheder for tabeller o.a. som tilføjes schemaet. 

   NB! Når der oprettes nye tabeller i hhv. schema data og opslag, *skal* man bruge rolle "skov_writer" 
   eller "postgres". Ellers vil de nedenstående defult privileges ikke blive sat op.
   
*/ 

-- Læse rettigheder til nye objekter for read og write grupper
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA public, data, opslag GRANT SELECT  ON TABLES    TO skov_reader, skov_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA public, data, opslag GRANT SELECT  ON SEQUENCES TO skov_reader, skov_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA public, data, opslag GRANT EXECUTE ON FUNCTIONS TO skov_reader, skov_writer;
-- Læg mærke til ...FOR ROLE... delen af sætningen, som definerer hvilke brugere der kan bruges til oprettelse naf tabeller osv.

-- Alle rettigheder til nye objekter til gruppe adm
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA public, data, opslag GRANT ALL ON TABLES    TO skov_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA public, data, opslag GRANT ALL ON SEQUENCES TO skov_owner; 
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA public, data, opslag GRANT ALL ON FUNCTIONS TO skov_owner;

-- Alle rettigheder til nye objekter til gruppe datawriter i schema "data"
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA data GRANT ALL ON TABLES    TO skov_writer;
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA data GRANT ALL ON SEQUENCES TO skov_writer; 
ALTER DEFAULT PRIVILEGES FOR ROLE skov_owner, postgres IN SCHEMA data GRANT ALL ON FUNCTIONS TO skov_writer;

--- SLUT på Ressource opsætning

--- Oprettelse af eksempel brugere. 
--- * Navne bør ændres til relevante brugernavne
--- * Husk at brugernavne administres på database *server* niveau, ikke database niveau, 

-- Opret 3 eksempel brugere; husk at bruge nøgleordet INHERIT i denne kommando; dette medfører at 
-- bruger automatisk får tildelt rettigheder fra ressourcegrupperne, som brugeren bliver medlem af

-- Bruger "lene" oprettes og tildeles læse rettigheder til databasen
-- (afkommentér næste 2 linjer)
CREATE ROLE lene WITH LOGIN PASSWORD 'fischer' VALID UNTIL '2024-01-01' INHERIT;
GRANT skov_reader TO lene;

-- Bruger "klaus" oprettes og tildeles læse rettigheder til databasen og skrive rettigheder til schema "data" 
-- (afkommentér næste 2 linjer)
CREATE ROLE klaus WITH LOGIN PASSWORD 'agerskov' VALID UNTIL '2024-01-01' INHERIT;
GRANT skov_writer TO klaus;

