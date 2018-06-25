import securebox
import user_database
from Crypto.PublicKey import RSA


user = user_database.User('e340546', "Jose Ignacio",
	"nagomez97@gmail.com", None, 0)

key = open("e340546.pem", "r").read()
user.public_key = key

key = open("e340546.bin", "r").read()
user.private_key = key

# #___Test de registerUser___
name, ts = securebox.registerUser(user)
print("\nUsuario registrado con exito: ")
# print("Nombre: " + name)
# print("Timestamp: " + str(ts) + "\n")

# #___Test de getPublicKey___
# key = securebox.getPublicKey(user, user.id)
# if key is None:
# 	print("\nEl usuario no ha sido registrado.\n")
# print("\nClave publica obtenida:\n")
# print(key + "\n")

# #___Test de search_user___
# found = securebox.searchUser('nagomez97@gmail.com', user)
# print("\nUsuarios coincidentes encontrados:\n")
# print(found)
# print("\n")

# #___Test de deleteUser___
# id = securebox.deleteUser(user)
# print("\nID del usuario borrado:\n" + id + "\n")


#___Test de uploadFile___
# file_path = '/home/nacho/Desktop/test.py'
# id = securebox.uploadFile(user, file_path)
# print("\nSe ha enviado el archivo:", id)

#___Test de listFiles___
files, number = securebox.listFile(user)

print('\nArchivos del usuario ' + user.name)
for file in files:
	print(file)

if len(files) == 0:
	print('\nNo hay archivos.\n')

# #___Test de downloadFile___
# file_id = 'dbc3c11e93bf38c7b2477cffd94f2257'
# file = securebox.downloadFile(user, file_id)
# f = open('download.d', 'w')
# f.write(file)
# f.close


# #___Test de deleteFile___
# file_id = files[0]
# id = securebox.deleteFile(user, file_id)

# files, delete_number = securebox.listFile(user)
# if delete_number >= number:
# 	print('\nError borrando archivo.\n')
# else:
# 	print('\nArchivo borrado correctamente.\n')