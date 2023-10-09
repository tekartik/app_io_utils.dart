import 'package:process_run/shell.dart';
import 'package:tekartik_app_crypto/encrypt.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

extension SecureEnvKeyIo on SecureEnvKey {
  Future<String> getValue() async {
    // Read from environment variable
    var encryptedValue = ShellEnvironment().vars[key];
    var value = decrypt(encryptedValue!, password);
    return value;
  }

  Future<void> setFromInput() async {
    var value = await prompt('Enter value');
    await setValue(value);
  }

  Future<void> setValue(String value) async {
    var shell = Shell();
    var encryptedValue = encrypt(value, password);

    // Should not ask for password
    await shell.run('ds env var set $key $encryptedValue');
  }
}
