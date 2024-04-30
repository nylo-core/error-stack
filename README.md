# Error Net for Flutter

[![pub package](https://img.shields.io/pub/v/permission_policy.svg)](https://pub.dartlang.org/packages/permission_policy)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## Usage

### Simple to use

#### Nylo

``` dart
// Add Error Net to your Nylo application
...
import 'package:error_net/error_net.dart';

class AppProvider {

  @override
  boot(Nylo nylo) async {
    ...
    nylo.useErrorNet(); // enables Error Net
  }
}
```

#### Flutter App

``` dart
// Add Error Net to your main.dart file
...
import 'package:error_net/error_net.dart';

void main() {
  ErrorNet.init(); // Initialize Error Net
  runApp(MyApp());
}
```

Once you have added Error Net to your application, it will override the default error handling in your application.

## Features

- [x] Copy error message to clipboard
- [x] Search fix for error via Google
- [x] Modern UI
- [x] Light and Dark mode support

## Getting started

### Installation

Add the following to your `pubspec.yaml` file:

``` yaml
dependencies:
  error_net: ^1.0.0
```

or with Dart:

``` bash
dart pub add error_net
```

## How to use

The package is very simple to use. 

### Log Levels

- `ErrorNetLogLevel.minimal` (default)
- `ErrorNetLogLevel.verbose` (shows more information)

You can set the log level when initializing Error Net.

### Initialize Error Net


#### Nylo

``` dart
import 'package:error_net/error_net.dart';

class AppProvider {
    
  @override
  boot(Nylo nylo) async {
     ...
     nylo.useErrorNet(logLevel: ErrorNetLogLevel.verbose);
  }
}
```

#### Flutter App
``` dart
import 'package:flutter/material.dart';
import 'package:error_net/error_net.dart';

void main() {
  ErrorNet.init(logLevel: ErrorNetLogLevel.verbose); // Initialize Error Net
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
