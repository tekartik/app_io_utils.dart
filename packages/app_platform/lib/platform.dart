/// Top-level `isIOS`, `isAndroid`, `isLinux`, `isWindows` and `isMacOS`,
/// computed once from `platformContext.io`. Import it with a prefix
/// (`as p`): the names clash with other libraries (`flutter_test`...).
///
/// Io only: on the web, reading one of them throws an [UnsupportedError].
library;

import 'package:tekartik_app_io_platform/app_platform.dart';

final _platformContextIo = platformContext.io!;

/// True on iOS (a Flutter app on a device), false on the other io platforms.
final isIOS = _platformContextIo.isIOS;

/// True on Android (a Flutter app on a device), false on the other io
/// platforms.
final isAndroid = _platformContextIo.isAndroid;

/// True on Linux.
final isLinux = _platformContextIo.isLinux;

/// True on Windows.
final isWindows = _platformContextIo.isWindows;

/// True on macOS.
final isMacOS = _platformContextIo.isMacOS;
