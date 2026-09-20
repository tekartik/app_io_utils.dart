---
name: tekartik-app-io-launcher-setup
description: >-
  Use when a Dart command line tool, dev script or desktop app must open
  something on the user's desktop with tekartik_app_io_launcher:
  launchBrowser, launchChrome, launchFirefox (a Uri), launchDefaultViewer /
  launchDefaultViewerPath / launchImageViewer (a file in its default
  application), launchTextEdit (gedit, notepad, TextEdit), launchFileExplorer
  (a folder in the file manager), launchTerminal with
  LaunchTerminalOptions(directoryPath:), launchIdea (IntelliJ IDEA), the
  launcher.dart import, verbose: true, the Future<bool> result and the web
  stub that throws UnimplementedError.
---

# Launch desktop applications (tekartik_app_io_launcher)

`tekartik_app_io_launcher` opens a url, a file, a folder, a terminal or the
IDE in the application the user's desktop provides, from `dart:io` code. It
uses `package:process_run` to find (`which`) and run the right command on
Linux, macOS and Windows.

## Guidelines

* Dependency (git, not on pub.dev):
  ```yaml
  dependencies:
    tekartik_app_io_launcher:
      git:
        url: https://github.com/tekartik/app_io_utils.dart
        path: packages/app_launcher
      version: '>=0.1.1'
  ```
  It brings `process_run`, `path` and `tekartik_common_utils`; declare
  `process_run` (and `path`) yourself when you use their helpers
  (`userAppDataPath`, `ShellException`, `join`...).
* Import `package:tekartik_app_io_launcher/launcher.dart`, the only public
  library (everything under `lib/src/` is private).
* Every launcher returns a `Future<bool>`: `true` when a suitable command
  was found and started (no guarantee that the application showed
  anything), `false` when nothing usable is installed. All take
  `verbose: false` by default; `verbose: true` echoes the command run.
* Platform: `dart:io` only. On the web the same names exist (conditional
  import) but every call throws `UnimplementedError`: importing is safe,
  calling is not.
* Urls, in a browser (`Uri` argument: `Uri.parse('https://...')` or
  `Uri.file(path)`):
  - `launchBrowser(uri)`: the default browser (`xdg-open` when present,
    `open` on macOS, `explorer` on Windows), then `launchChrome` as a
    fallback.
  - `launchChrome(uri)`: `google-chrome`, `open -a "Google Chrome"`,
    `start chrome`.
  - `launchFirefox(uri)`: `firefox`, `open -a Firefox`, `start firefox`.
* Files, in their default application:
  - `launchDefaultViewer(uri)`: `xdg-open` / `open` / `explorer`, chrome
    as a fallback. `launchDefaultViewerPath(path)` first converts a path to
    a `file:` uri (a string that already has a scheme, `http://...`, is
    kept as is); `launchImageViewer(path)` is the same call under another
    name. Works for pdf, html, markdown, images...
  - `launchTextEdit(path, {doNotCreate})`: creates the file (and its parent
    directories) when missing unless `doNotCreate: true`, then runs `gedit`
    (Linux), `notepad` (Windows), `open -a TextEdit` (macOS), `vi` as the
    last resort.
* Folders: `launchFileExplorer(path)` shows a folder (or a file) in the
  file manager: `open`, `explorer`, or on Linux the first available of
  `xdg-open`, `nautilus`, `dolphin`, `thunar`, `nemo`, `caja`, `pcmanfm`,
  `pcmanfm-qt`.
* Terminal: `launchTerminal(options: LaunchTerminalOptions(directoryPath:
  '.'))` opens a new terminal window in that directory (made absolute; the
  current directory without options): Terminal.app on macOS, Windows
  Terminal (`wt -d`) then `cmd /c start cmd` on Windows, on Linux the first
  available of `xdg-terminal-exec`, `x-terminal-emulator`,
  `gnome-terminal`, `konsole`, `xfce4-terminal`, `mate-terminal`, `tilix`,
  `terminator`, `alacritty`, `kitty`, `wezterm`, `foot`, `xterm`.
* IDE: `launchIdea(args: ['.'])` opens IntelliJ IDEA on the given project
  or file paths: `open -na "IntelliJ IDEA.app" --args ...` (then the
  Ultimate and CE app names) on macOS, `idea`, `idea64`, `idea.cmd`,
  `idea.bat`, `idea64.exe` on Windows, `idea`, `intellij-idea-ultimate`,
  `intellij-idea-community` on Linux.
* Blocking or detached: `launchFileExplorer` and `launchTerminal` start a
  detached process and return at once. The others run the command with
  process_run `run` and complete when it exits: for `launchTextEdit` that
  is when the editor (or `vi`) is closed; browsers usually hand the url to
  a running instance and exit immediately. A non zero exit code makes `run`
  throw a `ShellException` (`package:process_run/shell.dart`), except in
  `launchBrowser`/`launchDefaultViewer` on Windows (ignored) and in
  `launchIdea` (returns false): wrap the call in `try`/`catch` when the
  tool must not crash.
* Paths with spaces are fine (quoted with `shellArgument`, or passed as
  process arguments). Prefer absolute paths.
* Tests: keep the launchers out of automated tests (they open windows and
  need a desktop); the package tests only reference the functions. Put
  manual checks in `example/` scripts, as the package does.

## Examples

### Open a url, default browser first then chrome

```dart
import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

Future<void> openDocs(String url) async {
  var uri = Uri.parse(url);
  try {
    if (await launchBrowser(uri, verbose: true)) {
      return;
    }
  } on ShellException catch (e) {
    print('default browser failed: $e');
  }
  if (!await launchChrome(uri)) {
    print('No browser found, open $uri yourself');
  }
}

Future<void> main() => openDocs('https://dart.dev');
```

### Generate a report and show it

```dart
import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

Future<void> main() async {
  var dir = Directory(join('.local', 'report'));
  await dir.create(recursive: true);
  var htmlPath = join(dir.path, 'index.html');
  await File(htmlPath).writeAsString('<h1>Report</h1>');
  var pngPath = join(dir.path, 'chart.png');
  // ... write the image ...

  // Default browser for the html file, default image viewer for the png
  await launchDefaultViewerPath(htmlPath);
  if (File(pngPath).existsSync()) {
    await launchImageViewer(pngPath);
  }
  // And the folder itself in the file manager
  await launchFileExplorer(dir.absolute.path);
}
```

### Developer helper: terminal, IDE and config file

```dart
import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_app_io_launcher/launcher.dart';

/// dart run tool/dev.dart terminal|idea|config
Future<void> main(List<String> args) async {
  switch (args.firstOrNull) {
    case 'terminal':
      // New terminal window in the project directory
      await launchTerminal(
        options: LaunchTerminalOptions(directoryPath: '.'),
        verbose: true,
      );
    case 'idea':
      await launchIdea(args: ['.']);
    case 'config':
      // Created if missing, in the user application data directory
      var path = join(userAppDataPath, 'my_tool', 'config.yaml');
      await launchTextEdit(path);
    default:
      print('usage: dev terminal|idea|config');
  }
}
```

## Common mistakes

* Calling a launcher from code that also runs on the web: it throws
  `UnimplementedError` there.
* Passing a path string to `launchBrowser`, `launchChrome` or
  `launchDefaultViewer`: they take a `Uri`; use `launchDefaultViewerPath`
  or `Uri.file(path)`.
* Awaiting `launchTextEdit` inside a server or UI loop: it returns only
  when the editor exits.
* Ignoring a `false` result: nothing was opened, print the path or url so
  the user can open it.
