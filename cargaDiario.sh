# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
REP="/cygdrive/c/Falabella/AutRep/rep"
LOG="/cygdrive/c/Falabella/AutRep/log"
# --
#pais=$1
pais=$(echo $1 | awk '{print substr($0,1,3)}')
odate=$2
# --
arcLOG=$LOG/log_$odate.txt
# --
ruta=$REP/$pais
nomLST="datosDiarios_$pais.txt"
touch $DAT/$nomLST
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : cargaDiario.sh. Inicio" | sed 's/$'"/`echo \\\r`/" >> $arcLOG
# --
# -- Hace lista con las versiones mas recientes de LST por dia
lista=$(ls -1 $ruta/*_$odate*.lst 2>/dev/null |
          awk -F'-' '{
             if(NR==1) { cveAnt=$1; nomAnt=$0 }
             else { if(cveAnt!=$1) { print nomAnt }
                    nomAnt=$0; cveAnt=$1 } }
          END{print nomAnt}')
# --
echo "Carga de archivos LST"
# --
# -- Carga en archivo de datos diarios
for a in $(echo $lista); do
   echo $(date '+%d-%m-%Y %H:%M:%S,00')" : cargaDiario.sh.    Carga "$a | sed 's/$'"/`echo \\\r`/" >> $arcLOG
   echo "Archivo: "$a
   # -- Genera archivo de jobs del dia ODATE
   cat $a |
      awk '/EJECUCIONES DE JOBS DE CONTROL-M/ {isPrint=1} {if(isPrint) print}' |
      awk '/=============/ {exit} {print}' |
      grep "^   " | grep -v 'Nro. Run' | grep -v '   -----' |
      awk -v l="22,22,22,11,10,11,10,12,13,8" -v pais=$pais -v ODATE=$odate '@include "func.txt" 
	  BEGIN{s="@"}
      { $0=trim($0)
        if(readFields())
           print field[1] s ODATE s toISODate(field[4]) s toUSTime(field[5]) s toISODate(field[6]) s toUSTime(field[7]) s substr(field[8],1,1) s toUSTime(field[9]) s field[10] }' >> $DAT/$nomLST
done
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : cargaDiario.sh.    Elimina datos repetidos y jobs sin finalizar" | sed 's/$'"/`echo \\\r`/" >> $arcLOG
mv $DAT/$nomLST $DAT/tmp1.txt
cat $DAT/tmp1.txt |
   sort -u |
   awk -F'@' 'BEGIN{s=FS} {if($7=="F") print $1 s $2 s $3 s $4 s $5 s $6 s $7 s $8+0 s $9}' |
   sort -t'@' -nk 2,2 > $DAT/$nomLST
# --
rm -f $DAT/tmp1.txt
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : cargaDiario.sh. Fin" | sed 's/$'"/`echo \\\r`/" >> $arcLOG