rem ---
echo off
rem ---
call setVar.bat
set tmp=%DAT%\tmpFTP.txt
set tmp2=%DAT%\tmpFTP2.txt
rem ---
echo %date% %time% : traeLST.bat. Inicio >> %arcLOG%
rem --
cd %EXE%
echo Prepara FTP para reportes LST
copy %EXE%\ftp.txt %EXE%\ftp_%1.txt >NUL
sed -i "s/<pais>/%1/g" %EXE%\ftp_%1.txt
echo Busca reportes LST en el servidor de Control-M
ftp -s:%EXE%\ftp_%1.txt >%tmp% 2>%tmp2%
rem -- Busca resultado del FTP
findstr "^150" %tmp% >NUL
If %ERRORLEVEL% NEQ 0 (
    echo %date% %time% : traeLST.bat. ERROR >> %arcLOG%
	type %tmp% >> %arcLOG%
)
echo %date% %time% : traeLST.bat. Fin >> %arcLOG%
