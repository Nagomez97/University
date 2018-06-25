# Conclusiones
Esta práctica ha sido especialmente interesante. Hemos podido trabajar con contenido multimedia en tiempo real, creando una aplicación que, disponiendo de más tiempo para mejorarla, podría convertirse en un pariente de grandes sistemas como Skype. 

Además, hemos gozado de cierta libertad a la hora de implementarla, lo que nos ha ocasionado algunos problemas de implementación a los que nos habríamos tenido que enfrentar en la vida real, por lo que ha sido especialmente enriquecedora.

Sin embargo, debido a estos mismos problemas de implementación, no hemos sido capaces de elaborar una aplicación tan sofisticada como nos hubiese gustado. A continuación hablaremos de los problemas encontrados y los aspectos a mejorar.

## Problemas de implementación
Durante el desarrollo de esta práctica nos hemos encontrado algunas dificultades, que finalmente hemos conseguido solucionar:
* Empezamos desarrollando en **python 2.7** por problemas de compatibilidad de librerías, pero finalmente decidimos cambiar a **python 3**. Este cambio supuso cambios en la codificación de los mensajes (en **python 2.7** no es necesario codificar antes de enviar a través del socket) que nos llevaron a replantear el formato de nuestros paquetes.
* Al enviar video desde un fichero, no podíamos pausarlo. Para solucionarlo decidimos que el video no se pausaría, sino que continuaría la reproducción, pero no se enviarían los frames. De este modo, al reanudar, el usuario apreciaría un salto temporal en el contenido. Sin embargo, al no tratarse de un cliente de streaming de video, sino de videollamadas, podemos asumir que esta política es adecuada.
* Cuando finalizaba la reproducción de un video emitido desde fichero, saltaban errores de frames vacíos (no había más video que enviar). Por ello decidimos emitir el vídeo en bucle, reiniciándolo cuando terminase su reproducción.

## Aspectos a mejorar
Debido al tiempo dedicado a subsanar los errores anteriores, y a conseguir un correcto funcionamiento de la aplicación, ha habido ciertos aspectos que no hemos podido implementar:
* No contamos con un sistema de control de calidad de la llamada basado en la congestión de la red. Tanto emisor como receptor conocen los FPS a los que están emitiendo y recibiendo video, y no sería muy complicado implementar un sistema de control basado en esta información, pero tras varios intentos hemos decidido dejarlo como está al no obtener resultados satisfactorios.