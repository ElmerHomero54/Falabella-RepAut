@echo off
rem ---
set EXE=C:\Falabella\AutRep\exe
PATH=C:\cygwin64\bin;%PATH%
rem --
rem -- Calcula odate restando uno a la fecha del sistema
for /f "delims=" %%a in (' powershell "(Get-Date).AddDays(-1).tostring(\"yyyyMMdd\")" ') do set "odate=%%a"
echo Se procesa con fecha de %odate%
rem ---
rem -- Genera cada grafica indicada
%EXE%\creaGrafica.bat arg %odate%
rem ---%EXE%\creaGrafica.bat "persat" %odate%
rem ---%EXE%\creaGrafica.bat "perfcc" %odate%
rem ---%EXE%\creaGrafica.bat "argsat" %odate%
rem ---%EXE%\creaGrafica.bat "argfcc" %odate%
rem ---%EXE%\creaGrafica.bat "chisat" %odate%
rem ---%EXE%\creaGrafica.bat "chifcc" %odate%
rem ---%EXE%\creaGrafica.bat "colsat" %odate%
rem ---%EXE%\creaGrafica.bat "colfcc" %odate%
rem
