# tekartik_app_python

Helpers for Dart build and dev scripts that call python through
[process_run](https://pub.dev/packages/process_run) shells: point `python3`,
`python`, `pip3` and `pip` at a virtualenv, and pip install a package only
when it is missing.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_python:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_python
```

```dart
import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:tekartik_app_python/python.dart';

Future<void> main() async {
  var venvPath = '.local/venv';
  if (!Directory(venvPath).existsSync()) {
    // The system python creates the venv.
    await run('python3 -m venv ${shellArgument(venvPath)}');
  }
  // From now on python3/pip3 in process_run shells are the venv ones.
  await pythonEnvInit(paths: [venvPath]);
  await pythonCheckOrInstallPackage('requests');
  await run('python3 --version');
}
```

Platforms: Linux and macOS (a posix venv, `<venv>/bin/python3`), with the
Dart VM.

## API

- `pythonEnvInit({paths})`: the first existing directory of `paths` is used
  as the venv: its `bin/python3` and `bin/pip3` become the `python3`,
  `python`, `pip3`, `pip` aliases of the global process_run
  `shellEnvironment`. Only the first call has an effect.
- `pythonCheckOrInstallPackage(name)`: `pip3 list` once per process, then
  `pip3 install name` when `name` is not listed (use the name as `pip3 list`
  prints it).

## Common pitfalls

- The aliases only apply to process_run shells (`run`, `Shell`), not to
  `dart:io` `Process.run`, and `which('python3')` still finds the system
  one.
- Create the venv before `pythonEnvInit`: a later call with the same paths is
  ignored.
- A Windows venv (`Scripts\python.exe`) is not detected.
