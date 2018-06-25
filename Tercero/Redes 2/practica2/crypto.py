
from Crypto.PublicKey import RSA
from Crypto.Random import get_random_bytes
from Crypto.Cipher import AES, PKCS1_OAEP
from Crypto.Util import Padding
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256


#___Funciones de cifrado asimetrico___

""" key_generator()
Funcion que genera el par de claves RSA
"""
def key_generator():

	# Creamos el par de claves RSA de 2048 bits
	# key sera un objeto RSAkey que contendra las claves
	key = RSA.generate(2048)

	# Obtenemos la clave privada
	""" Argumentos:
	:param format: (default) PEM
	:param passphrase: clave usada para proteger la clave privada
	:param pkcs: tipo de PKCS (usaremos 1)
	:param protection: esquema de cifrado de la clave privada (no usaremos)
	"""
	private_key = key.exportKey(pkcs=1)

	# Obtenemos la clave publica
	public_key = key.publickey().exportKey()

	return private_key, public_key

""" encrypt_RSA()
Funcion para cifrar un texto usando RSA

:param text: texto a cifrar
:param recipient_key: en caso de no haber fichero, usaremos esta clave
"""
def encrypt_RSA(text, recipient_key):

	cipher = PKCS1_OAEP.new(recipient_key)

	encrypted = cipher.encrypt(text)

	return encrypted

""" decrypt_RSA()
Funcion para descifrar un texto usando RSA

:param ciphertext: texto cifrado
:param sender_key: clave para descifrar (o None si no se usa)
"""
def decrypt_RSA(ciphertext, sender_key):

	cipher = PKCS1_OAEP.new(sender_key)

	decrypted = cipher.decrypt(ciphertext)

	return decrypted


#___Funciones de cifrado simetrico (AES)___

""" encrypt_AES()
Funcion para cifrar un texto usando AES
Usaremos claves de 256 bits, encadenamiento CBC y 16 Bytes de IV
	Por convencion, los primeros 16 Bytes del paquete resultante
corresponderan al IV usado en el cifrado

:param text: texto a cifrar
:param key: clave de cifrado (simetrica)
"""
def encrypt_AES(text, key):

	# Generamos un vector de inicializacion aleatorio
	random_iv = get_random_bytes(16)

	# Tenemos que meterle padding al texto para el IV
	padded_text = Padding.pad(text, 16)
	
	# Generamos el objeto clave
	cipher = AES.new(key, AES.MODE_CBC, iv=random_iv)

	# Ciframos el texto
	encrypted= cipher.encrypt(padded_text)

	# Concatenamos el IV al mensaje cifrado
	packet = random_iv + encrypted

	return packet 

""" decrypt_AES()
Funcion para descifrar un texto usando AES
:param ciphertext: texto cifrado
:param key: clave para descifrar
"""
def decrypt_AES(packet, key):

	# Tomamos los 16 primeros bytes, que es el IV
	random_iv = packet[0:16]

	# Tomamos el resto del mensaje
	ciphertext = packet[16:]

	# Generamos el objeto AES con la clave y modo CBC, usando el IV anterior
	cipher = AES.new(key, AES.MODE_CBC, iv=random_iv)

	# Desciframos el texto
	plaintext = cipher.decrypt(ciphertext)

	# Quitamos el padding sobrante
	unpadded = Padding.unpad(plaintext, 16)

	return unpadded

#___Funciones de cifrado de ficheros___

''' encrypt_file()
Funcion para cifrar un archivo
:param file: cadena a cifrar
:param pub_recipient_key: Clave publica del receptor
'''
def encrypt_file(msg, pub_recipient_key):

	# Obtenemos una clave aes aleatoria
	aes_key = get_random_bytes(32)

	# Encriptamos clave simetrica
	enc_aes_key = encrypt_RSA(aes_key, pub_recipient_key)

	#Encriptamos fichero con clave simetrica
	enc_file = encrypt_AES(msg, aes_key)

	sobre = enc_aes_key + enc_file

	return sobre

''' decrypt_file()
Funcion para descifrar un archivo
:param file: cadena cifrada
:param priv_recipient_key: Clave privada del receptor
'''
def decrypt_file(received, priv_recipient_key):

	# Dividimos clave y fichero encriptado
	enc_aes_key = received[0:256]
	enc_file = received[256:]

	# Desencriptamos clave AES
	aes_key = decrypt_RSA(enc_aes_key, priv_recipient_key)
	
	# Desencriptamos fichero con la clave AES
	file = decrypt_AES(enc_file, aes_key)

	return file

#___Funciones de autenticacion (Firma Digital)___

""" digital_signature()
Funcion para firmar digitalmente

:param message: mensaje a firmar
:param my_key: clave del usuario que firma
"""
def digital_signature(message, my_key):

	# Hacemos un resumen hash del mensaje
	hsh = SHA256.new(message)

	# Creamos la firma digital con my_key y el hash del mensaje
	signature = pkcs1_15.new(my_key).sign(hsh)
	
	return signature

""" verifty_signature()
Funcion para verificar una firma digital

:param message: mensaje en plano
:param sender_key: clave del emisor
:param signature: firma digital del mensaje
"""
def verify_signature(message, sender_key, signature):

	# Hash del mensaje
	hsh = SHA256.new(message)

	try:
		# Comparamos el hash del mensaje con el recibido
		pkcs1_15.new(sender_key).verify(hsh, signature)
		return True
	except (ValueError, TypeError):
		return False

""" encrypt_and_sign()
Funcion cifrar y firmar un mensaje

:param message: mensaje en plano
:param sender_key: clave del emisor
:param dest_key: clave del receptor
"""
def encrypt_and_sign(message, sender_key, dest_key):
	
	# Firma del fichero
	signature = digital_signature(message, sender_key)

	# Cifrado del fichero firmado
	# Ya contiene la clave simetrica cifrada
	packet = encrypt_file(signature+message, dest_key)

	return packet

""" decrypt_and_check_sign()
Funcion descifrar y comprobar firma de un mensaje

:param message: mensaje
:param sender_key: clave del emisor
:param dest_key: clave del receptor
"""
def decrypt_and_check_sign(message, sender_key, dest_key):
	
	f = decrypt_file(message, dest_key)

	# Separamos firma del cuerpo del mensaje
	signature = f[:256]
	mes = f[256:]

	return mes, verify_signature(mes, sender_key, signature)