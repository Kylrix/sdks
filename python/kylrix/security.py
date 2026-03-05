import base64
import os
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives.ciphers.aead import AESGCM


class KylrixSecurity:
    """
    Ecosystem-wide Security Primitives for Python.
    Implements Zero-Knowledge AES-256-GCM encryption/decryption.
    Standardized with TypeScript/Dart/Go implementations.
    """

    ITERATIONS = 100000
    KEY_SIZE = 32  # 256 bits

    @staticmethod
    def derive_key(password: str, salt: str) -> bytes:
        """Derives a cryptographic key from a master password and salt."""
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=KylrixSecurity.KEY_SIZE,
            salt=salt.encode(),
            iterations=KylrixSecurity.ITERATIONS,
        )
        return kdf.derive(password.encode())

    @staticmethod
    def encrypt(data: str, key: bytes) -> dict:
        """Encrypted data using AES-GCM."""
        aesgcm = AESGCM(key)
        nonce = os.urandom(12)
        ciphertext = aesgcm.encrypt(nonce, data.encode(), None)

        return {
            "cipher": base64.b64encode(ciphertext).decode("utf-8"),
            "iv": base64.b64encode(nonce).decode("utf-8"),
        }

    @staticmethod
    def decrypt(cipher: str, iv: str, key: bytes) -> str:
        """Decrypts a base64 encoded cipher text using AES-GCM."""
        aesgcm = AESGCM(key)
        nonce = base64.b64decode(iv)
        ciphertext = base64.b64decode(cipher)

        plaintext = aesgcm.decrypt(nonce, ciphertext, None)
        return plaintext.decode("utf-8")
