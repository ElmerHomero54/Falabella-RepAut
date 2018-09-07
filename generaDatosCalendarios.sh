# --
EXE="/cygdrive/c/Falabella/AutRep/exe"
DAT="/cygdrive/c/Falabella/AutRep/dat"
REP="/cygdrive/c/Falabella/AutRep/rep"
FTP="/cygdrive/c/Falabella/AutRep/dat/ftp"
# --
calend=$1
odate=$2
nDias=$3
pais=$4
#--
function generaDatosCalendarios() {
   cal -m $1 |
      sed '1d' | sed '1d' |
      grep -v 'enero' | grep -v 'abril' | grep -v 'julio' | grep -v 'octubre' |
      grep -v 'lu ma' |
      awk -v ano=$1 ' @include "../exe/func.txt" 
      BEGIN{s="@"; inic=-2
             l="2,1,2,1,2,1,2,1,2,1,2,1,2,3,2,1,2,1,2,1,2,1,2,1,2,1,2,3,2,1,2,1,2,1,2,1,2,1,2,1,2"
             d="1,0,2,0,3,0,4,0,5,0,6,0,7,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,1,0,2,0,3,0,4,0,5,0,6,0,7"
             q2=split(d,ds,",")}
      { if(NR%6==1) inic=inic+3
        if(readFields()) {
           for(i=1;i<=q;i++)
              if(i%2==1 && field[i]!="") {
                 mes=inic+2
                 if(i<14) mes=inic
                 if(i>14 && i<28) mes=inic+1
                 printf("%04d%02d%02d@%d\n",ano,mes,field[i],ds[i]) } } }' |
       sort -t'@' >> $2

echo "0.. recien salido del horno"
cat $2
echo "---------------------------------"
}
# --
function lee_dias() {
   rm -f $DAT/tma2
   rango=$(echo $odate | awk '{ano=substr($0,1,4);print ano","ano+1}')
echo "RABGO: "$rango
   for a in $(echo $rango | awk -F',' '{for(i=1;i<=NF;i++) print $i}'); do
echo "--->"$a
      generaDatosCalendarios $a $DAT/tma2
   done
   # -- Agrega los dias festivos del pais
   touch $EXE/diasFeriados_$pais.txt
   cat $EXE/diasFeriados_$pais.txt | sed 's/-//g' | awk '{print $0"@X"}' > $DAT/tma1
echo "*************************************************************"
echo "1...."
cat $DAT/tma1

   join -t'@' $DAT/tma2 $DAT/tma1 -a1 |
     sort -rk 1 |
     awk -F'@' -v odate=$odate -v tip=$calend -v nDias=$nDias '
     { if($1==odate) esOK=1
       if(esOK)
          if(tip=="HAB") {
             if($2+0<6 && $3!="X") { print; n=n+1 }
          }
          else { print; n=n+1 }
       if(n>=nDias) exit }' |
     sort |
     awk -F'@' '
     BEGIN{d="LUN@MAR@MIE@JUE@VIE@SAB@DOM";split(d,dias,"@")}
     { print "1:"$1; print "2:"dias[$2]" "substr($1,7,2) }' > $DAT/tma1
   # --
cat $DAT/tma1
   lst=$(grep '^1:' $DAT/tma1 | sed 's/1://g' | awk '{printf("@%s",$0)}' | awk '{print substr($0,2)}')
   dows=$(grep '^2:' $DAT/tma1 | sed 's/2://g' | awk '{printf("@%s",$0)}' | awk '{print substr($0,2)}')
}