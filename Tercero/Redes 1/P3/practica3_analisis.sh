#! /bin/bash

##########################################################################
# Analizamos los argumentos del script
##########################################################################

# El primer argumento debe ser el nombre de la traza a analizar
NOMBRE_TRAZA=$1

##########################################################################
# Obtenemos los porcentajes de los paquetes de tipo IP, ya sean VLAN o no.
##########################################################################
echo ""
echo "--------------------------------------------------"
echo ""
echo "Porcentajes de paquetes IP y no IP"

# Contamos los paquetes que son IP 
#PAQ_IP=`tshark -r $NOMBRE_TRAZA -T fields -e  eth.type -e vlan.etype -Y 'eth.type eq 0x00000800 or vlan.etype eq 0x00000800' | wc -l`
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
# Calculamos el top 10 en bytes de: 
# - Direcciones IP (origen/destino)
# - Puertos (origen/destino)
##########################################################################