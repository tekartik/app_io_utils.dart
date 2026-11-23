@TestOn('vm')
library;

import 'package:tekartik_app_io_launcher/launcher.dart';
import 'package:test/test.dart';

void main() {
  String? none(String command) => null;
  bool missing(String path) => false;

  test('CHROME_EXECUTABLE first', () {
    expect(
      findChromeExecutable(
        operatingSystem: 'linux',
        environment: {'CHROME_EXECUTABLE': '/opt/chrome/chrome'},
        which: (command) => '/usr/bin/$command',
      ),
      '/opt/chrome/chrome',
    );
  });

  test('the path, Chrome before Chromium', () {
    expect(
      findChromeExecutable(
        operatingSystem: 'linux',
        environment: {},
        which: (command) => command == 'chromium' || command == 'google-chrome'
            ? '/usr/bin/$command'
            : null,
      ),
      '/usr/bin/google-chrome',
    );
    expect(
      findChromeExecutable(
        operatingSystem: 'linux',
        environment: {},
        which: (command) =>
            command == 'chromium-browser' ? '/usr/bin/$command' : null,
      ),
      '/usr/bin/chromium-browser',
    );
  });

  test('the macOS app', () {
    const app = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
    expect(
      findChromeExecutable(
        operatingSystem: 'macos',
        environment: {},
        which: none,
        exists: (path) => path == app,
      ),
      app,
    );
  });

  test('Windows install locations', () {
    var environment = {
      'ProgramFiles': r'C:\Program Files',
      'ProgramFiles(x86)': r'C:\Program Files (x86)',
      'LOCALAPPDATA': r'C:\Users\me\AppData\Local',
    };
    String find(String installed) => findChromeExecutable(
      operatingSystem: 'windows',
      environment: environment,
      which: none,
      exists: (path) => path == installed,
    );
    for (var installed in [
      r'C:\Program Files\Google\Chrome\Application\chrome.exe',
      r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
      r'C:\Users\me\AppData\Local\Google\Chrome\Application\chrome.exe',
    ]) {
      expect(find(installed), installed);
    }
  });

  test('not found', () {
    for (var system in ['linux', 'macos', 'windows']) {
      expect(
        () => findChromeExecutable(
          operatingSystem: system,
          environment: {'ProgramFiles': r'C:\Program Files'},
          which: none,
          exists: missing,
        ),
        throwsStateError,
      );
    }
  });
}
