#!/bin/bash

# Comprobamos que se hayan introducido los valores necesarios
if [ "$#" -lt 4 ] ; then 
	echo "Introducir los siguientes argumentos:"
	echo "$0 <nombre fichero> <Titulo grafica> <xlabel> <ylabel>"
	exit
fi

# Variables 
TEMPORALTASA="TASA.temp"
ARG=$1

# Contamos el numero de elementos
TOTALARG=`cat  $ARG | sed '/^\s*$/d' | wc -l`

# Ordenamos para agrupar y poder obtener la tasa total
sort -n $ARG | sed '/^\s*$/d' | awk -v t=$TOTALARG 'BEGIN{s=0} NR>1 && p!=$1 {printf "%s\t%s\n", p, s; s=0} {s+=1} {p=$1} END{printf "%s\t%s\n", p, s}' > $TEMPORALTASA

# Comandos de GnuPlot
gnuplot <<EOF
# Titulo grafica
set title "$2"

# Eje X
set xlabel "$3"

# Eje Y
set ylabel "$4"

set xrange [0:]

# Dibujamos la grafica
plot "$TEMPORALTASA" using 1:2 with boxes title "$2"

# La exportamos en png
set term pngcairo
set output "$2.png"
replot
set output
EOF

# Borrado del temporal
rm $TEMPORALTASA