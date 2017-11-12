#!/bin/bash

# Comprobamos que se hayan introducido los valores necesarios
if [ "$#" -lt 4 ] ; then 
	echo "Introducir los siguientes argumentos:"
	echo "$0 <nombre fichero> <Titulo grafica> <xlabel> <ylabel>"
	exit
fi

# Variables 
TEMPORALECDF="ECDF.temp"
ARG=$1

# Contamos el numero de elementos
TOTALARG=`cat  $ARG | sed '/^\s*$/d' | wc -l`

# Ordenamos para agrupar y poder obtener la frecuencia acumulada de los datos de la primera columna
sort -n $ARG | sed '/^\s*$/d' | awk -v t=$TOTALARG 'BEGIN{s=0; printf "0\t0\n"} NR>1 && p!=$1 {printf "%s\t%s\n", p, (s/t)} {s+=1} {p=$1} END{printf "%s\t%s\n", p, (s/t)}' > $TEMPORALECDF

# Comandos de GnuPlot
gnuplot <<EOF
# Titulo grafica
set title "$2"

# Eje X
set xlabel "$3"

# Eje Y
set ylabel "$4"

# Rango variable y
set yrange [0:1]

# Rango variable x
set xrange [0:0.001]

# Dibujamos la grafica
plot "$TEMPORALECDF" using 1:2 with steps title "$2"

# La exportamos en png
set term pngcairo
set output "$2.png"
replot
set output
EOF

# Borrado del temporal
rm $TEMPORALECDF