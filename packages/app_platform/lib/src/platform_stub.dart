import 'import.dart'; // ignore: depend_on_referenced_packages

/// No longer needed
void platformInit() => _stub('platformInit');

/// Browser or io context.
PlatformContext get platformContext => _stub('platformContext');

/// Always throw.
T _stub<T>(String message) {
  throw UnimplementedError(message);
}
