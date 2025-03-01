import base64
import hashlib
import os
from sys import argv

# As per https://github.com/qbittorrent/qBittorrent/blob/ce9bdaef5cdb8ab77d71481f20b25c9e6da1b9eb/src/base/utils/password.cpp#L48
ITERATIONS = 100_000

# 4x32 bits words = 16 bytes: https://github.com/qbittorrent/qBittorrent/blob/ce9bdaef5cdb8ab77d71481f20b25c9e6da1b9eb/src/base/utils/password.cpp#L75
SALT_SIZE = 16

# Prompt user for password
password = argv[1]

# Generate a cryptographically secure pseudorandom salt
salt = os.urandom(SALT_SIZE)

# PBKDF2 w/ SHA512 hmac
h = hashlib.pbkdf2_hmac("sha512", password.encode(), salt, ITERATIONS)

# Base64 encode and join salt and hash
# print(f"Hash: {base64.b64encode(salt).decode()}:{base64.b64encode(h).decode()}")
print("{\"hash\": " + f"\"{base64.b64encode(salt).decode()}:{base64.b64encode(h).decode()}\"" + "}")