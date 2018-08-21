# --
# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
# --
pais=$1
ODATE=$2
# --
nomLST="datosDiarios_"$pais".txt"
# --
# -- Genera archivo temporal mensual
# --    Borra version anterior
rm -f $DAT/tmpMensual_$pais.txt
# --    Calcula y graba el rango de meses
# --    Genera encabezados de años y meses para la grafica
echo $ODATE |
   awk -v nm=12 '
   BEGIN{ mx="ENERO@FEBRERO@MARZO@ABRIL@MAYO@JUNIO@JULIO@AGOSTO@SEPTIEMBRE@OCTUBRE@NOVIEMBRE@DICIEMBRE"; q=split(mx,meses,"@") }
   { finis=$0; yr_f=substr(finis,1,4)+0; mt_f=substr(finis,5,2)+0
     yr=yr_f;mt=mt_f
     for(i=nm;i>=1;i--) {
        print sprintf("%04d%02d",yr,mt)"@"meses[mt]
        mt=mt-1; if(mt<1) { mt=12; yr=yr-1 } } }' |
   sort -t'@' -nk 1,1 |
   awk -F'@' '
   BEGIN{s=FS}
   NR==1 {inic=$1}
   { ax=substr($1,1,4); if(ant!=ax) { let=ax; ant=ax } else let=""
     ano=ano s let
     mes=mes s $2 }
   END{finis=$1
       print inic s finis
       print substr(ano,2)
       print substr(mes,2) }' |
   sed 's/$'"/`echo \\\r`/" > $DAT/tmpMensual_$pais.txt
# --
# -- Separa los limites inicial y final del rango calculado
mi=$(head -1 $DAT/tmpMensual_$pais.txt | cut -d'@' -f 1)
mf=$(head -1 $DAT/tmpMensual_$pais.txt | cut -d'@' -f 2)
# --
echo "Rango de fechas para reporte mensual: "$mi "  " $mf
# --
# -- Genera archivo temporal con datos del rango de meses
# --
# -- Crea filtro de jobs 
filtFin=$(cat $DAT/grupos.txt | grep '^'$pais'#F@' | awk -F'@' '{for(i=2;i<=NF;i++) print $i}' | sed 's/,/|/g')
filtGrp=""
for d in $(cat $DAT/grupos.txt | grep '^'$pais'#G@' | awk -F'@' '{for(i=3;i<=NF;i++) print $i}' | sed 's/,/|/g'); do
   filtGrp=$filtGrp$(echo $d"|")
done
filtGrp=$(echo $filtGrp | sed 's/.$//')
# --
filt=$(echo $filtFin"|"$filtGrp | awk -F'|' '{for(i=1;i<=NF;i++) a[$i]=$i} END{for(i in a) printf("%s|",a[i])}' | awk '{n=length($0);print substr($0,2,n-2)}')
# --
# --    Genera archivo de datos temporal con los datos de los jobs de grupos
cat $DAT/$nomLST |
   awk -F'@' -v mi=$mi -v mf=$mf '{ anomes=substr($2,1,6); if(anomes>=mi && anomes<=mf) print }' |
   grep -E "$(echo $filt)"  |
   sort |
   awk -F'@' 'BEGIN{s="@";n=1} @include "'$EXE'/func.txt"
   { lei = $1 substr($2,1,6) # -- La clave es el job y el año/mes
     if(cve!=lei) {
        x=length(cve); job=substr(cve,1,x-6);mes=substr(cve,x-5)
        printf("%s@%s@%8.8f@%8.8f\n",job,mes,diff_inic/n,diff_finis/n)
        diff_inic=0; diff_finis=0; n=1 }
     else
        n++
     cve = $1 substr($2,1,6) # -- La clave es el job y el año/mes
     diff_inic+=toTimeUnix($3,$4)
     diff_finis+=toTimeUnix($5,$6) }
   END{printf("%s@%s@%12.8f@%12.8f\n",job,mes,diff_inic/n,diff_finis/n)}' |
   sed '1d' > $DAT/t1_$pais.txt
# --
# --    Graba los datos de hora de fin de malla
cat $DAT/t1_$pais.txt |
   grep -E "$(echo $filtFin)" |
   awk -F'@' '{print $2 FS $4}' |
   sort -rnk 1,1 |
   awk -F'@' '
      NF==1 {print;ant=$1}
      NF>1 {if(ant!=$1) print;ant=$1}
      END{if(ant!=$1) print}' |
   awk -F'@' '@include "'$EXE'/func.txt"
   { print $1 FS strftime("%H%M%S", $2) }' |
   sort -t'@' -nk 1,1 |
   awk -F'@' -v nm=12 -v odate=$ODATE '
      BEGIN{s=FS
         yr=substr(odate,1,4);mt=substr(odate,5,2)+0
         for(i=1;i<=nm;i++) {
            ix=sprintf("%04d%02d",yr,mt)
            a[ix]=0
            mt=mt-1;if(mt==0) { mt=12; yr=yr-1 } } }
      { a[$1]=$2 }
      END{for(i in a) printf("%s@",a[i]);printf("\n")}' |
   sed 's/.$//' |
   sed 's/$'"/`echo \\\r`/" >> $DAT/tmpMensual_$pais.txt
# --
# -- Procesa los tiempos de proceso de los grupos de aplicacion
# --
# -- Genera los datos de duracion por rango de fechas
for dat in $(cat $DAT/grupos.txt | grep '^'$pais'#G@'); do
   # --    Busca la hora inicial
   ini=$(echo $dat | cut -d'@' -f 3)
   grep $ini $DAT/t1_$pais.txt |
     awk -F'@' '{print $2 FS $3}' |
     sort -unt'@' -k 1,1 > $DAT/t1_mens
   # --    Busca la hora final
   fin=$(echo $dat | cut -d'@' -f 4 | sed 's/,/|/g')
   grep -E "$fin" $DAT/t1_$pais.txt |
     awk -F'@' '{print $2 FS $4}' |
     sort -unt'@' -k 1,1 > $DAT/t2_mens
   # --
   # -- Calcula tiempos de ejecucion por grupos de aplicacion
   paste -d'@' $DAT/t1_mens $DAT/t2_mens |
      awk -F'@' 'BEGIN{s=FS}
      { ji[$1]=$2;jf[$3]=$4 }
      END{for(i in ji) if(ji[i]!="" && jf[i]!="") printf("%s@%8.8f\n",i,jf[i] - ji[i]) }' |
      awk -F'@' -v nm=12 -v odate=$ODATE '
         BEGIN{s=FS
            yr=substr(odate,1,4);mt=substr(odate,5,2)+0
            for(i=1;i<=nm;i++) {
               ix=sprintf("%04d%02d",yr,mt)
               a[ix]=0
               mt=mt-1;if(mt==0) { mt=12; yr=yr-1 } } }
         { a[$1]=$2 }
         END{for(i in a) printf("%s@",a[i]);printf("\n")}' |
      sed 's/$'"/`echo \\\r`/" >> $DAT/tmpMensual_$pais.txt
done
