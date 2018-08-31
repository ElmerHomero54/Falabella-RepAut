rem ---
call setVar.bat
PATH=C:\cygwin64\bin;%PATH%
rem --
echo %date% %time% : crea.bat. Inicio. Se procesa con fecha de %odate% >> %arcLOG%
rem ---
rem -- Genera cada grafica indicada
cd %EXE%
call creaGrafica.bat arg %odate%
rem ---call creaGrafica.bat "persat" %odate%
rem ---call creaGrafica.bat "perfcc" %odate%
rem ---call creaGrafica.bat "argsat" %odate%
rem ---call creaGrafica.bat "argfcc" %odate%
rem ---call creaGrafica.bat "chisat" %odate%
rem ---call creaGrafica.bat "chifcc" %odate%
rem ---call creaGrafica.bat "colsat" %odate%
rem ---call creaGrafica.bat "colfcc" %odate%
rem
echo %date% %time% : crea.bat. Fin de proceso >> %arcLOG%
