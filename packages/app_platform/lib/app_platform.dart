import 'src/import.dart' show PlatformContext;
import 'src/platform.dart' as src;

export 'src/import.dart' show PlatformContext;

/// Deprecated, no longer needed
void platformInit() => src.platformInit();

/// io context or throw. io is always non null insiade
PlatformContext get platformContext => src.platformContext;
