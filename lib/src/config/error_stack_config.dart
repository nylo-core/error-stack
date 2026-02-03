import 'package:flutter/material.dart';
import 'error_stack_log_level.dart';

/// Configuration options for ErrorStack.
///
/// Holds all configurable settings including logging level, routes,
/// theme preferences, and custom error widget builders.
class ErrorStackConfig {
  /// The logging level for error output.
  final ErrorStackLogLevel level;

  /// The initial route to navigate to when restarting after an error.
  final String initialRoute;

  /// Optional custom error widget builder for release mode.
  final Widget Function(FlutterErrorDetails errorDetails)? customErrorWidget;

  /// Forces the debug widget to be shown even in release mode.
  final bool forceDebugWidget;

  /// The current theme mode ('light' or 'dark').
  String themeMode;

  /// Creates an [ErrorStackConfig] with the specified settings.
  ///
  /// - [level] defaults to [ErrorStackLogLevel.verbose]
  /// - [initialRoute] defaults to "/"
  /// - [themeMode] defaults to "light"
  /// - [forceDebugWidget] defaults to false
  ErrorStackConfig({
    this.level = ErrorStackLogLevel.verbose,
    this.initialRoute = '/',
    this.customErrorWidget,
    this.forceDebugWidget = false,
    this.themeMode = 'light',
  });
}
