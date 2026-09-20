---
name: tekartik-app-python-setup
description: >-
  Use when a Dart script drives python through process_run shells with
  tekartik_app_python: pythonEnvInit(paths:) to route the python3, python,
  pip3 and pip commands to a virtualenv, pythonCheckOrInstallPackage to pip
  install a package once, creating a venv with `python3 -m venv`, running
  python with run() from process_run/shell.dart afterwards, and the
  python.dart import.
---

# Python from Dart scripts (tekartik_app_python)

`tekartik_app_python` is a small helper for Dart build and dev scripts that
call python: it points the process_run shell at a virtualenv and installs
missing pip packages. The commands themselves are run with
`package:process_run` (`run`, `Shell`).

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_python:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_python
    process_run: '>=1.2.1'
  ```
  It brings `process_run`, `dev_build`, `path` and `tekartik_common_utils`.
* Imports: `package:tekartik_app_python/python.dart` exports exactly
  `pythonEnvInit` and `pythonCheckOrInstallPackage`. Get `run`, `which`,
  `shellArgument`, `Shell`, `ShellException` and `shellEnvironment` from
  `package:process_run/shell.dart` (`package:dev_build/shell.dart`
  re-exports it), `stdout` from `package:process_run/stdio.dart`.
* `await pythonEnvInit(paths: ['.local/venv'])` once at startup, before any
  python command. The first existing directory of `paths` is taken as a
  virtualenv root: `<venv>/bin/python3` and `<venv>/bin/pip3` become the
  `python3`, `python`, `pip3` and `pip` aliases of the global process_run
  `shellEnvironment`, so every later `run('python3 ...')`,
  `run('pip3 ...')` or `Shell().run(...)` uses the venv. Without `paths`
  (or when none exists) the system python is used. Only the first call has
  an effect; later calls are ignored whatever their `paths`.
* Posix layout only (`bin/python3`): a Windows venv (`Scripts\python.exe`)
  is not detected; there, set the `shellEnvironment` aliases yourself. The
  aliases only affect process_run shells, not `dart:io` `Process.run`, and
  `which('python3')` still reports the system executable.
* Create the venv when missing, before initializing:
  `await run('python3 -m venv ${shellArgument(venvPath)}')` with the system
  python, then `pythonEnvInit(paths: [venvPath])`.
* `await pythonCheckOrInstallPackage('requests')` runs `pip3 list` once per
  process (cached) and `pip3 install <package>` when the package is not
  listed; it prints `Package x already installed` otherwise. Use the name
  as `pip3 list` prints it (case sensitive: `Pillow`, not `pillow`). Call
  it after `pythonEnvInit` so that it targets the venv. A missing `pip3`
  makes `run` throw a `ShellException`.
* Run python with process_run: `await run('python3 script.py arg')` throws
  `ShellException` on a non zero exit and echoes the command and its output
  (`verbose: false` to silence); `(await run('python3 --version',
  verbose: false)).outText` gives the output. Quote paths with
  `shellArgument`.
* Tests: `@TestOn('vm')`, skip when `await which('python3') == null`; keep
  the venv under `.local/` (git ignored).

## Examples

### Setup script: venv, packages, run

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_python/python.dart';

final venvPath = join('.local', 'venv');

Future<void> main() async {
  if (!Directory(venvPath).existsSync()) {
    // The system python creates the venv
    await run('python3 -m venv ${shellArgument(venvPath)}');
  }
  // From now on python3/pip3 are the venv ones (process_run shells only)
  await pythonEnvInit(paths: [venvPath]);
  await pythonCheckOrInstallPackage('requests');
  await pythonCheckOrInstallPackage('Pillow');

  await run('python3 --version');
  await run('python3 ${shellArgument(join('tool', 'convert.py'))} --all');
}
```

### Capture the output and handle a failure

```dart
import 'package:process_run/shell.dart';
import 'package:tekartik_app_python/python.dart';

Future<String?> pythonVersion() async {
  // First existing directory wins, none: system python
  await pythonEnvInit(paths: ['.local/venv', 'venv']);
  try {
    var results = await run('python3 --version', verbose: false);
    return results.outText.trim();
  } on ShellException catch (e) {
    print('python3 not usable: $e');
    return null;
  }
}

Future<void> main() async {
  print(await pythonVersion() ?? 'no python');
}
```

### Test skipped without python

```dart
@TestOn('vm')
library;

import 'package:process_run/shell.dart';
import 'package:tekartik_app_python/python.dart';
import 'package:test/test.dart';

void main() {
  test('python3', () async {
    if (await which('python3') == null) {
      markTestSkipped('python3 not installed');
      return;
    }
    await pythonEnvInit();
    var results = await run('python3 -c "print(1 + 1)"', verbose: false);
    expect(results.outText.trim(), '2');
  });
}
```

## Common mistakes

* Calling `pythonEnvInit` a second time with another venv: only the first
  call counts.
* Running python with `Process.run` from `dart:io` and expecting the venv:
  the aliases live in process_run's `shellEnvironment` only.
* Installing with `pythonCheckOrInstallPackage('pillow')` when `pip3 list`
  prints `Pillow`: the check misses and pip runs at every start.
* Forgetting to create the venv first: `pythonEnvInit` never creates it.
