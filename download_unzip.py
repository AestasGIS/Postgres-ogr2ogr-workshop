from ftplib import FTP
import re
import zipfile
import os

# Funktion til scanning af filnavne fra ftp LIST kommando
def callback(line):
    found = re.match(pattern, line)
    if (found): 
        if found.groups()[1].startswith(prefix): dnames.append(found.groups()[1])

# Diverse oplysninger, skal tilpasses for hver opsætning
server = os.environ["server"]    # FTP server for Datafordeler
userid = os.environ["userid"]    # Username for Datafordeler
passwd = os.environ["passwd"]    # Passwd do.
ftpdir = os.environ["ftpdir"]    # Relativ mappe på ftp server
zipdir = os.environ["zipdir"]    # Mappe på windows server til placering af zip filer fra download
gisdir = os.environ["gisdir"]    # Mappe på windows server til placering af udpakkede filer fra zip filer
prefix = os.environ["prefix"]    # Mappe på windows server til placering af udpakkede filer fra zip filer

print ("server = " + server)
print ("userid = " + userid)
print ("passwd = " + passwd)
print ("ftpdir = " + ftpdir)
print ("zipdir = " + zipdir)
print ("gisdir = " + gisdir)

pattern = r'.* ([A-Z|a-z].. .. .....) (.*)'

# Forbindelse til ftp 
ftp = FTP(server, userid, passwd)

if ftp:
    # Find mappe navn på ftp server med data
    dnames = []        
    ftp.retrlines('LIST',callback)
    
    
    ldir = '{}{}'.format(dnames[0],ftpdir)
    print ("ldir   = " + ldir)
    # Skift nuv. mappe på ftp server til relevant undermappe 
    ftp.cwd(ldir)
    
    #Find alle navne på zip filer
    dnames = []  
    prefix = ''    
    ftp.retrlines('LIST',callback)
    
    # For hver zip fil på ftp server
    for fname in dnames: 
    
        # Hent fil ned til windows server og læg den i temp mappe til zipfiler
        print ('Download: ' + fname)
        ftp.retrbinary("RETR " + fname, open(zipdir + fname, 'wb').write)
    
        # Udpak zip-fil til temp mappe til datafiler på windows server
        print ('Unzip: ' + fname)
        with zipfile.ZipFile(zipdir + fname, 'r') as zip_ref: zip_ref.extractall(gisdir)
    
    # Afslut
    ftp.quit()
    ftp.close()
    del ftp
else:
    print ("FTP server ikke fundet")
