@echo off
REM Prise en compte des chgt de variables en execution
setlocal enabledelayedexpansion

REM Chemin vers exiftool
set EXIFTOOL_PATH="C:\Program Files\exiftool\exiftool.exe"

REM Commande exiftool 
set EXIFTOOL_CMD=-d %%Y-%%m-%%d_%%H-%%M-%%S_%%%%f.%%%%e "-testname<FileModifyDate" "-testname<MediaModifyDate" "-testname<MediaCreateDate" "-testname<TrackCreateDate" "-testname<ModifyDate" "-testname<DateTimeOriginal"

REM Date/heure actuelle
for /f %%A in ('wmic os get localdatetime ^| find "."') do set DTS=%%A
set "DTS=%DTS:~0,8%_%DTS:~8,6%"

REM Nom du fichier de sortie
set "OUTPUT_FILE=renomasse_%DTS%.txt"

REM Fichiers traités en prévisualisation
set COUNT=1
set FILELIST=

REM Commande pour previsualiser le renommage et stocker le résultat dans un fichier
echo Previsualisation du renommage des fichiers :
echo:
(for %%F in (*) do (
	REM Exclure le fichier .bat et output.txt
    if /i not "%%~nxF"=="%~nx0" if /i not "%%~xF"==".txt" (
		REM Constitution d'une liste de fichiers
		set "FILELIST=!FILELIST! "%%F""
		if !COUNT! geq 5 goto :end_filelist
		set /a COUNT+=1
	)
))

:end_filelist

REM Execution d'exiftool en mode silencieux
%EXIFTOOL_PATH% -q %EXIFTOOL_CMD% !FILELIST!

echo:

REM Demander confirmation à l'utilisateur
set /p confirmation=Voulez-vous renommer les fichiers (o/n)?

REM Si l'utilisateur confirme, exécuter le renommage effectif
if /i "%confirmation%"=="o" (
    echo Renommage des fichiers...
	echo:
	
	REM Remplacement testname par filename puis execution
    set EXIFTOOL_CMD=%EXIFTOOL_CMD:-testname=-filename%
	%EXIFTOOL_PATH% -v1 !EXIFTOOL_CMD! . >%OUTPUT_FILE%
	
	type %OUTPUT_FILE%
) else (
    echo Renommage annule.
)

pause
endlocal