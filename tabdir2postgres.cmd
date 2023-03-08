@echo on
REM set pointer to QGIS paa dir
set "qgishome=C:\Program Files\QGIS 3.28.1"
REM call setup funktion for path and other environment var
call "%qgishome%\bin\o4w_env.bat"
@echo on

REM sæt parametre til database
set typdef="PostgreSQL"
set dbdef=PG:"host=localhost port=5433 user=**** password=**** dbname=geodata" 
set "schdef=fot"

REM VIGTIGT, hvis du indlaeser data i PostgreSQL !!! Encoding for data, der skal indlaeses i PostgreSQL..
SET PGCLIENTENCODING=UTF-8

REM for python program
set "server=ftp3.datafordeler.dk"  
set "userid=****"            
set "passwd=****"          
set "ftpdir=/Kommune/Kommune_0151" 
set "zipdir=d:/temp/dfzip/"        
set "gisdir=d:/temp/dfgis/"        
set "prefix=GeoDanmark60_TAB"        

REM Download and unzip data files
python "%~dp0download_unzip.py"

ogrinfo -q -sql "CREATE SCHEMA IF NOT EXISTS %schdef%" %dbdef%

REM SETLOCAL ENABLEDELAYEDEXPANSION

REM load all tab files into database
for /R "%gisdir%" %%f in (*.tab) do (
    ogr2ogr --config PG_USE_COPY yes -lco OVERWRITE=YES -lco SCHEMA=%schdef% -f %typdef% %dbdef% "%%f"
)
pause

