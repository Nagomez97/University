#!/bin/bash

# inicializar variables
Ninicio=16144      #10000 + 1024*6
Npaso=64
Nfinal=$((Ninicio+1024))
fDAT=slow_fast_time.dat
fPNG=slow_fast_time.png
Iterations=10

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG

# generar el fichero DAT vacío
touch $fDAT

for ((j = 1; j <= Iterations; j+=1)); do
echo "Running slow and fast in iteration $j"
	# bucle para N desde Ninicio hasta Nfinal con un paso de NPaso
	for ((N = Ninicio, i=0; N <= Nfinal ; N += Npaso, i+=1)); do
		echo "slow N: $N / $Nfinal..."
		
		# Ejecutamos slow con N, filtramos la linea que contiene el tiempo y
		# seleccionamos la tercera columna (el valor del tiempo). Deja el valor
		# en un array de variables para poder imprimirlo posteriormente
		slowTime[$i]=$(./slow $N | grep 'time' | awk '{print $3}')
	done
	# bucle para N desde Ninicio hasta Nfinal con un paso de NPaso
	for ((N = Ninicio, i=0 ; N <= Nfinal ; N += Npaso, i+=1)); do
		echo "fast N: $N / $Nfinal..."
		
		# Ejecutamos fast con N, filtramos la linea que contiene el tiempo y
		# seleccionamos la tercera columna (el valor del tiempo). Deja el valor
		# en una variable para poder imprimirlo posteriormente
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

		echo "$N	${slowTime[$i]}	$fastTime" >> $fDAT
	done
done

cat $fDat | sort -n | awk 'BEGIN{slow=0; fast=0; n=0} NR>1 && N!=$1{print N "\t" slow/n "\t" fast/n; slow=0; fast=0; n=0} {slow=slow+$2; fast=fast+$3; n=n+1; N=$1} END{print N "\t" slow/n "\t" fast/n}' > $fDat

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
