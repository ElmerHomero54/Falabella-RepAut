@echo off
rem ---
set EXE=C:\Falabella\AutRep\exe
PATH=C:\cygwin64\bin;%PATH%
rem --
rem -- Calcula odate restando uno a la fecha del sistema
for /f "delims=" %%a in (' powershell "(Get-Date).AddDays(-1).tostring(\"yyyyMMdd\")" ') do set "odate=%%a"
echo %odate%
rem ---
rem -- Genera cada grafica indicada
%EXE%\creaGrafica.bat "persat" %odate%
%EXE%\creaGrafica.bat "perfcc" %odate%
%EXE%\creaGrafica.bat "argsat" %odate%
%EXE%\creaGrafica.bat "argfcc" %odate%
%EXE%\creaGrafica.bat "chisat" %odate%
%EXE%\creaGrafica.bat "chifcc" %odate%
%EXE%\creaGrafica.bat "colsat" %odate%
%EXE%\creaGrafica.bat "colfcc" %odate%
rem
