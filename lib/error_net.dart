library error_net;

import 'package:nylo_support/nylo.dart';

import '/widgets/error_net_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The level of logging to be displayed
enum ErrorNetLogLevel {
  minimal,
  verbose,
}

class ErrorNet {
  static const String storageKey = 'error_net_theme_mode';

  /// Initialize the ErrorNet package
  /// You can set the [level] to [ErrorNetLogLevel.verbose] to see more details
  static init({ErrorNetLogLevel level = ErrorNetLogLevel.minimal, bool nyloInitialing = false}) {
    if (nyloInitialing == false) {
      Nylo.initFromPackage();
    }
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return ErrorNetWidget(errorDetails: errorDetails);
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
        print(
            'Google: (https://www.google.com/search?q=$encodedQuery%20flutter)');
        if (level == ErrorNetLogLevel.verbose) {
          print("Stack: $stack");
        }
      }
      return;
    };
  }
}
