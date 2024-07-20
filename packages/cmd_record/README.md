# cmd_record

A sample command-line stdout/stderr/stdin recorder

## Setup

```yaml
dependencies:
  tekartik_cmd_record:
    git:
      url: https://github.com/tekartik/app_io_utils.dart
      path: packages/cmd_record
      ref: dart3a
```

## Usage

````
Usage: cmd_record <command> [<arguments>]

Example: cmd_record -o "Hello world"
will display "Hellow world"

Global options:
-h, --help              Usage help
-v, --verbose           Verbose
-n, --no-stderr         No stderr
-s, --run-in-shell      RunInShell
-j, --json              Save as json
-i, --[no-]stdin        stdin read, need CTRL-C to terminate
-w, --[no-]own-stdin    handle stdin and forward command
-x, --exit-code         Exit code to return
    --version           Print the command version
````

## Activation

### From git repository

    pub global activate -s git https://github.com/tekartik/cmd_record.dart

### From local path

    pub global activate -s path .
    
## Quick test

### out record test

    bin/cmd_record.dart example/echo.dart --stdout out
    
should give in `cmd_record.log` something like:

    00:00.165 > out

### err record test

    bin/cmd_record.dart example/echo.dart --stderr err
    
should give in `cmd_record.log` something like:

    00:00.157 E err
    
### in record test

Recording stdin for now requires `CTRL-C` to exit has the main program handles stdin

    bin/cmd_record.dart -i example/echo.dart --stdin
    
should give in `cmd_record.log` something like:

    00:09.574 $ some text entered
    00:09.604 > some text entered

    
