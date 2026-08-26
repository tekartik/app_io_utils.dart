import 'dart:io';

import 'package:process_run/shell.dart';

/// Find the first of [commands] available on this machine, null if none.
Future<String?> whichFirst(List<String> commands) async {
  for (var command in commands) {
    var executable = await which(command);
    if (executable != null) {
      return executable;
    }
  }
  return null;
}

/// Start [executable] detached with [arguments].
///
/// Detached because the launched app must outlive the caller and must not
/// block it: a lot of terminal emulators (`xterm`, `alacritty`, `kitty`...)
/// stay in the foreground until their window is closed.
///
/// [arguments] are passed as is, no shell quoting is involved (a path with
/// spaces works).
///
/// Returns false when the process could not be started.
Future<bool> startDetached(
  String executable,
  List<String> arguments, {
  String? workingDirectory,
  bool verbose = false,
}) async {
  if (verbose) {
    stdout.writeln(
      '\$ ${[executable, ...arguments].map(shellArgument).join(' ')}'
      '${workingDirectory == null ? '' : ' (in $workingDirectory)'}',
    );
  }
  try {
    await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory,
      mode: ProcessStartMode.detached,
    );
    return true;
  } catch (e) {
    if (verbose) {
      stderr.writeln('$executable failed $e');
    }
    return false;
  }
}
