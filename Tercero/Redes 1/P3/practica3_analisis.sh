#! /bin/bash

##########################################################################
# Analizamos los argumentos del script
##########################################################################

# El primer argumento debe ser el nombre de la traza a analizar
NOMBRE_TRAZA=$1
TEMPORAL="practica3.temp"
TEMPORAL1="ECDFtemp.temp"
TEMPORALTCP="tcp.temp"
TEMPORALUDP="udp.temp"
TIME_TEMP="time.temp"
TOTAL="total.temp"
TOP=10
RESULTADOS="practica3.res"
SILENT=0
MAC="00:11:88:cc:33:e5"
IP="119.25.90.131"
UDPPORT="27884"

# Comprobamos que se haya introducido un argumento
if [ "$#" -lt 1 ] ; then 
	echo "Es necesario introducir un parámetro:"
	echo "$0 <Nombre de la traza>"
	echo "Si no se quiere mostrar nada por pantalla:"
	echo "$0 <Nombre de la traza> -s"
	exit
fi

# Comprobamos que ese arguento es un fichero pcap
if [[ $NOMBRE_TRAZA != *.pcap ]] ; then
	echo "El archivo introducido como primer argumento debe ser de tipo pcap:"
	echo "$0 <Nombre de la traza>"
	echo "Si no se quiere mostrar nada por pantalla:"
	echo "$0 <Nombre de la traza> -s"
	exit
fi

if [[ $2 == -s ]] ; then
	SILENT=1
fi

##########################################################################
# Obtenemos los porcentajes de los paquetes de tipo IP, ya sean VLAN o no.
##########################################################################
echo "" > $RESULTADOS
echo "--------------------------------------------------" >> $RESULTADOS
echo "" >> $RESULTADOS
echo "Porcentajes de paquetes IP y no IP" >> $RESULTADOS

# Contamos los paquetes totales
if [[ $SILENT == 0 ]] ; then
	echo "Analizando todos los paquetes"
fi
tshark -r $NOMBRE_TRAZA -T fields -e frame.len > $TOTAL
PAQ_TOTAL=`cat $TOTAL | wc -l`
# Contamos los paquetes que son IP 
if [[ $SILENT == 0 ]] ; then
	echo "Analizando paquetes IP"
fi
tshark -r $NOMBRE_TRAZA -T fields -e ip.dst -e ip.src -e udp.dstport -e udp.srcport -e tcp.dstport -e tcp.srcport -e frame.len -Y 'eth.type eq 0x00000800 or vlan.etype eq 0x00000800' > $TEMPORAL
PAQ_IP=`cat $TEMPORAL | wc -l`

# Obtenemos los paquetes no IP
PAQ_NOIP=$(($PAQ_TOTAL - $PAQ_IP))

# Obtenemos e imprimimos en los resultados los porcentajes de los paquetes
awk "BEGIN {printf \"IP: %.2f%%\n\", (($PAQ_IP*100)/$PAQ_TOTAL);}" >> $RESULTADOS
awk "BEGIN {printf \"NO IP: %.2f%%\n\", (($PAQ_NOIP*100)/$PAQ_TOTAL);}" >> $RESULTADOS

echo "" >> $RESULTADOS
echo "" >> $RESULTADOS

##########################################################################
# Obtenemos los porcentajes de los paquetes con protocolo TCP 
# y UDP respecto al total de paquetes IP
##########################################################################

echo "Porcentajes de paquetes UDP, TCP y OTROS respecto al total de paquetes IP" >> $RESULTADOS

# Contamos los paquetes con protocolo TCP
if [[ $SILENT == 0 ]] ; then
	echo "Analizando paquetes TCP"
fi
tshark -r $NOMBRE_TRAZA -T fields -e tcp.dstport -e tcp.srcport -e frame.len -Y 'tcp' > $TEMPORALTCP
PAQ_TCP=`cat $TEMPORALTCP | wc -l`
# Contamos los paquetes con protocolo UDP
if [[ $SILENT == 0 ]] ; then
	echo "Analizando paquetes UDP"
fi
tshark -r $NOMBRE_TRAZA -T fields -e udp.dstport -e udp.srcport -e frame.len  -Y 'udp' > $TEMPORALUDP
PAQ_UDP=`cat $TEMPORALUDP | wc -l`
# Obtenemos el numero de paquetes no TCP ni UDP
PAQ_OTROS=$(($PAQ_IP - $PAQ_TCP - $PAQ_UDP))

