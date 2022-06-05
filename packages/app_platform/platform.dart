import 'package:tekartik_app_io_platform/app_platform.dart';

/// Do not include with flutter_test. or add suffix.

/// Safe (false) on the web
final isIOS = platformContext.io?.isIOS ?? false;

/// Safe (false) on the web
final isAndroid = platformContext.io?.isAndroid ?? false;

/// Safe (false) on the web
final isLinux = platformContext.io?.isLinux ?? false;

/// Safe (false) on the web
final isWindows = platformContext.io?.isWindows ?? false;

/// Safe (false) on the web
final isMacOS = platformContext.io?.isMacOS ?? false;

/// Safe (false) on io
final isWeb = platformContext.browser != null;
