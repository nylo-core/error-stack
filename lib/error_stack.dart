library error_stack;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/widgets/error_stack_release_widget.dart';
import '/widgets/error_stack_debug_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The level of logging to be displayed
enum ErrorStackLogLevel {
  minimal,
  verbose,
}

class ErrorStack {
  /// Storage key
  static const String storageKey = 'error_stack';

  /// Storage instance
  final FlutterSecureStorage storage =
      const FlutterSecureStorage(aOptions: AndroidOptions());

  /// The initial route to navigate to when an error occurs
  String initialRoute = "/";

  /// The theme mode to use
  String themeMode = "light";

  /// singleton instance
  ErrorStack._privateConstructor();

  static final ErrorStack instance = ErrorStack._privateConstructor();

  /// Initialize the ErrorStack package
  /// You can set the [level] to [ErrorStackLogLevel.verbose] to see more details
  /// You can set the [initialRoute] to the route you want to navigate to when an error occurs
  static init({
    ErrorStackLogLevel level = ErrorStackLogLevel.minimal,
    String initialRoute = "/",
  }) async {
    ErrorStack.instance.initialRoute = initialRoute;
    ErrorStack.instance.themeMode = await ErrorStack.instance.storage
            .read(key: '${ErrorStack.storageKey}_theme_mode') ??
        'light';
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      if (kReleaseMode) {
        return ErrorStackReleaseWidget(errorDetails: errorDetails);
      }
      return ErrorStackDebugWidget(errorDetails: errorDetails);
    };
    FlutterError.onError = (FlutterErrorDetails details) {
      String stack = details.stack.toString();
      RegExp regExp = RegExp(r'(\(package:[A-z/.:0-9]+\))');

      Iterable<RegExpMatch> regMatches = regExp.allMatches(stack);

      String? className = '';
      if (regMatches.isNotEmpty) {
        className = regMatches.first.group(0);
      }

      if (kDebugMode) {
        print('𖢥 == Error Details == 𖢥');

        print(details.exceptionAsString());
        print('File: $className');
        String exception = "${details.exceptionAsString()} flutter";
        String encodedQuery = Uri.encodeQueryComponent(exception);
        print('Google: (https://www.google.com/search?q=$encodedQuery)');
        if (level == ErrorStackLogLevel.verbose) {
          print("Stack: $stack");
        }
      }
      return;
    };
  }
}
