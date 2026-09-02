@echo off
setlocal EnableExtensions EnableDelayedExpansion
rem Compile une lecon du recueil toute seule (deux passes de pdflatex) et range le PDF :
rem   lecon.bat 101                  -> Lecons\AG\101.pdf   (algebre : lecons 1xx, lues dans 100\)
rem   lecon.bat 201                  -> Lecons\AP\201.pdf   (analyse-probas : lecons 2xx, lues dans 200\)
rem   lecon.bat DevAlg/baseburnside  -> DevAlg\baseburnside.pdf   (chemin explicite, avec des /)
rem   lecon.bat all                  -> toutes les lecons de 100\ et 200\
rem   Double-clic sur lecon.bat (= sans argument) : equivaut a "all", et la fenetre reste ouverte a la fin.
rem Le script se place de lui-meme a la racine du recueil (son propre dossier).

cd /d "%~dp0"
where pdflatex >nul 2>&1
if errorlevel 1 (
	echo pdflatex introuvable : installe MiKTeX ou TeX Live, ou ajoute-le au PATH. 1>&2
	if "%~1"=="" pause
	exit /b 1
)

set "arg=%~1"
set "attendre="
if "%arg%"=="" (set "arg=all" & set "attendre=1")

if /i "%arg%"=="all" (call :toutes) else (call :compile_une "%arg%")
set "code=%errorlevel%"
if defined attendre (echo. & pause)
exit /b %code%


:compile_une
rem %~1 = numero de lecon, ou chemin/du/fichier sans .tex
set "cible=%~1"
set "cible=%cible:\=/%"
if "%cible%"=="%cible:/=%" (
	set "job=%cible%"
	set "def=\def\numlecon{%cible%}"
	if %cible% LSS 200 (set "dossier=Lecons/AG") else (set "dossier=Lecons/AP")
) else (
	for %%p in ("%cible%") do (set "job=%%~np" & set "dossier=%%~dpp")
	set "dossier=!dossier:~0,-1!"
	set "def=\def\fichier{%cible%}"
)
set "dosdir=%dossier:/=\%"
if not exist "%dosdir%" mkdir "%dosdir%"
for %%i in (1 2) do (
	pdflatex -interaction=nonstopmode -halt-on-error -output-directory="%dossier%" -jobname="%job%" "%def%\input{lecon}" >nul
	if errorlevel 1 (
		echo Erreur de compilation ^(%cible%^) : voir %dosdir%\%job%.log 1>&2
		exit /b 1
	)
)
del /q "%dosdir%\%job%.aux" "%dosdir%\%job%.log" "%dosdir%\%job%.out" 2>nul
echo -^> %dosdir%\%job%.pdf
exit /b 0


:toutes
rem toutes les lecons de 100\ et 200\ (fichiers <numero>.tex), echecs listes a la fin
set "echecs="
for %%f in (100\*.tex 200\*.tex) do (
	set "num=%%~nf"
	set "nonnum="
	for /f "delims=0123456789" %%x in ("!num!") do set "nonnum=1"
	if defined nonnum (
		echo ignore : %%f ^(le nom n'est pas un numero de lecon^) 1>&2
	) else (
		call :compile_une "!num!"
		if errorlevel 1 set "echecs=!echecs! !num!"
	)
)
if defined echecs (
	echo Lecons en echec :%echecs% 1>&2
	exit /b 1
)
exit /b 0
