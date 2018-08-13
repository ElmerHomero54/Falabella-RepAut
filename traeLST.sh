# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
REP="/cygdrive/c/Falabella/AutRep/rep"
FTP="/cygdrive/c/Falabella/AutRep/dat/ftp"
# --
pais=$1
# --
# -- Pasa a la carpeta por pais
# -- Revisa que haya archivos para pasar
ls -1 $FTP/$pais/*.lst 2>/dev/null
if [ $? -ne 0 ]; then
   exit 0
fi
# -- Hay archivos para procesar
for a in $(ls -1 $FTP/$pais/*.lst); do
   t1=$(echo $a | awk -F'/' '{print $NF}' | cut -d'.' -f 1)
   echo "Revisa: "$t1
   t2=$t1"-*.lst"
   fn=$(ls -1 $REP/$pais/$t2 2>/dev/null | wc -l | awk '{printf("%02d",$0+1)}')
   t3=$t1"-"$fn".lst"
   mv $a $REP/$pais/$t3
done
