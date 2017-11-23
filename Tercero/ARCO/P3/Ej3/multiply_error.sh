#!/bin/bash

# inicializar variables
P=0
Ninicio=$((256+256*P))
Npaso=16
Nfinal=$((Ninicio+256))
tempError=errores.dat
tempV=valgrind.temp
Iterations=10

#borrar ficheros temporales
rm -f $tempError $tempV
#generar ficheros vacios
touch $tempError


for ((N = Ninicio; N <= Nfinal ; N += Npaso)); do
	echo "matriz N: $N / $Nfinal..."

	# Ejecutamos el programa de multiplicación mediante cachegrind, 
	# filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --cachegrind-out-file=$tempV ./multiply $N

	mr_mult=$(cat $tempV | grep summary | awk '{print $6}')
	mw_mult=$(cat $tempV | grep summary | awk '{print $9}')

	# Ejecutamos el programa de multiplicación transpuesta mediante 
	# cachegrind, filtramos las columnas D1mr y D1mw.

	valgrind -q --tool=cachegrind --cachegrind-out-file=$tempV ./transposed $N

	mr_tran=$(cat $tempV | grep summary | awk '{print $6}')
	mw_tran=$(cat $tempV | grep summary | awk '{print $9}')

	echo "$N	$mr_mult	$mw_mult	$mr_tran	$mw_mult" >> $tempError
done
