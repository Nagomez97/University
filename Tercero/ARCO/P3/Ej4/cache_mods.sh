#!/bin/bash

# inicializar variables
P=0
Ninicio=$((512+256*P))
Npaso=16
Nfinal=$((Ninicio+256))
tempError=errores.dat
tempV=valgrind.temp
Iterations=10

#borrar ficheros temporales
rm -f $tempError $tempV
#generar ficheros vacios
touch $tempError

echo "Running slow and fast multiplication in iteration $j"

for ((N = Ninicio; N <= Nfinal ; N += Npaso)); do
	echo "matriz N: $N / $Nfinal..."

	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./multiply $N

	mr_mult1w=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --I1=4096,1,64 --D1=4096,1,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./transposed $N

	mr_tran1w=$(cat $tempV | grep summary | awk '{print $6}')


	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --I1=4096,4,64 --D1=4096,4,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./multiply $N

	mr_mult4w=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --I1=4096,4,64 --D1=4096,4,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./transposed $N

	mr_tran4w=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --I1=4096,64,64 --D1=4096,4,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./multiply $N

	mr_multfa=$(cat $tempV | grep summary | awk '{print $6}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --I1=4096,64,64 --D1=4096,4,64 --LL=8388608,1,64 --cachegrind-out-file=$temp ./transposed $N

	mr_tranfa=$(cat $tempV | grep summary | awk '{print $6}')


	echo "$N	$mr_mult1w	$mr_tran1w	$mr_mult4w $mr_tran4w	$mr_multfa	$mr_tranfa" >> $tempError
done
