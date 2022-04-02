// Noop
import 'import.dart' show PlatformContext;

/// No longer needed
void platformInit() {}

PlatformContext get platformContext =>
    throw UnsupportedError('platformContext');
