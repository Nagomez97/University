#!/bin/bash

# inicialiar variables
P=0
Ninicio=$((10000+1024*P))
Step=64
Nfinal=$((Ninicio+1024))
temp=cache.temp
fPNGread=cache_lectura.png
fPNGwrite=cache_escritura.png

make

# borrar el fichero temporal
rm -f $temp $fDAT cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat

# general un temporal vacio
touch $temp

#Bucle para iterar los tamaños de cache
for ((cache = 1024; cache <= 8192; cache *= 2)); do
	echo
	echo "Running slow and fast for a $cache Bytes L1 cache"
	#Variable para el archivo de cache
	cDAT="cache_$cache.dat"

	# Bucle para iterar los tamaños de matrices
	for((N = Ninicio; N <= Nfinal; N += Step)); do
		echo
		echo "Matriz N: $N / $Nfinal"
		echo

		valgrind -q --tool=cachegrind --I1=$cache,1,64 --D1=$cache,1,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./slow $N

		#mr_slow=$(cat $temp | grep summary | awk '{print $3}')
		#mw_slow=$(cat $temp | grep summary | awk '{print $6}')
		mr_slow=$(cat $temp | grep summary | awk '{print $6}')
		mw_slow=$(cat $temp | grep summary | awk '{print $9}')

		valgrind -q --tool=cachegrind --I1=$cache,1,64 --D1=$cache,1,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./fast $N

		#mr_fast=$(cat $temp | grep summary | awk '{print $3}')
		#mw_fast=$(cat $temp | grep summary | awk '{print $6}')
		mr_fast=$(cat $temp | grep summary | awk '{print $6}')
		mw_fast=$(cat $temp | grep summary | awk '{print $9}')

		echo "$N 	$mr_slow 	$mw_slow 	$mr_fast 	$mw_fast" >> $cDAT
	done
done

echo "Generating reading errors plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"	
gnuplot << END_GNUPLOT
set title "Read Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGread"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "slow 1024", \
     "cache_1024.dat" using 1:4 with lines lw 2 title "fast 1024", \
     "cache_2048.dat" using 1:2 with lines lw 2 title "slow 2048", \
     "cache_2048.dat" using 1:4 with lines lw 2 title "fast 2048", \
     "cache_4096.dat" using 1:2 with lines lw 2 title "slow 4096", \
     "cache_4096.dat" using 1:4 with lines lw 2 title "fast 4096", \
     "cache_8192.dat" using 1:2 with lines lw 2 title "slow 8192", \
     "cache_8192.dat" using 1:4 with lines lw 2 title "fast 8192"

replot
quit
END_GNUPLOT

echo "Generating write errors plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"	
gnuplot << END_GNUPLOT
set title "Write Misses"
set ylabel "Misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGwrite"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "slow 1024", \
     "cache_1024.dat" using 1:5 with lines lw 2 title "fast 1024", \
     "cache_2048.dat" using 1:3 with lines lw 2 title "slow 2048", \
     "cache_2048.dat" using 1:5 with lines lw 2 title "fast 2048", \
     "cache_4096.dat" using 1:3 with lines lw 2 title "slow 4096", \
     "cache_4096.dat" using 1:5 with lines lw 2 title "fast 4096", \
     "cache_8192.dat" using 1:3 with lines lw 2 title "slow 8192", \
     "cache_8192.dat" using 1:5 with lines lw 2 title "fast 8192"

replot
quit
END_GNUPLOT

