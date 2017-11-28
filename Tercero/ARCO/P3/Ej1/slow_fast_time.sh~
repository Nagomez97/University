#!/bin/bash

# inicializar variables
P=6
Ninicio=$((10000 + 1024 * P))      #10000 + 1024*6
Npaso=64
Nfinal=$((Ninicio+1024))
fDAT=slow_fast_time.dat
temp=temporal.dat
fPNG=slow_fast_time.png
Iterations=10

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG $temp

# generar el fichero DAT vacío
touch $fDAT
touch $temp

for ((j = 1; j <= Iterations; j+=1)); do
echo "Running slow and fast in iteration $j"

	for ((N = Ninicio; N <= Nfinal ; N += Npaso)); do
		echo "matriz N: $N / $Nfinal..."

		# Ejecutamos slow con N, filtramos la linea que contiene el tiempo y
		# seleccionamos la tercera columna (el valor del tiempo). Deja el valor
		# en un array de variables para poder imprimirlo posteriormente
		slowTime=$(./slow $N | grep 'time' | awk '{print $3}')
		
		# Ejecutamos fast con N, filtramos la linea que contiene el tiempo y
		# seleccionamos la tercera columna (el valor del tiempo). Deja el valor
		# en una variable para poder imprimirlo posteriormente
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

		echo "$N	$slowTime	$fastTime" >> $temp
	done
done

#cat $fDAT | sort -n | awk 'BEGIN{slow=0; fast=0; n=0; N=0} {slow=slow+$2; fast=fast+$3; n=n+1;} NR>1 && N!=$1{print N "\t" slow/n "\t" fast/n; slow=0; fast=0; n=0} {N=$1} END{print N "\t" slow/n "\t" fast/n}'

awk -v I=$Iterations '{media_slow[$1] = media_slow[$1] + $2; media_fast[$1] = media_fast[$1] + $3} END{for(j in media_slow) print j"	"media_slow[j]/I"	"media_fast[j]/I}' $temp | sort > $fDAT
echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"	
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
