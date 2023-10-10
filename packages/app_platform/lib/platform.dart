/// Do not include with flutter_test. or add suffix.
library;

import 'package:tekartik_app_io_platform/app_platform.dart';

final _platformContextIo = platformContext.io!;

/// Safe (false) on the web
final isIOS = _platformContextIo.isIOS;

/// Safe (false) on the web
final isAndroid = _platformContextIo.isAndroid;

/// Safe (false) on the web
final isLinux = _platformContextIo.isLinux;

/// Safe (false) on the web
final isWindows = _platformContextIo.isWindows;

/// Safe (false) on the web
final isMacOS = _platformContextIo.isMacOS;