# Obtenemos e imprimimos en los resultados los porcentajes de los paquetes
awk "BEGIN {printf \"IP-TCP: %.2f%%\n\", (($PAQ_TCP*100)/$PAQ_IP);}" >> $RESULTADOS
awk "BEGIN {printf \"IP-UDP: %.2f%%\n\", (($PAQ_UDP*100)/$PAQ_IP);}" >> $RESULTADOS
awk "BEGIN {printf \"IP-OTROS: %.2f%%\n\", (($PAQ_OTROS*100)/$PAQ_IP);}" >> $RESULTADOS

echo "" >> $RESULTADOS
echo "--------------------------------------------------" >> $RESULTADOS
echo "" >> $RESULTADOS

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

echo "TOPS 10 por paquetes" >> $RESULTADOS
echo "" >> $RESULTADOS

# ip.dst
echo "Top 10 IPs destino" >> $RESULTADOS
echo "  pos  paquetes                              ip destino" >> $RESULTADOS
awk -F '\t' '{print $1}' $TEMPORAL | sed '/^\s*$/d' | sort -n | uniq -c | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' | head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# ip.src
echo "Top 10 IPs origen" >> $RESULTADOS
echo "  pos  paquetes                               ip origen" >> $RESULTADOS
awk -F '\t' '{print $2}' $TEMPORAL | sed '/^\s*$/d' | sort -n | uniq -c | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' | head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# udp.dstport
echo "Top 10 Puertos UDP destino" >> $RESULTADOS
echo "  pos  paquetes                      puerto udp destino" >> $RESULTADOS
awk -F '\t' '{print $1}' $TEMPORALUDP | sed '/^\s*$/d' | sort -n | uniq -c | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' | head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# udp.srcport
echo "Top 10 Puertos UDP origen" >> $RESULTADOS
echo "  pos  paquetes                       puerto udp origen" >> $RESULTADOS
awk -F '\t' '{print $2}' $TEMPORALUDP | sed '/^\s*$/d' | sort -n | uniq -c | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# tcp.dstport
echo "Top 10 Puertos TCP destino" >> $RESULTADOS
echo "  pos  paquetes                      puerto tcp destino" >> $RESULTADOS
awk -F '\t' '{print $1}' $TEMPORALTCP | sed '/^\s*$/d' | sort -n | uniq -c | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# tcp.srcport
echo "Top 10 Puertos TCP origen" >> $RESULTADOS
echo "  pos  paquetes                       puerto tcp origen" >> $RESULTADOS
awk -F '\t' '{print $2}' $TEMPORALTCP | sed '/^\s*$/d' | sort -n | uniq -c | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
echo "--------------------------------------------------" >> $RESULTADOS
echo "" >> $RESULTADOS

# TOP 10 en bytes
# Para ello utilizamos el mismo fichero temporal que antes. Seleccionamos las columnas deseadas
# y las agrupamos por el parametro. Utilizamos awk para sumar los tamaños y ordenamos por el tamaño.
# Mostramos el TOP con head

echo "TOPS 10 por bytes" >> $RESULTADOS
echo "" >> $RESULTADOS
# ip.dst
echo "Top 10 IPs destino" >> $RESULTADOS
echo "  pos    tamaño                              ip destino" >> $RESULTADOS
awk -F '\t' '{print $1 "\t" $7}' $TEMPORAL | sort -n | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1} END{printf "%10s%40s\n", s, p}' | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# ip.src
echo "Top 10 IPs origen" >> $RESULTADOS
echo "  pos    tamaño                               ip origen" >> $RESULTADOS
awk -F '\t' '{print $2 "\t" $7}' $TEMPORAL | sort -n | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1} END{printf "%10s%40s\n", s, p}' | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# udp.dst
echo "Top 10 Puertos UDP destino" >> $RESULTADOS
echo "  pos    tamaño                      puerto udp destino" >> $RESULTADOS
awk -F '\t' '{print $1 "\t" $3}' $TEMPORALUDP | sort -n | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1} END{printf "%10s%40s\n", s, p}' | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# udp.src
echo "Top 10 Puertos UDP origen" >> $RESULTADOS
echo "  pos    tamaño                       puerto udp origen" >> $RESULTADOS
awk -F '\t' '{print $2 "\t" $3}' $TEMPORALUDP | sort -n | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1} END{printf "%10s%40s\n", s, p}' | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# tcp.dst
echo "Top 10 Puertos TCP destino" >> $RESULTADOS
echo "  pos    tamaño                      puerto tcp destino" >> $RESULTADOS
awk -F '\t' '{print $1 "\t" $3}' $TEMPORALTCP | sort -n | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1} END{printf "%10s%40s\n", s, p}' | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
# tcp.src
echo "Top 10 Puertos TCP origen" >> $RESULTADOS
echo "  pos    tamaño                       puerto tcp origen" >> $RESULTADOS
awk -F '\t' '{print $2 "\t" $3}' $TEMPORALTCP | sort -n | awk 'NR>1 && p!=$1 {printf "%10s%40s\n", s, p; s=0} {s+=$2} {p=$1} END{printf "%10s%40s\n", s, p}' | sort -nr | awk 'BEGIN{n=0}{printf "%5s%10s%40s\n", n+=1, $1, $2}' |head -n $TOP >> $RESULTADOS
echo "" >> $RESULTADOS
echo "--------------------------------------------------" >> $RESULTADOS
echo "" >> $RESULTADOS

