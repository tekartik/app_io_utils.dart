# tekartik_app_io_utils/app_io_launcher

Helper for launching desktop application (chrome, notepad, file explorer).

### Setup

```yaml
dependencies:
  tekartik_app_io_launcher:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      ref: dart3a
      path: packages/app_launcher
    version: '>=0.1.1'
```

### Usage

Launch default browser:

```dart
await launchBrowser(Uri.parse('https://www.google.com'));
```

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