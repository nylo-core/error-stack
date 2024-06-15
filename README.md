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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ErrorStack.init(); // Initialize Error Stack
  runApp(MyApp());
}
```

Once you have added Error Stack to your application, it will override the default error handling in your application.

## Features

- [x] Instant Google search to resolve error
- [x] Copy error message to clipboard
- [x] Modern UI for debug and release mode
- [x] Light and Dark mode support
- [x] Customizable Production Error Page

## Getting started

### Installation

Add the following to your `pubspec.yaml` file:

``` yaml
dependencies:
  error_stack: ^1.7.3
```

or with Dart:

``` bash
dart pub add error_stack
```

## How to use

The package is very simple to use. 

### Log Levels

- `ErrorStackLogLevel.verbose` (default)
- `ErrorStackLogLevel.minimal` (shows less information)

You can set the log level when initializing Error Stack.

#### Nylo

``` dart
import 'package:error_stack/error_stack.dart';

class AppProvider {
    
  @override
  boot(Nylo nylo) async {
     ...
     nylo.useErrorStack(logLevel: ErrorStackLogLevel.minimal);
  }
}
```

#### Flutter App

``` dart
import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ErrorStack.init(logLevel: ErrorStackLogLevel.minimal); // Initialize Error Stack
  runApp(MyApp());
}
```

### Full Parameters

``` dart
ErrorStack.init(
	level: ErrorStackLogLevel.verbose,  // The ErrorStackLogLevel.verbose | ErrorStackLogLevel.minimal
	initialRoute: "/", // Navigate to this route when tapping "Restart app"
	errorWidget: (errorDetails) { // The error widget you want to show in release mode
    	return Scaffold(
      	    appBar: AppBar(
        	    title: Text("Error"),
      	    ),
      	    body: Center(
        	    child: Text("An error occurred"),
      	    ),
    	);
	}
);
```

Try the [example](/example) app to see how it works.

## Changelog
Please see [CHANGELOG](https://github.com/nylo-core/permission-policy/blob/master/CHANGELOG.md) for more information what has changed recently.

## Social
* [Twitter](https://twitter.com/nylo_dev)

## Licence

The MIT License (MIT). Please view the [License](https://github.com/nylo-core/permission-policy/blob/main/LICENSE) File for more information.
