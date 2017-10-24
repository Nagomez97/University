#!/usr/bin/gnuplot
#chmod +x ejemploGNUplot.gp

# Salida por pantalla simple: sudo apt-get install gnuplot-x11; set term 11
set term dumb

#set data style points
set title "Titulo"
set xlabel "etiqueta x"
set ylabel "etiqueta y"
plot "salida.txt" using 1:2 with steps title "Datos"

# Para salida a un archivo tipo portable network graphics
set term jpeg
set output "salida.txt.jpeg"
replot

set term pngcairo
set output "salida.txt.png"
replot

set term svg
set output "salida.txt.svg"
replot

# Cierra el archivo de salida
set output

pause -1 "Pulse Enter para continuar"
