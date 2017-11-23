#!/bin/bash

# inicializar variables
tempError=errores.dat
tempTime=tiempos.dat
tempTimeOr=tiemposOr.dat
tempErrorOr=erroresOr.dat
final=mult.dat
Iterations=10

rm -f $tempTimeOr $tempErrorOr $final

# Obtenemos las medias de los tiempos
echo "Ordenando tiempos"
awk -v I=$Iterations '{media_mult[$1] = media_mult[$1] + $2; media_tran[$1] = media_tran[$1] + $3} END{for(j in media_mult) print j"	"media_mult[j]/I"	"media_tran[j]/I}' $tempTime | sort > $tempTimeOr

echo "Ordenando errores"
awk -v I=$Iterations ' \
	{D1mr_mult[$1] = D1mr_mult[$1] + $2; D1mw_mult[$1] = D1mw_mult[$1] + $3; D1mr_tran[$1] = D1mr_tran[$1] + $4; D1mw_tran[$1] = D1mw_tran[$1] + $5} \
	END{for(j in D1mr_mult) print j"	"D1mr_mult[j]/I"	"D1mw_mult[j]/I"	"D1mr_tran[j]/I"	"D1mw_tran[j]/I}' $tempError | sort > $tempErrorOr

echo "Joining"
join -j 1 -o 1.1,1.2,2.2,2.3,1.3,2.4,2.5 $tempTimeOr $tempErrorOr > $final

