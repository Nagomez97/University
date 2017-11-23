#!/bin/bash

# inicializar variables
Ninicio=1792
Npaso=16
Nfinal=$((Ninicio+256))
tempTime=tiempos.dat

#borrar ficheros temporales
rm -f $tempTime
#generar ficheros vacios

for ((j = 1; j <= Iterations; j+=1)); do
echo "Running slow and fast multiplication in iteration $j"

	for ((N = Ninicio, i=0 ; N <= Nfinal ; N += Npaso, i+=1)); do
		echo "matriz N: $N / $Nfinal..."

		# Ejecutamos slow con N, filtramos la linea que contiene el tiempo y
		# seleccionamos la tercera columna (el valor del tiempo). Deja el valor
		# en un array de variables para poder imprimirlo posteriormente
		multTime=$(./multiply $N | grep 'time' | awk '{print $3}')
		
		# Ejecutamos fast con N, filtramos la linea que contiene el tiempo y
		# seleccionamos la tercera columna (el valor del tiempo). Deja el valor
		# en una variable para poder imprimirlo posteriormente
		transTime=$(./transposed $N | grep 'time' | awk '{print $3}')

		echo "$N	$multTime	$transTime" >> $temp
	done
done
