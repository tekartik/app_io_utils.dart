import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_crypto/encrypt.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

/// Read and write a [SecureEnvKey] (io only).
///
/// The value is encrypted with `encrypt` of `tekartik_app_crypto` (AES with a
/// fixed IV, no integrity check): every value of one password uses the same
/// key stream, a known value reveals the others. Do not rely on it against
/// someone who can read the env file.
extension SecureEnvKeyIo on SecureEnvKey {
  /// The decrypted value of [key] in `ShellEnvironment().vars` (platform
  /// environment, user and local env files).
  ///
  /// Throws when the variable is missing, and in most cases when the password
  /// does not match (nothing checks the value: a wrong password can also give
  /// garbage).
  Future<String> getValue() async {
    // Read from environment variable
    var encryptedValue = ShellEnvironment().vars[key];
    var value = decrypt(encryptedValue!, password);
    return value;
  }

  /// Like [getValue], null when the variable is missing or cannot be
  /// decrypted (the error is written on stderr).
  Future<String?> getValueOrNull() async {
    // Read from environment variable
    var encryptedValue = ShellEnvironment().vars[key];
    if (encryptedValue != null) {
      try {
        var value = decrypt(encryptedValue, password);
        return value;
      } catch (e) {
        stderr.writeln('Error decrypting var \'$key\': $e');
      }
    }
    return null;
  }

  /// Prompts `Enter value` on stdin, then [setValue]. Call
  /// `sharedStdIn.terminate()` afterwards or the program does not exit.
  Future<void> setFromInput() async {
    var value = await prompt('Enter value');
    await setValue(value);
  }

  /// Encrypts [value] and stores it with `ds env var set <key> <encrypted>`:
  /// the local env file `.local/ds_env.yaml` of the current directory. Needs
  /// `ds` (`dart pub global activate process_run`); the command, with the
  /// encrypted value, is printed.
  Future<void> setValue(String value) async {
    var shell = Shell();
    var encryptedValue = encrypt(value, password);

    // Should not ask for password
    await shell.run('ds env var set $key $encryptedValue');
  }
}
