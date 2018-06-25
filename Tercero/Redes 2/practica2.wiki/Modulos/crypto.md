<h1>Crypto</h1>
Este módulo es el encargado de gestionar nuestro cifrado local. 


A continuación detallamos las funciones implementadas en este módulo:

* **key_generator():** Crea un par de claves RSA de 2048 bits.
* **encrypt_RSA(text, recipient_key):** Cifra un texto con la clave pública del receptor mediante el algoritmo RSA
* **decrypt_RSA(ciphertext, recipient_key):** Desifra un texto con la clave privada del receptor mediante el algoritmo RSA.
* **encrypt_AES(text, key):** Cifra un texto con el algoritmo AES y la clave proporcionada
* **decrypt_AES(packet, key):** Desifra un paquete con el algoritmo AES y la clave proporcionada
* **encrypt_file(msg, pub_recipient_key):** Cifra un mensaje con el algoritmo RSA-AES y la clave pública del receptor proporcionada
* **decrypt_file(received, priv_recipient_key):** Descifra un mensaje con el algoritmo RSA-AES y la clave privada del receptor proporcionada
* **digital_signature(message, my_key):** Firma un mensaje con la clave proporcionada mediante el algoritmo RSA
* **verify_signature(message, sender_key, signature):** Comprueba la firma de un mensaje con la clave del emisor proporcionada. En caso de que sea correcta, devolverá True
* **encrypt_and_sign(message, sender_key, dest_key):** Firma y cifra un mensaje con las claves proporcionadas mediante el algoritmo RSA-AES
* **decrypt_and_check_sign(message, sender_key, dest_key):** Comprueba la firma y descifra un mensaje con las claves proporcionadas mediante el algoritmo RSA-AES

Volver a [Modulos](Modulos).