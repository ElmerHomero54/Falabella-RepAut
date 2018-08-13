# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
nomLST="datosDiarios.txt"
nomDuracion="datGrafic.txt"
# --
pais="per"
ODATE="20180806"
nDias=21
# --
rm -f $DAT/$nomDuracion
rm -f $DAT/t1
rm -f $DAT/t2
# --
# -- Determina fechas inicial y final del rango de datos
# -- Siempre el ODATE sera la final. La inicial son n dias antes
fi=$(awk -v odate=$ODATE -v nDias=$nDias 'BEGIN{s= " "; print strftime("%Y%m%d", toTimeUnix(odate,"000001") - day2sec(nDias))} @include "func.txt"')
echo $fi | awk '@include "func.txt"
  {print toUSDate($0)}' | sed 's/$'"/`echo \\\r`/" > $DAT/$nomDuracion
# --
ff=$ODATE
# --
rm -f $DAT/t0
# -- Busca la hora final de la malla
# -- Lee las horas finales de los jobs de fin de malla
for a in $(cat $DAT/grupos.txt | grep '^'$pais'#F@' | cut -d'@' -f 2); do
   grep $a $DAT/$nomLST | grep '^'$pais | awk -F'@' -v fi=$fi -v ff=$ff '{if($3>=fi && $3<=ff) print $3 FS $6 FS $7}' >> $DAT/t0
done
# -- Busca la hora mas alta por fecha
cat $DAT/t0 | sort -t'@' -nk 1,1 -nk2,2 -nk 3,3 |
   awk -F'@' '{ if($1!=cveAnt) { print regAnt; cveAnt=$1 }
                regAnt=$0; cveAnt=$1}
      END{print regAnt}' |
   # -- Crea registro para generar grafica
   awk -F'@' -v fi=$fi -v ff=$ff -v nDias=$nDias '@include "func.txt"
   BEGIN{s=" "; r[fi]=0; r[ff]=0; t0=fi; for(i=2;i<=nDias;i++) { t=strftime("%Y%m%d", toTimeUnix(t0,"000001") + day2sec(1)); r[t]=0; t0=t } }
   { r[$1]=USTime2ExcelTime($3) }
   END{for(i in r) printf("%s@",r[i]); printf("\n")}' | sed 's/$'"/`echo \\\r`/" >> $DAT/$nomDuracion
# --
# -- Genera los datos de duracion por rango de fechas
for dat in $(cat $DAT/grupos.txt | grep '^'$pais'#G@'); do
   # -- Busca los jobs de inicio y fin para el grupo
   ini=$(echo $dat | cut -d'@' -f 3)
   fin=$(echo $dat | cut -d'@' -f 4)
   # -- Busca los tiempos de proceso de los jobs de inicio y fin
   grep $ini $DAT/$nomLST | grep '^'$pais | awk -F'@' -v fi=$fi -v ff=$ff '{if($3>=fi && $3<=ff) print $3 FS $4 FS $5}' > $DAT/t1
   n1=$(wc -l $DAT/t1 | cut -d' ' -f 1)
   grep $fin $DAT/$nomLST | grep '^'$pais | awk -F'@' -v fi=$fi -v ff=$ff '{if($3>=fi && $3<=ff) print $3 FS $6 FS $7}' > $DAT/t2
   n2=$(wc -l $DAT/t2 | cut -d' ' -f 1)
   # -- Si hallo los tiempos, calcula la duracion
   if [ $n1 -ne 0 ] && [ $n2 -ne 0 ] && [ $n1 -eq $n2 ]; then
      # -- Calcula la diferencia de tiempo entre inicio y fin
      paste -d'@' $DAT/t1 $DAT/t2 |
         awk -F'@' -v odate=$ODATE 'BEGIN{s=" "} @include "func.txt"
         { tmp=toTimeExcel(toTimeUnix($5,$6)-toTimeUnix($2,$3)); if(tmp<0)tmp=0; print $1 FS tmp }' |
         awk -F'@' -v fi=$fi -v ff=$ff -v nDias=$nDias '@include "func.txt"
         BEGIN{s=" "; r[fi]=0; r[ff]=0; t0=fi; for(i=2;i<=nDias;i++) { t=strftime("%Y%m%d", toTimeUnix(t0,"000001") + day2sec(1)); r[t]=0; t0=t } }
         { r[$1]=$2 }
         END{for(i in r) printf("%s@",r[i]); printf("\n")}' |
         sed 's/$'"/`echo \\\r`/" >> $DAT/$nomDuracion
   else
      awk -F'@' -v nDias=$nDias 'BEGIN{for(i=1;i<=nDias+1;i++) printf("0@"); print}'| sed 's/$'"/`echo \\\r`/" >> $DAT/$nomDuracion
   fi
done
