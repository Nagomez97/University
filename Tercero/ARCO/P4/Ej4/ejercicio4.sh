#!/bin/bash

NUMEROS=(1 2 4 6 7 8 9 10 12)
ITERATIONS=10
RES="resultados"

rm $RES
touch $RES

PAD=$(./pi_par3 | grep padding | awk '{print $8}')
echo "Padding habitual: $PAD" >> $RES

for i in ${NUMEROS[@]} ; do
	for ((j=0; j<$ITERATIONS; j++)) ; do
		RESULTADOS[$i]=$(./pi_par3 $i | grep Tiempo |  awk -v sum=${RESULTADOS[$i]} '{print $2+sum}')
	done
	RESULTADOS[$i]=$(awk -v sum=${RESULTADOS[$i]} -v it=$ITERATIONS 'BEGIN{print sum/it}')
	echo "Padding: $i Tiempo de ejecución: ${RESULTADOS[$i]}" >> $RES
done

cat $RES