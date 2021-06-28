// Noop
import 'package:tekartik_platform/context.dart' show PlatformContext;

// No longet needed
void platformInit() {}

PlatformContext get platformContext =>
    throw UnsupportedError('platformContext');
