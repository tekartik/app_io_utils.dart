import 'dart:io';

import 'package:process_run/shell.dart';

import 'launch_terminal_options.dart';
import 'launch_utils.dart';

export 'launch_terminal_options.dart' show LaunchTerminalOptions;

/// Terminal emulator commands tried on linux, in order.
///
/// `xdg-terminal-exec` and `x-terminal-emulator` resolve to the terminal the
/// user (or the distribution) configured, the others are the common desktop
/// environment and standalone ones.
const _linuxCommands = <String>[
  'xdg-terminal-exec',
  'x-terminal-emulator',
  'gnome-terminal',
  'konsole',
  'xfce4-terminal',
  'mate-terminal',
  'tilix',
  'terminator',
  'alacritty',
  'kitty',
  'wezterm',
  'foot',
  'xterm',
];

/// Working directory arguments of the linux terminals that need one.
///
/// The other terminals start in the directory they are spawned from, which is
/// handled by the process working directory. `gnome-terminal` and the like
/// talk to an already running server, so they need to be told explicitly.
List<String> _linuxDirectoryArgs(String command, String directoryPath) =>
    switch (command) {
      'gnome-terminal' ||
      'xfce4-terminal' ||
      'mate-terminal' ||
      'terminator' => ['--working-directory=$directoryPath'],
      'konsole' => ['--workdir', directoryPath],
      'tilix' => ['--working-directory=$directoryPath'],
      _ => <String>[],
    };

/// Launch a terminal emulator, spawning a new terminal window.
///
/// The window opens in [LaunchTerminalOptions.directoryPath] when given.
///
/// Returns false when no terminal could be launched.
Future<bool> launchTerminal({
  LaunchTerminalOptions? options,
  bool verbose = false,
}) async {
  var directoryPath = options?.directoryPath;
  if (directoryPath != null) {
    directoryPath = Directory(directoryPath).absolute.path;
  }

  if (Platform.isMacOS) {
    var executable = await which('open') ?? 'open';
    return await startDetached(executable, [
      '-a',
      'Terminal',
      directoryPath ?? '.',
    ], verbose: verbose);
  }

  if (Platform.isWindows) {
    // Windows Terminal when installed, the good old console otherwise.
    var wt = await which('wt');
    if (wt != null) {
      if (await startDetached(wt, [
        if (directoryPath != null) ...['-d', directoryPath],
      ], verbose: verbose)) {
        return true;
      }
    }
    var cmd = await which('cmd') ?? 'cmd';
    // `start` is a cmd builtin, it detaches the new console from this one.
    return await startDetached(
      cmd,
      ['/c', 'start', 'cmd'],
      workingDirectory: directoryPath,
      verbose: verbose,
    );
  }

  for (var command in _linuxCommands) {
    var executable = await which(command);
    if (executable == null) {
      continue;
    }
    var arguments = directoryPath == null
        ? <String>[]
        : _linuxDirectoryArgs(command, directoryPath);
    if (await startDetached(
      executable,
      arguments,
      workingDirectory: directoryPath,
      verbose: verbose,
    )) {
      return true;
    }
  }
  return false;
}
