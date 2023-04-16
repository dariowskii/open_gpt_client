import 'package:flutter_test/flutter_test.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

void main() {
  test('password generator correct length', () {
    const configuration = PasswordGeneratorConfiguration(
      length: 32,
    );
    final generator = PasswordGenerator.fromConfig(configuration: configuration);
    const numOfGeneratedPasswords = 100000;
    for (var i = 0; i < numOfGeneratedPasswords; i++) {
      final password = generator.generate();
      expect(password.length, 32);
    }
  });
}
