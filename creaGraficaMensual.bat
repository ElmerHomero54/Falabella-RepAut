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
rem --- Pasa a archivo y genera grafica
C:\cygwin64\bin\bash creaDatosGraficaMensual.sh %1 %2
del %OUT%\%1.xlsm
copy %FMT%\Fmt_%1_mensual.xlsm %OUT%\%1.xlsm
start excel %OUT%\%1.xlsm
