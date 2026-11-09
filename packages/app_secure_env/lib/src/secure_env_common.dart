/// An encrypted value of the process_run environment: the variable [key]
/// holds the value encrypted with [password].
class SecureEnvKey {
  /// The environment variable name (letters, digits, underscores).
  final String key;

  /// The AES password: 16, 24 or 32 ascii characters (any other length
  /// throws). It lives in the source code: it hides the value from a look at
  /// the env file, not from someone who also has the code.
  final String password;

  /// An encrypted value of the process_run environment.
  SecureEnvKey({required this.key, required this.password});
}
