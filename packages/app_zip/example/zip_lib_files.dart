// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_io_zip/zip.dart';

Future<void> main() async {
  var dstFile =
      File(join('.dart_tool', 'tekartik_app_io_zip', 'test', 'lib_files.zip'));
  var dstZipDir = dstFile.parent;

  try {
    await dstFile.parent.delete(recursive: true);
  } catch (_) {}
  var sourceFolder = 'lib';
  var dstZipFilePath = dstFile.path;
  await zip(sourceFolder, dst: dstZipFilePath);
  print('$dstFile: ${dstFile.statSync().size} bytes');

  var srcZipFilePath = dstZipFilePath;
  var dstFolder = dstZipDir.path;
  await unzip(srcZipFilePath, dst: dstFolder);
}