##########################################################################
# Realizamos las ECDF de la traza
# - Tamaños a nivel 2
# - Tamaños a nivel 3 de los paquetes HTTP
# - Tamaños a nivel 3 de los paquetes DNS
# - Tiempos de llegada de los TCP
# - Tiempos de llegada de los UDP
##########################################################################

if [[ $SILENT == 0 ]] ; then
	echo "Realizando graficas"
	echo "Realizando ECDF de tamaños a nivel 2"
fi

# Graficas de tamaño de paquetes a nivel 2

# Obtenemos el tamaño de los paquetes que utilizan nuestra MAC
tshark -r $NOMBRE_TRAZA -T fields -e frame.len -e eth.src -e eth.dst -Y "eth.addr==$MAC" > $TEMPORAL

# ECDF del tamaño de los paquetes de nivel 2 con origen en nuestra MAC
awk -v mac=$MAC '$2 == mac {print $1}' $TEMPORAL > $TEMPORAL1
./hacer_ECDF.sh $TEMPORAL1 "Tam eth salida" "Tamanio (bytes)" "Frecuencia"

# ECDF del tamaño de los paquetes de nivel 2 con destino en nuestra MAC
awk -v mac=$MAC '$3 == mac {print $1}' $TEMPORAL > $TEMPORAL1
./hacer_ECDF.sh $TEMPORAL1 "Tam eth entrantes" "Tamanio (bytes)" "Frecuencia"

# Graficas de tamaño de HTTP y DNS

if [[ $SILENT == 0 ]] ; then
	echo "Realizando ECDF de tamaños HTTP"
fi

# Obtenemos un archivo con todos los paquetes TCP
tshark -r $NOMBRE_TRAZA -T fields -e frame.len -e tcp.srcport -e tcp.dstport > $TEMPORAL

# Paquetes HTTP: vamos a filtrar el archivo temporal en busca de
# paquetes con origen/destino en el puerto 80 TCP

# ECDF del tamanio de los paquetes HTTP de nivel 3 con origen en el puerto 80
awk -v port=80 '$2 == port {print $1}' $TEMPORAL > $TEMPORAL1
./hacer_ECDF.sh $TEMPORAL1 "Tam HTTP src 80" "Tamanio (bytes)" "Frecuencia"

# ECDF del tamanio de los paquetes HTTP de nivel 3 con destino en el puerto 80
awk -v port=80 '$3 == port {print $1}' $TEMPORAL > $TEMPORAL1
./hacer_ECDF.sh $TEMPORAL1 "Tam HTTP dst 80" "Tamanio (bytes)" "Frecuencia"

# Obtenemos un archivo con todos los paquetes UDP
tshark -r $NOMBRE_TRAZA -T fields -e frame.len -e udp.srcport -e udp.dstport > $TEMPORAL

if [[ $SILENT == 0 ]] ; then
	echo "Realizando ECDF de tamaños DNS"
fi

# Paquetes DNS: vamos a filtrar el archivo temporal en busca de
# paquetes con origen/destino en el puerto 53 UDP

# ECDF del tamanio de los paquetes DNS de nivel 3 con origen en el puerto 53
awk -v port=53 '$2 == port {print $1}' $TEMPORAL > $TEMPORAL1
./hacer_ECDF.sh $TEMPORAL1 "Tam DNS src 53" "Tamanio (bytes)" "Frecuencia"

# ECDF del tamanio de los paquetes DNS de nivel 3 con origen en el puerto 53
awk -v port=53 '$3 == port {print $1}' $TEMPORAL > $TEMPORAL1
./hacer_ECDF.sh $TEMPORAL1 "Tam DNS dst 53" "Tamanio (bytes)" "Frecuencia"

if [[ $SILENT == 0 ]] ; then
	echo "Realizando ECDF de tiempos TCP"
