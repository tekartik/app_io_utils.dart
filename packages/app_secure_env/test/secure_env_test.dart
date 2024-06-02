@TestOn('vm')
library;

import 'package:process_run/shell.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';
import 'package:test/test.dart';

final secureEnvKey = SecureEnvKey(
    key: 'maSLWhDzFQg0dhIXKxev', password: 'x9cQYGAw8YVnhJyNmjc6cmq29XGnZgvD');
void main() {
  test('set/get', () async {
    await secureEnvKey.setValue('123');
    expect(
        ShellEnvironment().vars[secureEnvKey.key], 'XQpWzENKt8PCHRRgktowUA==');
    expect(await secureEnvKey.getValue(), '123');
  });
}
