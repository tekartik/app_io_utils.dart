# tekartik_app_secure_env

Keep a value (token, password) encrypted in the
[process_run](https://pub.dev/packages/process_run) environment of a `dart:io`
tool: `setValue` encrypts it and stores it with `ds env var set`, `getValue`
reads it back from `ShellEnvironment().vars` and decrypts it.

It only hides the value from a casual look at the env file: the password is
in your source code, and the encryption (`encrypt` of `tekartik_app_crypto`,
AES with a fixed IV and no integrity check) is weak. Do not use it to protect
a secret from someone who can read both your code and the env file.

## Getting started

The package is not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_secure_env:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_secure_env
    version: '>=0.1.0'
```

`setValue` runs the `ds` command of process_run:
`dart pub global activate process_run` (with `~/.pub-cache/bin` on the PATH).

```dart
import 'package:process_run/shell.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

/// The env variable name and the AES password (16, 24 or 32 ascii chars).
final apiKey = SecureEnvKey(
  key: 'MY_TOOL_API_KEY',
  password: 'replace-with-your-own-32-chars!!',
);

Future<void> main(List<String> args) async {
  if (args.firstOrNull == 'set') {
    // Prompts on stdin, writes .local/ds_env.yaml of the current directory
    await apiKey.setFromInput();
    await sharedStdIn.terminate();
    return;
  }
  var value = await apiKey.getValueOrNull();
  print(value == null ? 'not set' : 'set (${value.length} chars)');
}
```

Platforms: `dart:io` only (Dart VM, desktop), not the web.

## Common pitfalls

* `ds env var set` writes the **local** env file `.local/ds_env.yaml` of the
  current directory: git ignore `.local/`, and read the value from that same
  directory.
* `setValue` prints the `ds env var set` command (the encrypted value) on the
  console: avoid it in a CI log.
* `getValue` throws when the variable is missing or the password does not
  match; `getValueOrNull` returns null (and writes the error on stderr).
* Never print the decrypted value (examples print its length).
* A CI job can give the encrypted text as a regular environment variable of
  the same name: `ShellEnvironment().vars` includes the platform environment.

The [package skill](skills/tekartik-app-secure-env-setup/SKILL.md) has more
examples.
