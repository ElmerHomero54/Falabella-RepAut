rem ---
echo off
rem ---
set EXE=C:\Falabella\AutRep\exe
set DAT=C:\Falabella\AutRep\dat
set FMT=%DAT%\fmt
set OUT=%DAT%\out
rem ---
cd %EXE%
rem ---
rem --- Parametros: <pais> <odate>
rem ---
rem --- FTP de datos de Control-M
echo Prepara FTP para reportes LST
copy %EXE%\ftp.txt %EXE%\ftp_%1.txt
sed -i "s/<pais>/%1/g" %EXE%\ftp_%1.txt
echo Busca reportes LST en el servidor de Control-M
rem        ftp -s:ftp_%1.txt
rem ---
rem --- Pasa a archivo y genera grafica
echo Carga en archivos diarios
C:\cygwin64\bin\bash traeLST.sh %1
C:\cygwin64\bin\bash cargaDiario.sh  %1 %2
C:\cygwin64\bin\bash creaDatosGrafica.sh %1 %2
echo Genera grafica en Excel
copy %EXE%\Fmt_%1_diario.xlsm %OUT%\%1.xlsm
start excel %OUT%\%1.xlsm
