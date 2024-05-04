# Error Stack for Flutter

[![pub package](https://img.shields.io/pub/v/permission_policy.svg)](https://pub.dartlang.org/packages/permission_policy)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

<img src="https://raw.githubusercontent.com/nylo-core/error-stack/main/screenshots/error_stack.png" height="400" />

### Simple to use

#### Nylo

``` dart
// Add Error Stack to your Nylo app provider
...
import 'package:error_stack/error_stack.dart';

class AppProvider {

  @override
  boot(Nylo nylo) async {
    ...
    nylo.useErrorStack(); // enables Error Stack
  }
}
```

#### Flutter App

``` dart
// Add Error Stack to your main.dart file
...
import 'package:error_stack/error_stack.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorStack.init(); // Initialize Error Stack
  runApp(MyApp());
}
```

Once you have added Error Stack to your application, it will override the default error handling in your application.

## Features

- [x] Copy error message to clipboard
- [x] Search fix for error via Google
- [x] Modern UI for debug and release mode
- [x] Light and Dark mode support

## Getting started

### Installation

Add the following to your `pubspec.yaml` file:

``` yaml
dependencies:
  error_stack: ^1.2.1
```

or with Dart:

``` bash
dart pub add error_stack
```

## How to use

The package is very simple to use. 

### Log Levels

- `ErrorStackLogLevel.minimal` (default)
- `ErrorStackLogLevel.verbose` (shows more information)

You can set the log level when initializing Error Stack.

#### Nylo

``` dart
import 'package:error_stack/error_stack.dart';

class AppProvider {
    
  @override
  boot(Nylo nylo) async {
     ...
     nylo.useErrorStack(logLevel: ErrorStackLogLevel.verbose);
  }
}
```

#### Flutter App

``` dart
import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorStack.init(logLevel: ErrorStackLogLevel.verbose); // Initialize Error Stack
  runApp(MyApp());
}
```

Try the [example](/example) app to see how it works.

## Changelog
Please see [CHANGELOG](https://github.com/nylo-core/permission-policy/blob/master/CHANGELOG.md) for more information what has changed recently.

## Social
* [Twitter](https://twitter.com/nylo_dev)

## Licence

The MIT License (MIT). Please view the [License](https://github.com/nylo-core/permission-policy/blob/main/LICENSE) File for more information.
