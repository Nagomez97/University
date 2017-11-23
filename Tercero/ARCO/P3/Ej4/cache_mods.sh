#!/bin/bash

# inicializar variables
P=0
Ninicio=$((512+256*P))
Npaso=16
Nfinal=$((Ninicio+256))
tempError=errores.dat
tempTime=tiempos.dat
tempV=valgrind.temp
Iterations=10

#borrar ficheros temporales
rm -f $tempError $tempV $tempTime
#generar ficheros vacios
touch $tempError

echo "Running slow and fast multiplication in iteration $j"

for ((N = Ninicio; N <= Nfinal ; N += Npaso)); do
	echo "matriz N: $N / $Nfinal..."

	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	mult1w_time=$(valgrind -q --tool=cachegrind --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 --cachegrind-out-file=$tempV ./multiply $N | grep "Execution time:" | awk '{print $3}')

	mr_mult1w=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	tran1w_time=$(valgrind -q --tool=cachegrind --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 --cachegrind-out-file=$tempV ./transposed $N | grep "Execution time:" | awk '{print $3}')

	mr_tran1w=$(cat $tempV | grep summary | awk '{print $6}')


	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	mult4w_time=$(valgrind -q --tool=cachegrind --I1=4096,4,64 --D1=4096,4,64 --LL=8388608,1,64 --cachegrind-out-file=$tempV ./multiply $N | grep "Execution time:" | awk '{print $3}')

	mr_mult4w=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	tran4w_time=$(valgrind -q --tool=cachegrind --I1=4096,4,64 --D1=4096,4,64 --LL=8388608,1,64 --cachegrind-out-file=$tempV ./transposed $N | grep "Execution time:" | awk '{print $3}')

	mr_tran4w=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	multfa_time=$(valgrind -q --tool=cachegrind --I1=4096,64,64 --D1=4096,64,64 --LL=8388608,1,64 --cachegrind-out-file=$tempV ./multiply $N | grep "Execution time:" | awk '{print $3}')

	mr_multfa=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	tranfa_time=$(valgrind -q --tool=cachegrind --I1=4096,64,64 --D1=4096,64,64 --LL=8388608,1,64 --cachegrind-out-file=$tempV ./transposed $N | grep "Execution time:" | awk '{print $3}')

	mr_tranfa=$(cat $tempV | grep summary | awk '{print $6}')


	echo "$N	$mr_mult1w	$mr_tran1w	$mr_mult4w $mr_tran4w	$mr_multfa	$mr_tranfa" >> $tempError
	echo "$N	$mult1w_time	$tran1w_time	$mult4w_time $tran4w_time	$multfa_time	$tranfa_time" >> $tempTime
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
plot "$tempError" using 1:2 with lines lw 2 title "multiply 1 way", \
     "$tempError" using 1:3 with lines lw 2 title "transpose 1 way", \
     "$tempError" using 1:4 with lines lw 2 title "multiply 4 way", \
     "$tempError" using 1:5 with lines lw 2 title "transpose 4 way", \
     "$tempError" using 1:6 with lines lw 2 title "multiply fully associative", \
     "$tempError" using 1:7 with lines lw 2 title "transpose fully associative"

replot
quit
END_GNUPLOT

echo "Generating write errors plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"	
gnuplot << END_GNUPLOT
set title "Execution time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGwrite"
plot "$tempTime" using 1:2 with lines lw 2 title "multiply 1 way", \
     "$tempTime" using 1:3 with lines lw 2 title "transpose 1 way", \
     "$tempTime" using 1:4 with lines lw 2 title "multiply 4 way", \
     "$tempTime" using 1:5 with lines lw 2 title "transpose 4 way", \
     "$tempTime" using 1:6 with lines lw 2 title "multiply fully associative", \
     "$tempTime" using 1:7 with lines lw 2 title "transpose fully associative"

replot
quit
END_GNUPLOT
