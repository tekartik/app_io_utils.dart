import 'dart:io';

import 'package:tekartik_platform/context.dart' show PlatformContext;
import 'package:tekartik_platform_io/context_io.dart';

void platformInit() {
  // No need to handle macOS, as it has now been added to TargetPlatform.
  if (Platform.isLinux || Platform.isWindows) {
    // As of 2020/07/01 this seems no longer needed
    // debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

PlatformContext get platformContext => platformContextIo;
