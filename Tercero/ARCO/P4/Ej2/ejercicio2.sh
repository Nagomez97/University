#!/bin/bash

TINI=1
TFIN=4
SINI=100
SFIN=1000
STEP=$(((SFIN-SINI)/10))
TEMP="tiempos.temp"
ITERATIONS=5

make clean
make

rm *.temp

touch $TEMP

for ((i=$SINI; i<=$SFIN; i=i+$STEP)) ; do
	CADENA="$i"
	SUM=0.000000000000
	for ((k=0; k<$ITERATIONS; k++)); do
		SUM=$(./pescalar_serie $i | grep Tiempo | awk -v sum=$SUM '{print $2+sum}' | bc)
	done
	SUM=$(($SUM/$ITERATIONS))
	CADENA="$CADENA\t$SUM"
	SUM=0.000000000000
	for ((j=$TINI; j<=$TFIN; j++ )); do
		for ((k=0; k<$ITERATIONS; k++)); do
			SUM=$(./pescalar_par2 $i $j | grep Tiempo | awk -v sum=$SUM '{print $2+sum}' | bc)
			echo "$SUM $k $j $i"
		done
		SUM=$(($SUM/$ITERATIONS))
		CADENA="$CADENA\t$SUM"
	done
	echo -e "$CADENA" >> $TEMP
done
