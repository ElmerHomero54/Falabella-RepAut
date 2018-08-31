echo off
rem -- Definicion de Variables de Entorno
rem ---
set EXE=C:\Falabella\AutRep\exe
set DAT=C:\Falabella\AutRep\dat
set LOG=C:\Falabella\AutRep\log
set FMT=%DAT%\fmt
set OUT=%DAT%\out
rem --
rem -- Calcula odate restando uno a la fecha del sistema
for /f "delims=" %%a in (' powershell "(Get-Date).AddDays(-1).tostring(\"yyyyMMdd\")" ') do set "odate=%%a"
rem --
set arcLOG=%LOG%\log_%odate%".txt"
