#!/bin/bash

TINI=1
TFIN=4
SINI=10000000
SFIN=100000000
STEP=$((($SFIN-$SINI)/10))
TEMP="tiempos.temp"
ACC="acceleration.temp"
fPNGtime="times.png"
fPNGacc="acceleration.png"
ITERATIONS=5

make clean
make

rm *.temp

touch $TEMP $ACC

for ((i=$SINI; i<=$SFIN; i=i+$STEP)) ; do
	CADENA="$i"
	SUM=0
	echo "Tam: $i/$SFIN"
	for ((k=0; k<$ITERATIONS; k++)); do
		SUM=$(./pescalar_serie $i | grep Tiempo | awk -v sum=$SUM '{print $2+sum}')
	done
	SUM=$(awk -v sum=$SUM -v it=$ITERATIONS 'BEGIN{print sum/it}')
	CADENA="$CADENA\t$SUM"
	for ((j=$TINI; j<=$TFIN; j++ )); do
		SUM=0
		for ((k=0; k<$ITERATIONS; k++)); do
			SUM=$(./pescalar_par2 $i $j | grep Tiempo | awk -v sum=$SUM '{print $2+sum}')
		done
		SUM=$(awk -v sum=$SUM -v it=$ITERATIONS 'BEGIN{print sum/it}')
		CADENA="$CADENA\t$SUM"
	done
	echo -e "$CADENA" >> $TEMP
	#echo -e $CADENA | awk '{print $2}'
	echo $(echo -e $CADENA | awk '{print $1 "\t" $2/$3 "\t" $2/$4 "\t" $2/$5 "\t" $2/$6 }') >> $ACC
done

echo "Imprimiendo grafica de tiempo de ejecucion..."

gnuplot << END_GNUPLOT
set title "Escalar Product Execution Time"
set ylabel "Time (s)"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNGtime"
plot "$TEMP" using 1:2 with lines lw 2 title "serie", \
	 "$TEMP" using 1:3 with lines lw 2 title "parallel 1 thread", \
	 "$TEMP" using 1:4 with lines lw 2 title "parallel 2 threads", \
	 "$TEMP" using 1:5 with lines lw 2 title "parallel 3 threads", \
     "$TEMP" using 1:6 with lines lw 2 title "parallel 4 threads"
replot
quit
END_GNUPLOT

echo "Imprimiendo grafica de aceleracion..."

gnuplot << END_GNUPLOT
set title "Escalar Acceleration"
set ylabel "Acceleration"
set xlabel "Vector Size"
set key right bottom
set grid
set term png
set output "$fPNGacc"
plot "$ACC" using 1:2 with lines lw 2 title "serie / parallel 1 thread", \
	 "$ACC" using 1:3 with lines lw 2 title "serie / parallel 2 thread", \
	 "$ACC" using 1:4 with lines lw 2 title "serie / parallel 3 threads", \
     "$ACC" using 1:5 with lines lw 2 title "serie / parallel 4 threads"
replot
quit
END_GNUPLOT