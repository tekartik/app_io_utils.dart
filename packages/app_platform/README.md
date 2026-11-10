# tekartik_app_io_platform

Which operating system a Dart io program (command line tool, server, Flutter
mobile or desktop app) runs on, as a
[tekartik_platform](https://github.com/tekartik/platform.dart) `PlatformContext`,
plus `isLinux`, `isWindows`, `isMacOS`, `isAndroid` and `isIOS` booleans.

## Getting started

Not on pub.dev, add it as a git dependency:

```yaml
dependencies:
  tekartik_app_io_platform:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/app_platform
```

```dart
import 'package:tekartik_app_io_platform/app_platform.dart';
import 'package:tekartik_app_io_platform/platform.dart' as p;

void main() {
  // {io: {platform: linux}}
  print(platformContext.toMap());
  print(p.isWindows ? 'windows' : (p.isMacOS ? 'macos' : 'linux or other'));
  var env = platformContext.io!.environment;
  print(env['HOME'] ?? env['USERPROFILE']);
}
```

Example: [example/main.dart](example/main.dart).

## Platforms

* Dart VM, command line, Flutter mobile and desktop: `platformContext` is the
  io context (`platformContextIo` of tekartik_platform_io): `io` and
  `platform` are set, `browser` and `node` are null.
* Web: importing compiles, but reading `platformContext` or one of the
  `platform.dart` booleans throws an `UnsupportedError`. This package has no
  browser context: use tekartik_platform_browser there.

## Entry points

* `package:tekartik_app_io_platform/app_platform.dart`: `platformContext`
  (`io`, `platform`, `toMap()`) and the `PlatformContext` type.
  `platformInit()` is a deprecated no-op, nothing to call anymore.
* `package:tekartik_app_io_platform/platform.dart`: the top-level `isIOS`,
  `isAndroid`, `isLinux`, `isWindows` and `isMacOS`, computed once from
  `platformContext.io`.

## Common pitfalls

* Import `platform.dart` with a prefix (`as p`): its short names clash with
  other libraries (`flutter_test`, `dart:io` `Platform` getters...).
* `isAndroid` and `isIOS` are only true in a Flutter app on a device, never
  on a desktop host.
* Shared code that also compiles for the web must not read `platformContext`
  there: guard it, or catch `UnsupportedError`.

Agent skill: [skills/tekartik-app-io-platform-setup](skills/tekartik-app-io-platform-setup/SKILL.md).
