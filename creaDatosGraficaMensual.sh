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
       diff_inic+=USTime2ExcelTime($4)
       diff_finis+=USTime2ExcelTime($6) }
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
   #awk -F'@' '@include "'$EXE'/func.txt"
   #{ print $1 FS strftime("%H%M%S", $2) }' |
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
      END{for(i in ji)
             if(ji[i]!="" && jf[i]!="") {
                if(jf[i]<ji[i]) jf[i]=jf[i]+1
                printf("%s@%8.8f\n",i,jf[i] - ji[i]) 
             } }' |
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
# --
# -- Proceso adicional que busca los datos en archivos mensuales
# --
# -- Lee el rango de fechas
ini=$(head -1 $DAT/tmpMensual_$pais.txt | cut -d'@' -f 1)
fin=$(head -1 $DAT/tmpMensual_$pais.txt | cut -d'@' -f 2)
# --
# -- Obtiene todos los meses del rango
rango=$(awk -F'@' -v nm=12 'BEGIN{s=FS}
        NR==1 {ini=$1;fin=$2}
        NR==2 {ano=substr(ini,1,4)+0;mes=substr(ini,5,2)+0;
           for(i=1;i<=nm;i ++) { printf("%04d%02d@",ano,mes)
              mes=mes+1; if(mes>nm) {mes=1;ano=ano+1} }
           printf("\n"); exit 0 }' $DAT/tmpMensual_$pais.txt | sed 's/.$//g')
# --
# -- Prepara la salida para Excel para comparar contra datos anteriores
cat $DAT/tmpMensual_$pais.txt |
   sed 's/\(.*\)@/\1 /' |
   awk -F'@' -v nm=12 -v rango=$rango '
   BEGIN{s=FS;q=split(rango,cve,"@")}
   NR>3 { for(i=1;i<=NF;i++) print NR-3 s cve[i] s $i }' > $DAT/tma1
# --
# -- Busca los datos mensuales anteriores
cat $DAT/dat_men_${pais}_sat.txt |
   awk -F'@' -v ini=$ini -v fin=$fin '{ if($1>=ini && $1<=fin) print }' |
   awk -F'@' -v nm=12 -v rango=$rango -v nf=$(head -1 $DAT/dat_men_${pais}_sat.txt | awk -F'@' '{print NF-1}') '
   BEGIN{ s=FS;cr=""; for(i=1;i<=nf;i++) cr=cr"@0"; cr=substr(cr,2)
      q=split(rango,cve,"@");for(i=1;i<=q;i++) a[cve[i]]=cr }
   { d="";for(i=2;i<=NF;i++) d=d s $i; d=substr(d,2); a[$1]=d }
   END{for(i in a) print i s a[i]}' |
   awk -F'@' '@include "'$EXE'/func.txt"
      { for(i=2;i<NF;i++) printf("%d%s%s%s%f\n",i-1,FS,$1,FS,USTime2ExcelTime($i)) }' | #print i-1 FS $1 FS USTime2ExcelTime($i) }' |
   sort -t'@' -nk1,1 > $DAT/tma2
# --
# --
head -3 $DAT/tmpMensual_$pais.txt > $DAT/tmpMensual_${pais}_2.txt
paste -d'@' $DAT/tma1 $DAT/tma2 |
   awk -F'@' '{ cve=$2; monto=$3; if(monto==0 && $6!=0) monto=$6
                print $1 FS cve FS monto }' |
   awk -F'@' '{if(ant!=$1) { print substr(sal,2); sal=""; ant=$1 }
      sal=sal FS $3 }
   END{print substr(sal,2)}' |
   sed '1d' |
   awk -F'@' '{ print }
   NR>4 { for(i=1;i<=NF;i++) sum[i]+=$i }
   END{for(i=1;i<=NF;i++) printf("%f%s",sum[i]+$i,FS); printf("\n")}' >> $DAT/tmpMensual_${pais}_2.txt
# --
        cp $DAT/tmpMensual_$pais.txt $DAT/tma3
cp $DAT/tmpMensual_${pais}_2.txt $DAT/tmpMensual_$pais.txt
rm -f $DAT/tmpMensual_${pais}_2.txt
