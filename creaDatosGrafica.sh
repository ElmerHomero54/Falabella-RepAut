# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
LOG="/cygdrive/c/Falabella/AutRep/log"
MAN=$DAT/man
# --
#. lee_lista_dias.sh
. generaDatosCalendarios.sh
# --
pais=$(echo $1 | awk '{print substr($0,1,3)}')
aplic=$1
ODATE=$2
calend=$(cat $EXE/grupos.txt | grep '^'$aplic'#P#' | cut -d'@' -f 2)
nDias=$(cat $EXE/grupos.txt | grep '^'$aplic'#P#' | cut -d'@' -f 3)
# --
nomLST="datosDiarios_"$pais".txt"
nomDuracion="datGrafic.txt"
arcLOG=$LOG/log_$odate.txt
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh. Inicio" | xargs printf "%s\r\n" >> $arcLOG
# --
rm -f $DAT/$nomDuracion
rm -f $DAT/t1
rm -f $DAT/t2
rm -f $DAT/tma4
rm -f $DAT/tma5
# --
# -- Determina las fechas que se graficaran
# --    Guarda en variable >>lst<<< la lista de dias que se graficaran
# --    Determina la lista de dias de acuerdo al tipo de calendario (habil o todos)
lee_dias $calend $ODATE $nDias $pais
# --    Graba la lista de dias como primer renglon. En formato Excel
echo $lst |
   awk -F'@' '@include "func.txt"
   { for(i=1;i<=NF;i++) printf("@%s",toEURDate($i)); printf("\n") }' |
   awk '{ print substr($0,2) }' > $DAT/tma4
# -- Graba los nombres de los dias
echo $dows >> $DAT/tma4
# --
fi=$(echo $lst | cut -d'@' -f 1)
ff=$ODATE
# --
echo "Para "$aplic" se crearan datos desde "$fi" hasta "$ff
# --
# -- Busca la hora final de la malla
# -- Lee las horas finales de los jobs de fin de malla
for a in $(cat $EXE/grupos.txt | grep '^'$aplic'#F#' | cut -d'@' -f 2 | awk -F',' '{for(i=1;i<=NF;i++) print $i}'); do
   grep $a $DAT/$nomLST | awk -F'@' -v lst=$lst '{if(index(lst,$2)>0) print $2 FS $5 FS $6}' >> $DAT/t0
done
cat $DAT/t0 | awk -F'@' '{if($2!="" && $3!="") print}' | sort -rut'@' -k 1,1 | sort -t'@' |
   # -- Crea registro para generar grafica
   awk -F'@' -v lst=$lst '@include "func.txt"
   BEGIN{s=" "; q=split(lst,tmp,"@"); for(i in tmp) r[tmp[i]]=0 }
   { if(index(lst,$1)>0) r[$1]=USTime2ExcelTime($3) }
   END{for(i in r) printf("0#%s@",r[i]); printf("\n")}' >> $DAT/tma5
# --
# -- Genera los datos de duracion por rango de fechas tomados del reporte LST
for dat in $(cat $EXE/grupos.txt | grep '^'$aplic'#G#'); do
   gpo=$(echo $dat | cut -d'@' -f 1 | cut -d'#' -f 3)
   echo "Se leen datos para el renglon de grafica: "$gpo
   echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh.    Se leen datos para renglon "$gpo | xargs printf "%s\r\n" >> $arcLOG
   # -- Busca los jobs de inicio y fin para el grupo
   # --    Lee horas iniciales
   ini=$(echo $dat | cut -d'@' -f 3)
   grep $ini $DAT/$nomLST |
     awk -F'@' -v lst=$lst '{if(index(lst,$2)>0) print $2 FS $3 FS $4}' |
     sort -unt'@' -k 1,1 > $DAT/t1
   # --    Lee horas finales. Puede haber mas de un job de finalizacion; se tomara el que haya tardado mas
   fin=$(echo $dat | cut -d'@' -f 4 | sed 's/,/|/g')
   grep -E "$(echo $fin)" $DAT/$nomLST |
      awk -F'@' -v lst=$lst '{if(index(lst,$2)>0) print}' |
      sort -t'@' -nk 2,2 |
      awk -F'@' 'BEGIN{s="@";hf=0}
      { if(NR==1) {fo=$2;ff=$5;hf=$6}
        if(fo!=$2) {
           print fo s ff s hf
           fo=$2;ff=$5;hf=$6 }
        else {
           if($5!="") ff=$5
           if(hf<$6) hf=$6 } }
        END{print fo s ff s hf}' > $DAT/t2
   # --    Calcula tiempos y graba en archivo
   paste -d'@' $DAT/t1 $DAT/t2 |
      awk -F'@' -v lst=$lst -v gpo=$gpo '@include "func.txt"
      BEGIN{s=FS; q=split(lst,tmp,"@"); for(i in tmp) r[tmp[i]]=0 }
      { if(NF==6) { inic[$1]=$3; finis[$4]=$6 } }
      END{printf("%s#@",gpo)
          for(i in r) {
            r[i]=USTime2ExcelTime(finis[i])-USTime2ExcelTime(inic[i])
            if(r[i]<0)r[i]=r[i]+1
            printf("%s@",r[i]) }
          printf("\n") }' >> $DAT/tma5
done
# --
# -- Genera los datos de duracion por rango de fechas tomados de datos manuales
for dat in $(cat $EXE/grupos.txt | grep '^'$aplic'#M#'); do
   gpo=$(echo $dat | cut -d'@' -f 1 | cut -d'#' -f 3)
   arc=$(echo $dat | cut -d'@' -f 3)
   tail -$nDias $MAN/$arc |
      sed 's/\r$//' |  # -- dos2unix (Es archivo WIndows y se pasa a Linux)
      awk -F';' '{ printf("@%s",$2) }' |
      awk -v gpo=$gpo '{print gpo"#"substr($0,2)}' >> $DAT/tma5
done
# -- Crea los encabezados del archivo para grafica
cat $DAT/tma4 | awk '{printf("%s\r\n",$0)}' > $DAT/$nomDuracion
# -- Ordena los datos por grupo de aplicacion
# -- Si existe mas de un renglon por grupo de aplicacion, los suma
sort -t'#' -nk 1 $DAT/tma5 |
   awk -F'@' '{
      if(substr($1,1,1)=="#") {
         gpo=substr($1,2)
         if(gpo!=ga) {
            if(ga!="") { for(i=2;i<=NF;i++) printf("%8.8f%s",sum[i],FS); printf("\n") }
            for(i=2;i<=NF;i++) sum[i]=$i }
         else
            for(i=2;i<=NF;i++) sum[i]=sum[i]+$i }
      else
         print
      ga=gpo }
   END{ for(i=2;i<=NF;i++) printf("%8.8f%s",sum[i],FS); printf("\n") }' |
   awk '{printf("%s\r\n",$0)}' >> $DAT/$nomDuracion
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh.    Borra archivos temporales de trabajo" | xargs printf "%s\r\n" >> $arcLOG
rm -f $DAT/t1
rm -f $DAT/t2
rm -f $DAT/tma4
rm -f $DAT/tma5
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh. Fin" | xargs printf "%s\r\n" >> $arcLOG
