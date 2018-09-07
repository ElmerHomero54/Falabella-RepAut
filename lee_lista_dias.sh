lee_cambios_horarios() {
   act=$(echo $2 | awk '{print substr($0,1,4)}')
   sig=$(echo $2 | awk '{print substr($0,1,4)+1}')
   aHorVerano=$(grep  "v@"$act $EXE/cambiosHorarios_$4.txt | cut -d'@' -f2,3)
   aHorInvierno=$(grep  "i@"$sig $EXE/cambiosHorarios_$4.txt | cut -d'@' -f2,3)
   horv=$(echo $aHorVerano | cut -d'@' -f 1); nvov=$(echo $aHorVerano | cut -d'@' -f 2)
   hori=$(echo $aHorInvierno | cut -d'@' -f 1); nvoi=$(echo $aHorInvierno | cut -d'@' -f 2)
}
# --
lee_dias_habiles() {
   while [ $x -le $3 ]; do
      dow=$(date -d $ft +%u)
      if [ $dow -ne 6 ] && [ $dow -ne 7 ]; then
         grep $ft diasFeriados_$4.txt > /dev/null
         if [ $? -eq 1 ]; then   # -- No es fin de semana ni feriado
            echo $ft >> $DAT/tma1; echo $ft"@"$dow >> $DAT/tma2
            x=$(( $x + 1 ))
         fi
      fi
      fx=$(date --date="$ft -1 day" +%Y-%m-%d); ft=$fx
      # -- Falla con cambio de horario. Debe obviarse la fecha de cambio de horario
      if [ $ft == $horv ]; then ft=$nvov; fi
      if [ $ft == $hori ]; then ft=$nvoi; fi
   done
}
# --
lee_todos_dias() {
   while [ $x -lt $3 ]; do
      x=$(( $x + 1 ))
      if [ $ft != $horv ] && [ $ft != $hori ]; then
         fx=$(date --date="$ft -1 day" +%Y-%m-%d)
         ft=$fx
      fi
      # -- Falla con cambio de horario. Debe obviarse la fecha de cambio de horario
      if [ $ft == $horv ] || [ $ft == $hori ]; then
         dow=7; echo $ft >> $DAT/tma1; echo $ft"@"$dow >> $DAT/tma2
         dow=6
         if [ $ft == $horv ]; then ft=$nvov; fi
         if [ $ft == $hori ]; then ft=$nvoi; fi
      else
         dow=$(date -d $ft +%u)
      fi
      echo $ft >> $DAT/tma1
      echo $ft"@"$dow >> $DAT/tma2
   done
}
# --
lee_dias() {  #  lee_dias(calendario, fecha inicial de rango, numero de dias, pais)
   rm -f $DAT/tma1; rm -f $DAT/tma2
   x=1; ft=$(echo $2 | awk '{print substr($0,1,4)"-"substr($0,5,2)"-"substr($0,7,2)}')
   lee_cambios_horarios $1 $ft $3 $4 
   if [ $1 == "HAB" ]; then
      lee_dias_habiles $1 $ft $3 $4 
   else
      lee_todos_dias $1 $ft $3 $4
   fi
   lst=$(cat $DAT/tma1 | sort | sed 's/-//g' | awk '{printf("@%s",$0)}' | awk '{print substr($0,2)}')
   dows=$(cat $DAT/tma2 | sort |
          awk -F'@' 'BEGIN{s=FS; t1="LUN@MAR@MIE@JUE@VIE@SAB@DOM";q=split(t1,dias,s)}
            {printf("@%s %s",dias[$2],substr($1,9,2))}' | awk '{print substr($0,2)}')
   rm -f $DAT/tma1; rm -f $DAT/tma2
}
# --
