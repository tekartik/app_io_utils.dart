# IO Zip utilities

## Getting Started

### Setup

```yaml
dependencies:
  tekartik_app_io_zip:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      ref: dart3a
      path: packages/app_zip
    version: '>=0.2.0'
```

### Usage

```dart
import 'package:tekartik_app_io_zip/zip.dart';
```

Zip

```dart
await zip(sourceFolder, dst: dstZipFilePath);
await zip('my_source_folder', dst: 'my_zip.zip');
```

Unzip

```dart
await unzip(srcZipFilePath, dst: dstFolder);
await unzip(dst: 'my_zip.zip', dst: 'my_extract_folder');
```