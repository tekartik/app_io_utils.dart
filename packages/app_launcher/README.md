# tekartik_app_io_launcher

Open desktop applications from a Dart program (a dev tool, a build menu, a
CLI): the default browser, Chrome, Firefox, a text editor, the file manager,
a terminal or IntelliJ IDEA. Every launcher returns a `Future<bool>`: `true`
when a command was started, `false` when nothing suitable was found or the
command failed (no exception).

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_io_launcher:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_launcher
```

```dart
import 'dart:io';

import 'package:tekartik_app_io_launcher/launcher.dart';

Future<void> main() async {
  var url = Uri.parse('https://dart.dev');
  if (!await launchBrowser(url)) {
    // Nothing opened: show the url instead.
    stdout.writeln('Open $url');
  }
  await launchFileExplorer(Directory.current.path);
  await launchTerminal(
    options: LaunchTerminalOptions(directoryPath: Directory.current.path),
  );
}
```

Platforms: Linux, macOS and Windows (Dart VM, Flutter desktop). On Android
and iOS they find no command and return `false`; on the web (the library
imports everywhere) they throw `UnimplementedError`.

## Launchers

| Function | Opens | With |
|---|---|---|
| `launchBrowser(uri)`, `launchDefaultViewer(uri)` | the default app for the uri | `xdg-open`, `open`, `explorer`; Chrome as the fallback |
| `launchDefaultViewerPath(path)`, `launchImageViewer(path)` | a file in its default app | same, after converting the path to a `file:` uri |
| `launchChrome(uri)`, `launchFirefox(uri)` | that browser | `google-chrome`/`firefox`, `open -a`, `start` |
| `launchTextEdit(path)` | a text editor (creates the file unless `doNotCreate: true`) | `gedit` (Linux), `notepad`, `open -a TextEdit`; `false` when none |
| `launchFileExplorer(path)` | the file manager on a folder or file | `xdg-open` or a known file manager, `open`, `explorer` |
| `launchTerminal(options:)` | a new terminal window in a directory | `xdg-terminal-exec`, `x-terminal-emulator`, gnome-terminal..., Terminal.app, `wt`/`cmd` |
| `launchIdea(args:)` | IntelliJ IDEA on the given paths | `idea` (Toolbox or tarball launcher), `open -na "IntelliJ IDEA.app"`, `idea64.exe` |

`verbose: true` prints the command run.

## Common pitfalls

- `launchFileExplorer` and `launchTerminal` start a detached process and
  return at once. The others wait for the command: when Chrome, Firefox,
  gedit or IDEA is not running yet, the started process is the app itself
  and the call only completes when its window is closed. Do not await them
  in a loop that must go on (or call them without `await`).
- The uri functions take a `Uri`: use `launchDefaultViewerPath` (or
  `Uri.file(path)`) for a file path.
- Prefer absolute paths; paths with spaces are fine.
- Keep them out of automated tests (they open windows); the `example/`
  scripts are manual checks.
