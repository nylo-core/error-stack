library error_stack;

import '/widgets/error_stack_release_widget.dart';
import 'package:nylo_support/helpers/backpack.dart';
import 'package:nylo_support/nylo.dart';
import '/widgets/error_stack_debug_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The level of logging to be displayed
enum ErrorStackLogLevel {
  minimal,
  verbose,
}

class ErrorStack {
  static const String storageKey = 'error_stack_theme_mode';

  /// Initialize the ErrorStack package
  /// You can set the [level] to [ErrorStackLogLevel.verbose] to see more details
  /// You can set the [initialRoute] to the route you want to navigate to when an error occurs
  /// You can set [isNyloApp] to true if you are using the Nylo framework
  static init({ErrorStackLogLevel level = ErrorStackLogLevel.minimal, String initialRoute = "/", bool isNyloApp = false}) {
    if (isNyloApp == false) {
      Nylo _nylo = Nylo();
      Backpack.instance.set('nylo', _nylo);
      /// Initialize the Nylo framework
    }
    Backpack.instance.set("${storageKey}_initial_route", initialRoute);
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
        print(
            'Google: (https://www.google.com/search?q=$encodedQuery)');
        if (level == ErrorStackLogLevel.verbose) {
          print("Stack: $stack");
        }
      }
      return;
    };
  }
}
