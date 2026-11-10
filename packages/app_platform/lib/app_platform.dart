/// The [PlatformContext] of an io program (Dart VM, command line, Flutter
/// mobile and desktop): [platformContext]. It throws on the web.
library;

import 'src/import.dart' show PlatformContext;
import 'src/platform.dart' as src;

export 'src/import.dart' show PlatformContext;

/// Deprecated, no longer needed: a no-op kept for old callers.
void platformInit() => src.platformInit();

/// The io context (`io` and `platform` non null) on the Dart VM and Flutter
/// mobile and desktop.
///
/// Throws an [UnsupportedError] on the web.
PlatformContext get platformContext => src.platformContext;
