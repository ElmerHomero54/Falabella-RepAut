# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
LOG="/cygdrive/c/Falabella/AutRep/log"
# --
pais=$1
ODATE=$2
nDias=22
# --
nomLST="datosDiarios_"$pais".txt"
nomDuracion="datGrafic.txt"
arcLOG=$LOG/log_$odate.txt
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh. Inicio" | sed 's/$'"/`echo \\\r`/" >> $arcLOG
# --
rm -f $DAT/$nomDuracion
rm -f $DAT/t1
rm -f $DAT/t2
# --
# -- Determina fechas inicial y final del rango de datos
# -- Siempre el ODATE sera la final. La inicial son n dias antes
fi=$(awk -v odate=$ODATE -v nDias=$nDias 'BEGIN{s= " "; print strftime("%Y%m%d", toTimeUnix(odate,"130001") - day2sec(nDias-1))} @include "func.txt"')
echo $fi | awk '@include "func.txt"
  {print toUSDate($0)}' > $DAT/$nomDuracion
# --
ff=$ODATE
# --
echo "Para "$pais" se crearan datos desde "$fi" hasta "$ff
# --
rm -f $DAT/t0
# -- Busca la hora final de la malla
# -- Lee las horas finales de los jobs de fin de malla
for a in $(cat $DAT/grupos.txt | grep '^'$pais'#F#' | cut -d'@' -f 2 | awk -F',' '{for(i=1;i<=NF;i++) print $i}'); do
   grep $a $DAT/$nomLST | awk -F'@' -v fi=$fi -v ff=$ff '{if($2>=fi && $2<=ff) print $2 FS $5 FS $6}' >> $DAT/t0
done
# --
# -- Busca la hora mas alta por fecha
cat $DAT/t0 | awk -F'@' '{if($2!="" && $3!="") print}' | sort -rut'@' -k 1,1 | sort -t'@' |
   # -- Crea registro para generar grafica
   awk -F'@' -v fi=$fi -v ff=$ff -v nDias=$nDias '@include "func.txt"
   BEGIN{s=" "; r[fi]=0; r[ff]=0; t0=fi; for(i=2;i<=nDias;i++) { t=strftime("%Y%m%d", toTimeUnix(t0,"000001") + day2sec(1)); r[t]=0; t0=t } }
   { r[$1]=USTime2ExcelTime($3) }
   END{for(i in r) printf("%s@",r[i]); printf("\n")}' >> $DAT/$nomDuracion
# --
# -- Genera los datos de duracion por rango de fechas
for dat in $(cat $DAT/grupos.txt | grep '^'$pais'#G#'); do
   gpo=$(echo $dat | cut -d'@' -f 1 | cut -d'#' -f 3)
   echo "Se leen datos para el renglon de grafica: "$gpo
   echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh. Se leen datos para renglon "$gpo | sed 's/$'"/`echo \\\r`/" >> $arcLOG
   # -- Busca los jobs de inicio y fin para el grupo
   ini=$(echo $dat | cut -d'@' -f 3)
   # -- Busca los tiempos de proceso de los jobs de inicio y fin
   grep $ini $DAT/$nomLST |
     awk -F'@' -v fi=$fi -v ff=$ff '{if($2>=fi && $2<=ff) print $2 FS $3 FS $4}' |
     sort -unt'@' -k 1,1 > $DAT/t1
   n1=$(wc -l $DAT/t1 | cut -d' ' -f 1)
   # -- Puede haber mas de un job de finalizacion; se tomara el que haya tardado mas
   fin=$(echo $dat | cut -d'@' -f 4 | sed 's/,/|/g')
   grep -E "$(echo $fin)" $DAT/$nomLST |
      awk -F'@' -v fi=$fi -v ff=$ff '{if($2>=fi && $2<=ff) print}' |    # --->  && $7=="F"
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
   n2=$(wc -l $DAT/t2 | cut -d' ' -f 1)
   # --
   # -- Si hallo los tiempos, calcula la duracion
   if [ $n1 -ne 0 ] && [ $n2 -ne 0 ] && [ $n1 -eq $n2 ]; then
      # -- Calcula la diferencia de tiempo entre inicio y fin
      paste -d'@' $DAT/t1 $DAT/t2 |
         awk -F'@' -v odate=$ODATE 'BEGIN{s=" "} @include "func.txt"
         { if($5=="" || $6=="") { $5=$2; $6=$3 }  # -- Si no hay proceso final o no tiene fechas, se coloca la inicial
           tmp=toTimeExcel(toTimeUnix($5,$6)-toTimeUnix($2,$3)); if(tmp<0)tmp=0; print $1 FS tmp }' |
         awk -F'@' -v fi=$fi -v ff=$ff -v nDias=$nDias -v gpo=$gpo '@include "func.txt"
         BEGIN{s=" "; r[fi]=0; r[ff]=0; t0=fi; for(i=2;i<=nDias;i++) { t=strftime("%Y%m%d", toTimeUnix(t0,"000001") + day2sec(1)); r[t]=0; t0=t } }
         { r[$1]=$2 }
         END{printf("#%s@",gpo);for(i in r) printf("%s@",r[i]); printf("\n")}' >> $DAT/$nomDuracion
   else
      awk -F'@' -v nDias=$nDias -v gpo=$gpo 'BEGIN{printf("#%s@",gpo);for(i=1;i<=nDias+1;i++) printf("0@"); print}' >> $DAT/$nomDuracion
   fi
done
# -- Agrupa por renglones de grafica
mv $DAT/$nomDuracion $DAT/tma4
cat $DAT/tma4 |
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
   sed 's/$'"/`echo \\\r`/" > $DAT/$nomDuracion
# --
echo $(date '+%d-%m-%Y %H:%M:%S,00')" : creaDatosGrafica.sh. Fin" | sed 's/$'"/`echo \\\r`/" >> $arcLOG