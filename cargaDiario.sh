# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
REP="/cygdrive/c/Falabella/AutRep/rep"
nomLST="datosDiarios.txt"
# --
pais=$1
odate=$2
# --
ruta=$REP/$pais
# --
# -- Hace lista con las versiones mas recientes de LST por dia
lista=$(ls -1 $ruta/*_$odate*.lst |
          awk -F'-' '{
             if(NR==1) { cveAnt=$1; nomAnt=$0 }
             else { if(cveAnt!=$1) { print nomAnt }
                    nomAnt=$0; cveAnt=$1 } }
          END{print nomAnt}')
# --
# -- Carga en archivo de datos diarios
for a in $(echo $lista); do
   # -- Genera archivo de jobs del dia ODATE
   cat $a |
      awk '/EJECUCIONES DE JOBS DE CONTROL-M/ {isPrint=1} {if(isPrint) print}' |
      awk '/=============/ {exit} {print}' |
      grep "^   " | grep -v 'Nro. Run' | grep -v '   -----' |
      awk -v l="22,22,22,11,10,11,10,12,13,8" -v pais=$pais -v ODATE=$odate '@include "func.txt" BEGIN{s="@"}
      { $0=trim($0)
        if(readFields())
           print pais s field[1] s ODATE s toUSDate(field[4]) s toUSTime(field[5]) s toUSDate(field[6]) s toUSTime(field[7]) s substr(field[8],1,1) s toUSTime(field[9]) s field[10] }' >> $DAT/$nomLST
done
