# tekartik_app_io_utils/app_io_launcher

Helper for launching desktop application (chrome, notepad, file explorer).

### Setup

```yaml
dependencies:
  tekartik_app_io_launcher:
    git:
      url: git://github.com/tekartik/app_io_utils.dart
      ref: null_safety
      path: packages/app_launcher
    version: '>=0.1.1'
```

### Usage

Launch Chrome:

```dart
await launchChrome(Uri.parse('https://www.google.com'));
```

Launch Text edit:
```dart
await launchTextEdit('<my file path>');
```

Launch File explorer:
```dart
await launchFileExplorer('<my directory path>');
```