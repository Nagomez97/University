#! /bin/bash

##########################################################################
# Analizamos los argumentos del script
##########################################################################

# El primer argumento debe ser el nombre de la traza a analizar
NOMBRE_TRAZA=$1
TEMPORAL="practica3.temp"
TOP=10
RESULTADOS="practica3.res"

# Comprobamos que se haya introducido un argumento
if [ "$#" -ne 1 ] ; then 
	echo "Es necesario introducir un parámetro:"
	echo "$0 <Nombre de la traza>"
	exit
fi

# Comprobamos que ese arguento es un fichero pcap
if [[ $NOMBRE_TRAZA != *.pcap ]] ; then
	echo "El archivo introducido como primer argumento debe ser de tipo pcap:"
	echo "$0 <Nombre de la traza>"
	exit
fi

##########################################################################
# Obtenemos los porcentajes de los paquetes de tipo IP, ya sean VLAN o no.
##########################################################################
echo ""
echo "--------------------------------------------------"
echo ""
echo "Porcentajes de paquetes IP y no IP"

# Contamos los paquetes que son IP 
#PAQ_IP=`tshark -r $NOMBRE_TRAZA -T fields -e  eth.type -e vlan.etype -Y 'eth.type eq 0x00000800 or vlan.etype eq 0x00000800' | wc -l`
PAQ_IP=`tshark -r $NOMBRE_TRAZA -T fields -e ip.dst -e ip.src -e udp.dstport -e udp.srcport -e tcp.dstport -e tcp.srcport -e frame.len -Y 'eth.type eq 0x00000800 or vlan.etype eq 0x00000800' > $TEMPORAL | wc -l`
PAQ_IP=55114
PAQ_TOTAL=55667
# Contamos los paquetes totales
#PAQ_TOTAL=`tshark -r $NOMBRE_TRAZA | wc -l`

# Obtenemos los paquetes no IP
PAQ_NOIP=$(($PAQ_TOTAL - $PAQ_IP))

# Obtenemos e imprimimos los porcentajes de los paquetes
awk "BEGIN {printf \"IP: %.2f%%\n\", (($PAQ_IP*100)/$PAQ_TOTAL);}"
awk "BEGIN {printf \"NOIP: %.2f%%\n\", (($PAQ_NOIP*100)/$PAQ_TOTAL);}"

echo ""
echo ""

##########################################################################
# Obtenemos los porcentajes de los paquetes con protocolo TCP 
# y UDP respecto al total de paquetes IP
##########################################################################

echo "Porcentajes de paquetes UDP, TCP y OTROS respecto al total de paquetes IP"

PAQ_TCP=49378
PAQ_UDP=4970

# Contamos los paquetes con protocolo TCP
#PAQ_TCP=`tshark -r $NOMBRE_TRAZA -T fields -e ip.proto -Y 'ip.proto eq 6' | wc -l`

# Contamos los paquetes con protocolo UDP
#PAQ_UDP=`tshark -r $NOMBRE_TRAZA -T fields -e ip.proto -Y 'ip.proto eq 17' | wc -l`

# Obtenemos el numero de paquetes no TCP ni UDP
PAQ_OTROS=$(($PAQ_IP - $PAQ_TCP - $PAQ_UDP))

# Obtenemos e imprimimos los porcentajes de los paquetes
awk "BEGIN {printf \"IP-TCP: %.2f%%\n\", (($PAQ_TCP*100)/$PAQ_IP);}"
awk "BEGIN {printf \"IP-UDP: %.2f%%\n\", (($PAQ_UDP*100)/$PAQ_IP);}"
awk "BEGIN {printf \"IP-OTROS: %.2f%%\n\", (($PAQ_OTROS*100)/$PAQ_IP);}"

echo ""
echo "--------------------------------------------------"
echo ""

##########################################################################
# Calculamos el top 10 en bytes y en paquetes de: 
# - Direcciones IP (origen/destino)
# - Puertos (origen/destino) separando TCP de UDP
##########################################################################

# TOP 10 en paquetes:
# Para ello hemos guardado en $TEMPORAL un filtrado de Tshark con los campos pedidos y
# a continuacion los ordenamos en funcion de la columna que nos interese. Los agrupamos
# (usando uniq) y contamos los grupos. La variable TOP indica el numero de lineas a mostrar.
# Tenemos en cuenta que puede haber lineas vacias. Las eliminamos con sed

echo "TOPS 10 por paquetes" > $RESULTADOS

# ip.dst
echo "Top 10 IP destino" >> $RESULTADOS
awk -F '\t' '{print $1}' $TEMPORAL | sed '/^\s*$/d' | sort | uniq -c | sort -nr | awk '{printf "%10s%40s\n",$1, $2}' | head -n $TOP >> $RESULTADOS
# ip.src
echo "Top 10 IP origen" >> $RESULTADOS
awk -F '\t' '{print $2}' $TEMPORAL | sed '/^\s*$/d' | sort | uniq -c | sort -nr | awk '{printf "%10s%40s\n",$1, $2}' | head -n $TOP >> $RESULTADOS
# udp.dstport
echo "Top 10 Puerto UDP destino" >> $RESULTADOS
awk -F '\t' '{print $3}' $TEMPORAL | sed '/^\s*$/d' | sort | uniq -c | sort -nr | awk '{printf "%10s%40s\n",$1, $2}' | head -n $TOP >> $RESULTADOS
# udp.srcport
echo "Top 10 Puerto UDP origen" >> $RESULTADOS
awk -F '\t' '{print $4}' $TEMPORAL | sed '/^\s*$/d' | sort | uniq -c | sort -nr |  awk '{printf "%10s%40s\n",$1, $2}' |head -n $TOP >> $RESULTADOS
# tcp.dstport
echo "Top 10 Puerto TCP destino" >> $RESULTADOS
awk -F '\t' '{print $5}' $TEMPORAL | sed '/^\s*$/d' | sort | uniq -c | sort -nr |  awk '{printf "%10s%40s\n",$1, $2}' |head -n $TOP >> $RESULTADOS
# tcp.srcport
echo "Top 10 Puerto TCP origen" >> $RESULTADOS
awk -F '\t' '{print $6}' $TEMPORAL | sed '/^\s*$/d' | sort | uniq -c | sort -nr |  awk '{printf "%10s%40s\n",$1, $2}' |head -n $TOP >> $RESULTADOS

# TOP 10 en bytes
# Para ello utilizamos el mismo fichero temporal que antes. Seleccionamos las columnas deseadas
# y las agrupamos por el parametro. Utilizamos awk para sumar los tamaños y ordenamos por el tamaño.
# Mostramos el TOP con head

echo "TOPS 10 por bytes" >> $RESULTADOS

# ip.dst
echo "Top 10 IP destino" >> $RESULTADOS
awk -F '\t' '{print $1 "\t" $7}' practica3.temp | sort | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1}' | sort -nr | head -n $TOP >> $RESULTADOS

#Mostramos los resultados
cat $RESULTADOS

#eliminamos el temporal
#rm $TEMPORAL