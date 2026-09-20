---
name: tekartik-app-secure-env-setup
description: >-
  Use when a Dart io tool or script must keep a secret (password, token, api
  key) encrypted in the process_run shell environment with
  tekartik_app_secure_env: SecureEnvKey(key:, password:), the SecureEnvKeyIo
  extension methods getValue, getValueOrNull, setValue and setFromInput, AES
  encryption from tekartik_app_crypto (16, 24 or 32 character password), the
  `ds env var set` command (dart pub global activate process_run),
  ShellEnvironment().vars, the .local/ds_env.yaml file and the
  secure_env.dart import.
---

# Encrypted secrets in the shell environment (tekartik_app_secure_env)

`tekartik_app_secure_env` stores a value AES-encrypted (tekartik_app_crypto)
in a process_run environment variable, written with the `ds env var set`
command, and reads it back through `ShellEnvironment().vars`. A dev script
or CLI can thus keep a credential out of its source and out of the plain
environment.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_secure_env:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_secure_env
      version: '>=0.1.0'
  ```
  It brings `process_run` and `tekartik_app_crypto` (repo
  `https://github.com/tekartik/app_common_utils.dart`, path `app_crypto`);
  declare them yourself when you import their libraries. The machine also
  needs the `ds` command: `dart pub global activate process_run` (with
  `~/.pub-cache/bin` on the PATH).
* Import `package:tekartik_app_secure_env/secure_env.dart`: `SecureEnvKey`
  and the `SecureEnvKeyIo` extension (io only: stdin, shell, environment).
* `SecureEnvKey(key: 'MY_TOOL_API_KEY', password: <16, 24 or 32 ascii
  chars>)`: `key` is the environment variable name holding the encrypted
  text (one per secret; letters, digits and underscores), `password` is the
  AES key used by `encrypt`/`decrypt` (any other length throws). Define the
  key once, in a library shared by the script that sets it and the code
  that reads it. The password lives in your source: it hides the value from
  a casual look at env files, it does not protect against someone holding
  both the file and the code.
* Write: `await key.setValue(value)` encrypts (`encrypt(value, password)`,
  base64 output) and runs `ds env var set <key> <encrypted>` in a
  `Shell()`. By default `ds env var set` writes the **local** process_run
  env file `.local/ds_env.yaml` of the current directory (git ignore
  `.local/`), so the readers must run from that same directory. For a user
  wide value run `ds env var set --user <key> <encrypted>` yourself (file
  `~/.config/tekartik/process_run/env.yaml`), computing `<encrypted>` with
  `encrypt` from `package:tekartik_app_crypto/encrypt.dart`.
  `await key.setFromInput()` prompts `Enter value` on stdin (`prompt` from
  process_run) then calls `setValue`; afterwards call
  `await sharedStdIn.terminate()` (`package:process_run/shell.dart`) or the
  program will not exit.
* Read: `await key.getValue()` takes `ShellEnvironment().vars[key]` (the
  platform environment merged with the user and local env files) and
  decrypts it; it throws when the variable is missing (null check) or when
  the password does not match. `await key.getValueOrNull()` returns null in
  both cases (decryption errors are written on stderr). Both are async
  although they do no io.
* Because the platform environment is included, a CI job can provide the
  encrypted text as a regular environment variable (a secret) under the
  same name: no `ds` needed at read time.
* Tests: `@TestOn('vm')`. The package test does `setValue('123')` then
  `getValue()` and checks the stored base64 text; it leaves a
  `.local/ds_env.yaml` in the test working directory, so use a dedicated
  test key name.

## Examples

### One script: set from the keyboard, or read

```dart
import 'package:process_run/shell.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

/// Shared definition: the env var name and the 32 char AES password.
final apiKey = SecureEnvKey(
  key: 'MY_TOOL_API_KEY',
  password: 'x9cQYGAw8YVnhJyNmjc6cmq29XGnZgvD',
);

/// dart run tool/api_key.dart set   (prompts, writes .local/ds_env.yaml)
/// dart run tool/api_key.dart       (reads it back)
Future<void> main(List<String> args) async {
  if (args.firstOrNull == 'set') {
    await apiKey.setFromInput();
    await sharedStdIn.terminate();
    return;
  }
  var value = await apiKey.getValueOrNull();
  if (value == null) {
    stderr.writeln('API key not set, run: dart run tool/api_key.dart set');
    exit(1);
  }
  stdout.writeln('API key: ${'*' * value.length}');
}
```

### Non-interactive set from an argument

```dart
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

final dbPassword = SecureEnvKey(
  key: 'MY_TOOL_DB_PASSWORD',
  password: '0123456789abcdef', // 16 chars
);

/// dart run tool/db_password_set.dart <password>
Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('usage: db_password_set <password>');
    exit(64);
  }
  await dbPassword.setValue(args.first);
  // Round trip check
  stdout.writeln('stored: ${await dbPassword.getValue() == args.first}');
}
```

### Tool asking once, then reusing the stored secret

```dart
import 'package:process_run/shell.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

final apiKey = SecureEnvKey(
  key: 'MY_TOOL_API_KEY',
  password: 'x9cQYGAw8YVnhJyNmjc6cmq29XGnZgvD',
);

Future<String> requireApiKey() async {
  var value = await apiKey.getValueOrNull();
  if (value == null) {
    // First run: ask once and store it encrypted for the next runs
    value = await prompt('API key');
    await apiKey.setValue(value);
    await sharedStdIn.terminate();
  }
  return value;
}

Future<void> main() async {
  var key = await requireApiKey();
  print('using an API key of ${key.length} chars');
}
```

### Encrypted text for a CI secret

```dart
import 'package:tekartik_app_crypto/encrypt.dart';
import 'package:tekartik_app_secure_env/secure_env.dart';

final apiKey = SecureEnvKey(
  key: 'MY_TOOL_API_KEY',
  password: 'x9cQYGAw8YVnhJyNmjc6cmq29XGnZgvD',
);

/// dart run tool/api_key_encrypt.dart <value>
/// Prints what to store in the CI secret named MY_TOOL_API_KEY.
void main(List<String> args) {
  print(encrypt(args.first, apiKey.password));
}
```

## Common mistakes

* A password that is not 16, 24 or 32 ascii characters: `encrypt` and
  `decrypt` throw.
* `ds` not installed or not on the PATH: `setValue` fails in `Shell.run`.
* Setting the value from one directory and reading it from another: the
  default store is the local `.local/ds_env.yaml`.
* Forgetting `sharedStdIn.terminate()` after `setFromInput()` or `prompt`:
  the process hangs on stdin.
* Committing `.local/ds_env.yaml`.
