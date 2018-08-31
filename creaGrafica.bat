echo off
rem ---
call setVar.bat
rem --
echo "--------------------------------------------------------------------" >> %arcLOG%
echo %date% %time% : creaGrafica.bat. Inicio con %1 y %2 >> %arcLOG%
rem ---
cd %EXE%
rem ---
rem --- Parametros: <pais> <odate>
rem ---
rem --- Corre FTP de datos de Control-M
call traeLST.bat %1 %2
rem --- Pasa a archivo y genera grafica
echo Pasa a rutas de respaldo los LST leidos
C:\cygwin64\bin\bash pasaLST.sh %1
echo Carga en archivos diarios
C:\cygwin64\bin\bash cargaDiario.sh %1 %2
echo Crea los datos para generar la grafica
C:\cygwin64\bin\bash creaDatosGrafica.sh %1 %2
echo Genera grafica en Excel
copy %EXE%\Fmt_%1_diario.xlsm %OUT%\%1.xlsm >NUL
start excel %OUT%\%1.xlsm
echo %date% %time% : creaGrafica.bat. Fin >> %arcLOG%
