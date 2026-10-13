// Copyright (c) 2016, Alexandre Roux Tekartik. All rights reserved. Use of this source code

// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_io_zip/zip.dart';
import 'package:tekartik_io_utils/directory_utils.dart';
import 'package:tekartik_io_utils/file_utils.dart';
import 'package:test/test.dart';

void main() {
  group('zip', () {
    test('unzip', () async {
      var dir = join('.dart_tool', 'tekartik_build_utils', 'test', 'unzip');
      await createEmptyDir(dir);

      await unzip(join('test', 'data', 'test.zip'), dst: dir);
      var dstTextFile = File(join(dir, 'test.txt'));
      expect(await dstTextFile.readAsString(), 'test');
      var dstBinFile = File(join(dir, 'test.bin'));
      expect(await dstBinFile.readAsString(), 'bin');
      if (supportsFilePermission) {
        //devPrint((await dstTextFile.stat()).mode.toRadixString(16));
        //devPrint(await dstBinFile.stat());
        expect(await hasExecutablePermission(dstTextFile.path), false);
        expect(await hasExecutablePermission(dstBinFile.path), true);
        expect((dstTextFile.statSync()).mode & executablePermissionModeMask, 0);
        expect(
          (dstBinFile.statSync()).mode & executablePermissionModeMask,
          executablePermissionModeMask,
        );
      }
    });
    test('zip_unzip', () async {
      var dir = join('.dart_tool', 'tekartik_build_utils', 'test', 'zip_unzip');
      try {
        await Directory(dir).delete(recursive: true);
      } catch (_) {}
      var srcDir = join(dir, 'src');
      await Directory(srcDir).create(recursive: true);
      await File(join(srcDir, 'test.txt')).writeAsString('test');
      var binFile = File(join(srcDir, 'test.bin'));
      await binFile.writeAsString('bin');

      if (supportsFilePermission) {
        await setExecutablePermission(binFile.path);
      }
      await zip(srcDir);
      var dstDir = join(dir, 'dst');
      await unzip('$srcDir.zip', dst: dstDir);
      var dstTextFile = File(join(dstDir, 'test.txt'));
      expect(await dstTextFile.readAsString(), 'test');
      var dstBinFile = File(join(dstDir, 'test.bin'));
      expect(await dstBinFile.readAsString(), 'bin');
      if (supportsFilePermission) {
        // devPrint((await dstTextFile.stat()).mode.toRadixString(16));
        //TOFIX
        /*
        expect(await hasExecutablePermission(dstTextFile.path), false);
        expect(await hasExecutablePermission(dstBinFile.path), true);
        expect((await dstTextFile.stat()).mode & executablePermissionModeMask, 0);
        expect((await dstBinFile.stat()).mode & executablePermissionModeMask, executablePermissionModeMask);
        */
      }
    });
    test('unzip refuses entries outside the destination', () async {
      var dir = await Directory.systemTemp.createTemp('app_zip_slip_');
      try {
        Future<String> writeZip(String name, List<String> entryNames) async {
          var archive = Archive();
          for (var entryName in entryNames) {
            var data = utf8.encode('content of $entryName');
            archive.addFile(ArchiveFile(entryName, data.length, data));
          }
          var zipPath = join(dir.path, name);
          await File(zipPath).writeAsBytes(ZipEncoder().encode(archive));
          return zipPath;
        }

        var dst = join(dir.path, 'out', 'inner');
        for (var entryName in ['../evil.txt', 'sub/../../evil.txt']) {
          // A valid entry first: nothing must be written at all.
          var zipPath = await writeZip('slip.zip', ['ok.txt', entryName]);
          await expectLater(
            unzip(zipPath, dst: dst),
            throwsA(isA<FileSystemException>()),
          );
          expect(File(join(dir.path, 'out', 'evil.txt')).existsSync(), isFalse);
          expect(File(join(dst, 'ok.txt')).existsSync(), isFalse);
        }

        // Absolute entry name
        var absolutePath = join(dir.path, 'absolute_evil.txt');
        var zipPath = await writeZip('absolute.zip', [absolutePath]);
        try {
          await unzip(zipPath, dst: dst);
        } on FileSystemException catch (_) {}
        expect(File(absolutePath).existsSync(), isFalse);

        // Dot segments that stay inside are fine
        zipPath = await writeZip('inside.zip', ['a/../b.txt', './c.txt']);
        await unzip(zipPath, dst: dst);
        expect(
          await File(join(dst, 'b.txt')).readAsString(),
          'content of a/../b.txt',
        );
        expect(File(join(dst, 'c.txt')).existsSync(), isTrue);
      } finally {
        await dir.delete(recursive: true);
      }
    });
  });
}
