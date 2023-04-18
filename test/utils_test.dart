import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

void main() {
  test('password generator correct length in utf8', () {
    const configuration = PasswordGeneratorConfiguration(
      length: 32,
    );
    final generator =
        PasswordGenerator.fromConfig(configuration: configuration);
    const numOfGeneratedPasswords = 100;
    for (var i = 0; i < numOfGeneratedPasswords; i++) {
      var password = '';
      while (utf8.encode(password).length != 32) {
        password = generator.generate();
      }
      expect(utf8.encode(password).length, 32);
      final encrypter = Encrypter(
        AES(
          Key.fromUtf8(password),
        ),
      );
      final iv = IV.fromLength(16);
      final encrypted = encrypter.encrypt('test', iv: iv);
      expect(encrypted.base64.isNotEmpty, true);
    }
  });
}
