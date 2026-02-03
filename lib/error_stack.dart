/// ErrorStack - Custom error handling for Flutter applications.
///
/// Provides beautiful error screens in debug mode with actionable
/// information like Google search links and stack traces.
// ignore: unnecessary_library_name
library error_stack;

// Config exports
export 'src/config/error_stack_log_level.dart';
export 'src/config/error_stack_config.dart';

// Storage exports
export 'src/storage/error_stack_storage_base.dart';
export 'src/storage/error_stack_storage.dart';

// Handler exports
export 'src/handler/error_stack_handler.dart';

// Widget exports
export 'widgets/error_stack_release_widget.dart';

// Dev Panel exports
export 'src/dev_panel/dev_panel.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'src/dev_panel/dev_panel_config.dart';
import 'src/dev_panel/data/dev_panel_store.dart';
import 'src/dev_panel/widgets/error_stack_dev_panel.dart';
import 'src/dev_panel/widgets/ui_debug_overlay.dart';
import 'src/config/error_stack_config.dart';
import 'src/config/error_stack_log_level.dart';
import 'src/storage/error_stack_storage.dart';
import 'src/storage/error_stack_storage_base.dart';
import 'src/handler/error_stack_handler.dart';

/// The main entry point for ErrorStack.
///
/// Provides a singleton facade that coordinates configuration,
/// storage, and error handling components.
///
/// ## Basic Usage
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await ErrorStack.init();
///   runApp(MyApp());
/// }
/// ```
///
/// ## Advanced Usage
///
/// ```dart
/// await ErrorStack.init(
///   level: ErrorStackLogLevel.verbose,
///   initialRoute: '/home',
///   forceDebugWidget: true,
/// );
/// ```
class ErrorStack {
  ErrorStack._();

  /// The singleton instance of ErrorStack.
  static final ErrorStack instance = ErrorStack._();

  /// The current configuration.
  late ErrorStackConfig config;

  /// The storage backend for preferences.
  late ErrorStackStorageBase storage;

  /// The error handler.
  late ErrorStackHandler handler;

  /// Whether ErrorStack has been initialized.
  static bool _initialized = false;

  /// Initialize the ErrorStack package.
  ///
  /// - [level] controls the verbosity of error logging
  /// - [initialRoute] is the route to navigate to when restarting after an error
  /// - [errorWidget] is an optional custom error widget for release mode
  /// - [forceDebugWidget] forces the debug widget in release mode
  /// - [devPanelConfig] configuration for the dev panel (API logging, auth key, etc.)
  /// - [enableDevPanel] whether to enable the dev panel (defaults to true in debug mode)
  static Future<void> init({
    ErrorStackLogLevel level = ErrorStackLogLevel.verbose,
    String initialRoute = '/',
    Widget Function(FlutterErrorDetails errorDetails)? errorWidget,
    bool forceDebugWidget = false,
    ErrorStackStorageBase? storage,
    DevPanelConfig? devPanelConfig,
    bool? enableDevPanel,
  }) async {
    final storageInstance = storage ?? ErrorStackStorage();
    final themeMode = await storageInstance.getThemeMode() ?? 'light';

    final config = ErrorStackConfig(
      level: level,
      initialRoute: initialRoute,
      customErrorWidget: errorWidget,
      forceDebugWidget: forceDebugWidget,
      themeMode: themeMode,
    );

    final handler = ErrorStackHandler(
      config: config,
      storage: storageInstance,
    );

    instance.config = config;
    instance.storage = storageInstance;
    instance.handler = handler;

    handler.install();
    _initialized = true;

    // Initialize dev panel store (default: enabled in debug mode only)
    final shouldEnableDevPanel = enableDevPanel ?? kDebugMode;
    if (shouldEnableDevPanel) {
      DevPanelStore.init(config: devPanelConfig);
    }
  }

  /// Returns true if ErrorStack has been initialized.
  static bool get isInitialized => _initialized;

  /// Shows the dev panel programmatically.
  ///
  /// Usage:
  /// ```dart
  /// ErrorStack.showDevPanel(context);
  /// ```
  static void showDevPanel(BuildContext context) {
    ErrorStackDevPanel.showDevPanel(context);
  }

  /// A builder function for MaterialApp that wraps the app with debug tools.
  ///
  /// This provides the dev panel bottom bar and UI debug overlays
  /// (grid paper, layout bounds, accessibility tools, etc.).
  ///
  /// Usage:
  /// ```dart
  /// MaterialApp(
  ///   builder: ErrorStack.builder,
  ///   home: MyHomePage(),
  /// )
  /// ```
  ///
  /// To combine with other builders (like localization):
  /// ```dart
  /// MaterialApp(
  ///   builder: (context, child) {
  ///     child = ErrorStack.builder(context, child);
  ///     // Add other wrappers here
  ///     return child;
  ///   },
  /// )
  /// ```
  static Widget Function(BuildContext, Widget?) get builder {
    return (context, child) {
      if (child == null) return const SizedBox.shrink();

      // Only apply debug tools if dev panel is initialized
      if (!DevPanelStore.isInitialized) {
        return child;
      }

      return UIDebugOverlay(
        child: ErrorStackDevPanel(child: child),
      );
    };
  }
}
