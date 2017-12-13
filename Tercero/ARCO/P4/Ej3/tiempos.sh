#!/bin/bash

NINI=$((512 + 4))
NFIN=$((1024 + $NINI))
STEP=64
TIMES="times_graphics.temp"
ITERATIONS=5
THREADS=4
PNG_time="Ej3_tiempos.png"
PNG_acc="Ej3_acceleration.png"

rm $TIMES

touch $TIMES

echo "Obteniendo informacion de tiempos de ejecucion en serie y con paralelizacion optima (bucle interno y 4 threads)"

#Tamanio	Serie	Paralela
for (( n = $NINI; n <= $NFIN; n=n+$STEP )); do
	SUMA_SERIE=0
	SUMA_TRANS=0
	echo "Size: $n/$NFIN"
	for (( i = 0; i < $ITERATIONS; i++ )); do
		S=$(./trans_serie $n | grep Execution | awk '{print $3}')
		SUMA_SERIE=$(awk -v t=$S -v s=$SUMA_SERIE 'BEGIN{print t+s}')
		T=$(./trans_bucle3 $n $THREADS | grep Execution | awk '{print $3}')
		SUMA_TRANS=$(awk -v t=$T -v s=$SUMA_TRANS 'BEGIN{print t+s}')
	done
	SUMA_SERIE=$(awk -v s=$SUMA_SERIE -v i=$ITERATIONS 'BEGIN{print s/i}')
	SUMA_TRANS=$(awk -v s=$SUMA_TRANS -v i=$ITERATIONS 'BEGIN{print s/i}')
	ACC=$(awk -v st=$SUMA_TRANS -v ss=$SUMA_SERIE 'BEGIN{print ss/st}')
	echo -e "$n\t$SUMA_SERIE\t$SUMA_TRANS\t$ACC" >> $TIMES
done

echo "Imprimiendo grafica de tiempo de ejecucion..."

gnuplot << END_GNUPLOT
set title "Matrix Execution Time"
set ylabel "Time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$PNG_time"
plot "$TIMES" using 1:2 with lines lw 2 title "Serie", \
	 "$TIMES" using 1:3 with lines lw 2 title "Paralelizacion interna"
replot
quit
END_GNUPLOT

echo "Imprimiendo grafica de aceleración"

gnuplot << END_GNUPLOT
set title "Matrix Acceleration Time"
set ylabel "Acceleration"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$PNG_acc"
plot "$TIMES" using 1:4 with lines lw 2 title "Aceleracion (Serie/paralela)"
replot
quit
END_GNUPLOT
