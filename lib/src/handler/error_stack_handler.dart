import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/error_stack_config.dart';
import '../config/error_stack_log_level.dart';
import '../storage/error_stack_storage_base.dart';
import '../../widgets/error_stack_debug_widget.dart';
import '../../widgets/error_stack_release_widget.dart';

/// Handles Flutter errors by logging, parsing stack traces,
/// and building appropriate error widgets.
class ErrorStackHandler {
  /// The configuration for error handling behavior.
  final ErrorStackConfig config;

  /// The storage backend for persisting preferences.
  final ErrorStackStorageBase storage;

  /// Creates an [ErrorStackHandler] with the given [config] and [storage].
  ErrorStackHandler({
    required this.config,
    required this.storage,
  });

  /// Installs this handler as the global Flutter error handler.
  ///
  /// Sets [ErrorWidget.builder] and [FlutterError.onError] to use
  /// this handler's methods.
  void install() {
    ErrorWidget.builder = buildErrorWidget;
    FlutterError.onError = handleError;
  }

  /// Builds the appropriate error widget based on build mode and config.
  ///
  /// In release mode (unless [config.forceDebugWidget] is true):
  /// - Returns [config.customErrorWidget] if provided
  /// - Otherwise returns [ErrorStackReleaseWidget]
  ///
  /// In debug mode or when [config.forceDebugWidget] is true:
  /// - Returns [ErrorStackDebugWidget] with injected dependencies
  Widget buildErrorWidget(FlutterErrorDetails errorDetails) {
    if (kReleaseMode && !config.forceDebugWidget) {
      if (config.customErrorWidget != null) {
        return config.customErrorWidget!(errorDetails);
      }
      return ErrorStackReleaseWidget(errorDetails: errorDetails);
    }
    return ErrorStackDebugWidget(
      errorDetails: errorDetails,
      initialRoute: config.initialRoute,
      initialThemeMode: config.themeMode,
      onThemeChanged: _handleThemeChanged,
    );
  }

  /// Callback for when the theme is changed in the debug widget.
  Future<void> _handleThemeChanged(String newTheme) async {
    config.themeMode = newTheme;
    await storage.setThemeMode(newTheme);
  }

  /// Handles a Flutter error by logging details to the console.
  ///
  /// Extracts the class/file name from the stack trace and provides
  /// a Google search link for the error message.
  void handleError(FlutterErrorDetails details) {
    String stack = details.stack.toString();
    String? className = _extractClassName(stack);

    if (kDebugMode) {
      print('𖢥 == Error Details == 𖢥');
      String exceptionAsString = details.exceptionAsString();
      if (exceptionAsString.isNotEmpty) {
        print(exceptionAsString);
      }

      if ((className ?? "").isNotEmpty) {
        print('File: $className');
      }

      String exception = "${details.exceptionAsString()} flutter";
      String encodedQuery = Uri.encodeQueryComponent(exception);
      print('Google: (https://www.google.com/search?q=$encodedQuery)');

      if (config.level == ErrorStackLogLevel.verbose) {
        print("Stack: $stack");
      }
    }
  }

  /// Extracts the class/file name from a stack trace string.
  ///
  /// Attempts to match package-style paths first, then web-style paths.
  /// Returns null or an empty string if no match is found.
  String? _extractClassName(String stack) {
    RegExp regExp = RegExp(r'(\(package:[A-z/.:0-9]+\))');
    RegExp webRegExp = RegExp(r'packages/[A-z_]+(/([A-z/.:0-9]+)\s[0-9:]+)');

    Iterable<RegExpMatch> regMatches = regExp.allMatches(stack);

    String? className;
    if (regMatches.isNotEmpty) {
      className = regMatches.first.group(0);
    }

    if (className == null || className.isEmpty) {
      Iterable<RegExpMatch> webRegMatches = webRegExp.allMatches(stack);
      if (webRegMatches.isNotEmpty) {
        className = webRegMatches.first.group(0);
      }
    }

    return className;
  }
}
