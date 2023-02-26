@echo on

REM sæt parametre
set typdef="PostgreSQL"
set dbdef=PG:"host=localhost port=5433 user=postgres password=ukulemy dbname=geodata" 
set "schdef=logging"
set "dirdef=D:\PostgreSQL\15\data\log\" 
REM VIGTIGT, hvis du indlaeser data i PostgreSQL !!! Encoding for data, der skal indlaeses i PostgreSQL..
SET PGCLIENTENCODING=WIN-1252

set OSGEO4W_ROOT=c:\OSGeo4W
set path=%OSGEO4W_ROOT%\bin;%OSGEO4W_ROOT%\apps\proj-dev\bin;%OSGEO4W_ROOT%\apps\gdal-dev\bin;%WINDIR%\system32;%WINDIR%;%WINDIR%\system32\WBem
SET PROJ_LIB=%OSGEO4W_ROOT%\share\proj

ogrinfo -q -sql "CREATE SCHEMA IF NOT EXISTS %schdef%" %dbdef%

SETLOCAL ENABLEDELAYEDEXPANSION

for /R "%dirdef%" %%f in (*.csv) do (

    set t1=%%f
    set t2=!t1:%dirdef%=!
    set tabname=!t2:.csv=! 
    
    ogr2ogr --config PG_USE_COPY yes -lco OVERWRITE=YES -lco SCHEMA=%schdef% -oo AUTODETECT_TYPE=YES  -f %typdef% %dbdef% "%%f"

    REM Goer et eller andet med ogrinfo, tabname og schema 
    )
pause
