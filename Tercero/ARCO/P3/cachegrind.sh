#!/bin/bash

# inicialiar variables
Ninicio=8144
Step=64
Nfinal=$((Ninicio+1024))
temp=cache.temp
fDAT=errores.temp

# borrar el fichero temporal
rm -f $temp $fDAT cache_1024.dat cache_2048.dat cache_4096.dat cache_8192.dat

# general un temporal vacio
touch $temp

#Bucle para iterar los tamaños de cache
for ((cache = 1024; cache <= 8192; cache *= 2)); do
	echo "Running slow and fast for a $cache Bytes L1 cache"

	#Variable para el archivo de cache
	cDAT="cache_$cache.dat"

	# Bucle para iterar los tamaños de matrices
	for((N = Ninicio; N <= Nfinal; N += Step)); do
		echo "Matriz N: $N / $Nfinal"

		valgrind --tool=cachegrind --I1=$cache,8,64 --D1=$cache,8,64 --LL=8388608,8,64 --cachegrind-out-file=$temp ./slow $N

		mr_slow=$(cat $temp | grep summary | awk '{print $3}')
		mw_slow=$(cat $temp | grep summary | awk '{print $6}')

		valgrind --tool=cachegrind --I1=$cache,8,64 --D1=$cache,8,64 --LL=8388608,8,64 --cachegrind-out-file=$temp ./fast $N

		mr_fast=$(cat $temp | grep summary | awk '{print $3}')
		mw_fast=$(cat $temp | grep summary | awk '{print $6}')

		echo "$N 	$mr_slow 	$mw_slow 	$mr_fast 	$mw_fast" >> $cDAT
	done

	awk -v CACHE=$cache '{fallos_slow = fallos_slow + $2; fallos_fast = fallos_fast + $4} END{ print "Cache de tamanio "CACHE":	"fallos_slow"	"fallos_fast}' $cDAT >> $fDAT
done

