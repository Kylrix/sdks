import 'dart:convert';
import 'package:cryptography/cryptography.dart';

/// The Kylrix Security Module (Dart/Flutter version).
/// Standardized for Zero-Knowledge encryption across the ecosystem.
class KylrixSecurity {
  static const int pbkdf2Iterations = 100000;
  static const int keyLength = 32; // 256 bits

  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac(Cryptography.instance.sha256()),
    iterations: pbkdf2Iterations,
    bits: keyLength * 8,
  );

  final _aes = Cryptography.instance.aesGcm();

  /// Derives a cryptographic key from a master password and salt.
  Future<SecretKey> deriveKey(String password, String salt) async {
    return await _pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: utf8.encode(salt),
    );
  }

  /// Encrypts data using AES-GCM.
  Future<Map<String, String>> encrypt(String data, SecretKey key) async {
    final secretBox = await _aes.encrypt(
      utf8.encode(data),
      secretKey: key,
    );

    return {
      'cipher': base64.encode(secretBox.cipherText),
      'iv': base64.encode(secretBox.nonce),
    };
  }

  /// Decrypts a base64 encoded cipher text using AES-GCM.
  Future<String> decrypt(String cipher, String iv, SecretKey key) async {
    final secretBox = SecretBox(
      base64.decode(cipher),
      nonce: base64.decode(iv),
      mac: Mac.empty,
    );

    final clearText = await _aes.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(clearText);
  }
}
