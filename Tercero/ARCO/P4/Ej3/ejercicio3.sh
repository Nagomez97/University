#!/bin/bash

THINI=1
THFIN=4
TIMES="times_test.temp"
SIZE=3000

rm $TIMES

touch $TIMES

make clean
make

SERIE=$(./trans_serie $SIZE | grep Execution | awk '{print $3}')
BUC1="Bucle 1\t\t"
BUC2="Bucle 2\t\t"
BUC3="Bucle 3\t\t"
SPEED1="Bucle 1\t"
SPEED2="Bucle 2\t"
SPEED3="Bucle 3\t"
# Bucle para calcular la tabla con distinto numero de hilos
for (( t = $THINI; t <= $THFIN; t++ )); do
	t1=$(./trans_bucle1 $SIZE $t| grep Execution | awk '{print $3}')
	t2=$(./trans_bucle2 $SIZE $t| grep Execution | awk '{print $3}')
	t3=$(./trans_bucle3 $SIZE $t| grep Execution | awk '{print $3}')
	BUC1="$BUC1\t$t1"
	BUC2="$BUC2\t$t2"
	BUC3="$BUC3\t$t3"
	SPEED1="$SPEED1\t\t$(awk -v t=$t1 -v s=$SERIE 'BEGIN{print s/t}')"
	SPEED2="$SPEED2\t\t$(awk -v t=$t2 -v s=$SERIE 'BEGIN{print s/t}')"
	SPEED3="$SPEED3\t\t$(awk -v t=$t3 -v s=$SERIE 'BEGIN{print s/t}')"
done
echo "Tabla de tiempos" >> $TIMES
echo -e "Version/Hilos\t\t1\t\t2\t\t3\t\t4" >> $TIMES
echo -e "Serie\t\t\t$SERIE" >> $TIMES
echo -e $BUC1 >> $TIMES
echo -e $BUC2 >> $TIMES
echo -e $BUC3 >> $TIMES
echo >> $TIMES
echo "Tabla de speedup" >> $TIMES
echo -e "Version/Hilos\t\t1\t\t2\t\t3\t\t4" >> $TIMES
echo -e "Serie\t\t\t1" >> $TIMES
echo -e $SPEED1 >> $TIMES
echo -e $SPEED2 >> $TIMES
echo -e $SPEED3 >> $TIMES
echo "El archivo $TIMES contiene los datos de las tablas de ejecucion"
