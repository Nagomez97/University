import crypto
from Crypto.Random import get_random_bytes
import sys
from Crypto.Util import Padding
from Crypto.PublicKey import RSA
from Crypto.Random import get_random_bytes
from Crypto.Cipher import AES, PKCS1_OAEP
from Crypto.Util import Padding
from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256

key = get_random_bytes(32)
text = "Este es mi texto secreto"
text1 = "Mensaje de error"

#___Test de AES___

encrypted =  crypto.encrypt_AES(text, key)

decrypted = crypto.decrypt_AES(encrypted, key)

if text == decrypted:
	print("Cifrado AES exitoso\n")
else:
	print("Cifrado AES fallido\n")


#___Test de RSA___
prvkey, pbckey = crypto.key_generator('e340546')

private_key = RSA.import_key(prvkey)
public_key = RSA.import_key(pbckey)

encrypted = crypto.encrypt_RSA(text, public_key)

decrypted = crypto.decrypt_RSA(encrypted, private_key)

if text == decrypted:
	print("Cifrado RSA exitoso\n")
else:
	print("Cifrado RSA fallido\n")

# Test de cifrado de fichero

f = 'ideas'
file = open(f, 'r')
content = file.read()
file.close()

encrypted = crypto.encrypt_file(f, public_key)
decrypted = crypto.decrypt_file(encrypted, private_key)

if content == decrypted:
	print("Cifrado fichero exitoso\n")
else:
	print("Cifrado fichero fallido\n")


# Test de firma digital

signature = crypto.digital_signature(text, private_key)

if crypto.verify_signature(text, public_key, signature):
	print("Firma digital verificada\n")
else:
	print("Firma digital rechazada\n")

