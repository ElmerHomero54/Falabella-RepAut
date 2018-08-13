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
copy ftp.txt ftp_%1.txt
sed -i s/<pais>/%1 ftp_%1.txt
ftp -s:ftp_%1.txt
rem ---
rem --- Pasa a archivo y genera grafica
C:\cygwin64\bin\bash traeLST.sh %1
C:\cygwin64\bin\bash cargaDiario.sh  %1 %2
C:\cygwin64\bin\bash creaDatosGrafica.sh %1 %2
copy %FMT%\Fmt_%1_diario.xlsx %OUT%\%1.xlsx
start excel %OUT%\%1.xlsx
