verificaPassword = [98, 130, 162, 195, 64, 7, 134, 166, 73, 104, 0, 161, 193, 226, 162, 132, 226, 130, 131, 73, 162, 192]
bruteforce = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\{\}._-'
user=[]

for j in verificaPassword:
    for i in bruteforce:
        if (j == (((ord(i) << 5) | (ord(i) >> 3)) ^ 111) & 255):
            user.append(i)

print(user)
