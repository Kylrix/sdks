package kylrix

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"io"

	"golang.org/x/crypto/pbkdf2"
)

// KylrixSecurity implements Zero-Knowledge AES-256-GCM encryption/decryption.
// Standardized across TS/Dart/Python implementations.
type KylrixSecurity struct{}

const (
	PBKDF2Iterations = 100000
	KeySize          = 32 // 256 bits
)

// DeriveKey derives a cryptographic key from a master password and salt.
func (s *KylrixSecurity) DeriveKey(password string, salt string) []byte {
	return pbkdf2.Key([]byte(password), []byte(salt), PBKDF2Iterations, KeySize, sha256.New)
}

// EncryptResult holds the result of an encryption operation
type EncryptResult struct {
	Cipher string `json:"cipher"`
	IV     string `json:"iv"`
}

// Encrypt encrypts data using AES-GCM.
func (s *KylrixSecurity) Encrypt(data string, key []byte) (*EncryptResult, error) {
	block, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}

	nonce := make([]byte, 12)
	if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, err
	}

	aesgcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	ciphertext := aesgcm.Seal(nil, nonce, []byte(data), nil)

	return &EncryptResult{
		Cipher: base64.StdEncoding.EncodeToString(ciphertext),
		IV:     base64.StdEncoding.EncodeToString(nonce),
	}, nil
}

// Decrypt decrypts a base64 encoded cipher text using AES-GCM.
func (s *KylrixSecurity) Decrypt(cipherStr string, ivStr string, key []byte) (string, error) {
	ciphertext, err := base64.StdEncoding.DecodeString(cipherStr)
	if err != nil {
		return "", err
	}

	nonce, err := base64.StdEncoding.DecodeString(ivStr)
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	aesgcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	plaintext, err := aesgcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return "", err
	}

	return string(plaintext), nil
}