fi

# Obtenemos archivo con los tiempos de los paquetes TCP, con las columnas de las ip destino y origen
tshark -r $NOMBRE_TRAZA -T fields -e frame.time_relative -e ip.src -e ip.dst -Y 'tcp' > $TEMPORAL

# Filtramos el anterior archivo buscando sólo las que tengan nuestra IP como origen
awk -v ip=$IP '$2 == ip {print $1 "\t" $2 "\t" $3}' $TEMPORAL > $TEMPORAL1

# Calculamos el tiempo entre paquetes
awk 'BEGIN{antigua = $1} {delta = $1-antigua; printf("%.7f\n", delta); antigua = $1 }' $TEMPORAL1 > $TIME_TEMP
./hacer_ECDF_tcp.sh $TIME_TEMP "Delta Time TCP salida" "Tiempo (s)" "Frecuencia"

# Filtramos el anterior archivo buscando sólo las que tengan nuestra IP como destino
awk -v ip=$IP '$3 == ip {print $1 "\t" $2 "\t" $3}' $TEMPORAL > $TEMPORAL1

# Calculamos el tiempo entre paquetes
awk 'BEGIN{antigua = $1} {delta = $1-antigua; printf("%.7f\n", delta); antigua = $1 }' $TEMPORAL1 > $TIME_TEMP
./hacer_ECDF_tcp.sh $TIME_TEMP "Delta Time TCP llegada" "Tiempo (s)" "Frecuencia"

if [[ $SILENT == 0 ]] ; then
	echo "Realizando ECDF de tiempos UDP"
fi

# Obtenemos archivo con los tiempo de los paquetes UDP, con las columnas de las ip destino y origen
tshark -r $NOMBRE_TRAZA -T fields -e frame.time_relative -e udp.srcport -e udp.dstport -Y 'udp.port == 27884' > $TEMPORAL

# Filtramos el anterior archivo buscando sólo las que tengan nuestro puerto UDP como origen
awk '$2 == 27884 {print $1 "\t" $2 "\t" $3}' $TEMPORAL > $TEMPORAL1

# Calculamos el tiempo entre paquetes y hacemos la grafica
awk 'BEGIN{antigua = $1} {delta = $1-antigua; printf("%.7f\n", delta); antigua = $1 }' $TEMPORAL1 > $TIME_TEMP
./hacer_ECDF_udp.sh $TIME_TEMP "Delta Time UDP salida" "Tiempo (s)" "Frecuencia"

# Filtramos el anterior archivo buscando sólo las que tengan nuestro puerto UDP como destino
awk '$3 == 27884 {print $1 "\t" $2 "\t" $3}' $TEMPORAL > $TEMPORAL1

# Calculamos el tiempo entre paquetes
awk 'BEGIN{antigua = $1} {delta = $1-antigua; printf("%.7f\n", delta); antigua = $1 }' $TEMPORAL1 > $TIME_TEMP
./hacer_ECDF_udp.sh $TIME_TEMP "Delta Time UDP llegada" "Tiempo (s)" "Frecuencia"

##########################################################################
# Calculamos el ancho de banda a nivel 2 en b/s
##########################################################################

if [[ $SILENT == 0 ]] ; then
	echo "Realizando gráficas de anchos de banda"
fi

# Obtenemos los paquetes con nuestra dirección ethernet
tshark -r $NOMBRE_TRAZA -T fields -e frame.len -e frame.time_relative -e eth.src -e eth.dst -Y "eth.addr==$MAC" > $TEMPORAL

# Truncamos el frame.time_relative a segundos y filtramos nuestra MAC como origen
awk -v mac=$MAC '$3 == mac {printf "%d\t%s\n", $2, $1*8}' $TEMPORAL > $TEMPORAL1
./hacer_grafica_tasa.sh $TEMPORAL1 "Tasa de salida" "Tiempo (s)" "Bits/s"

# Truncamos el frame.time_relative a segundos y filtramos nuestra MAC como destino
awk -v mac=$MAC '$4 == mac {printf "%d\t%s\n", $2, $1*8}' $TEMPORAL > $TEMPORAL1
./hacer_grafica_tasa.sh $TEMPORAL1 "Tasa de llegada" "Tiempo (s)" "Bits/s"

#Mostramos los resultados
if [[ $SILENT == 0 ]] ; then
	echo ""
	echo "RESULTADOS:"
	cat $RESULTADOS
fi

#eliminamos el temporal
rm $TEMPORAL $TOTAL $TEMPORAL1 $TIME_TEMP $TEMPORALTCP $TEMPORALUDP