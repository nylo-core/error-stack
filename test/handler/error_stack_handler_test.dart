import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/handler/error_stack_handler.dart';
import 'package:error_stack/src/config/error_stack_config.dart';
import 'package:error_stack/src/config/error_stack_log_level.dart';
import 'package:error_stack/src/storage/error_stack_storage_base.dart';
import 'package:error_stack/widgets/error_stack_debug_widget.dart';
import 'package:error_stack/widgets/error_stack_release_widget.dart';

/// Mock storage implementation for testing
class MockStorage implements ErrorStackStorageBase {
  String? _themeMode;
  int setThemeModeCallCount = 0;

  @override
  Future<String?> getThemeMode() async => _themeMode;

  @override
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    setThemeModeCallCount++;
  }
}

void main() {
  group('ErrorStackHandler', () {
    late MockStorage mockStorage;
    late ErrorStackConfig config;
    late ErrorStackHandler handler;

    setUp(() {
      mockStorage = MockStorage();
      config = ErrorStackConfig();
      handler = ErrorStackHandler(config: config, storage: mockStorage);
    });

    group('constructor', () {
      test('accepts config and storage', () {
        expect(handler.config, config);
        expect(handler.storage, mockStorage);
      });
    });

    group('install', () {
      test('sets ErrorWidget.builder', () {
        final originalBuilder = ErrorWidget.builder;

        handler.install();

        expect(ErrorWidget.builder, isNot(originalBuilder));
        expect(ErrorWidget.builder, handler.buildErrorWidget);
      });

      test('sets FlutterError.onError', () {
        final originalHandler = FlutterError.onError;

        handler.install();

        expect(FlutterError.onError, isNot(originalHandler));
        expect(FlutterError.onError, handler.handleError);
      });
    });

    group('buildErrorWidget', () {
      late FlutterErrorDetails errorDetails;

      setUp(() {
        errorDetails = FlutterErrorDetails(
          exception: Exception('Test error'),
          stack: StackTrace.current,
        );
      });

      testWidgets('returns ErrorStackDebugWidget in debug mode',
          (tester) async {
        // In debug mode (which test environment is), should return debug widget
        final widget = handler.buildErrorWidget(errorDetails);

        expect(widget, isA<ErrorStackDebugWidget>());
      });

      testWidgets('ErrorStackDebugWidget receives correct props',
          (tester) async {
        config = ErrorStackConfig(
          initialRoute: '/home',
          themeMode: 'dark',
        );
        handler = ErrorStackHandler(config: config, storage: mockStorage);

        final widget = handler.buildErrorWidget(errorDetails);

        expect(widget, isA<ErrorStackDebugWidget>());
        final debugWidget = widget as ErrorStackDebugWidget;
        expect(debugWidget.errorDetails, errorDetails);
        expect(debugWidget.initialRoute, '/home');
        expect(debugWidget.initialThemeMode, 'dark');
      });

      test('forceDebugWidget returns debug widget even if release mode logic',
          () {
        config = ErrorStackConfig(forceDebugWidget: true);
        handler = ErrorStackHandler(config: config, storage: mockStorage);

        final widget = handler.buildErrorWidget(errorDetails);

        // Since we're in debug mode, this will be debug widget anyway
        // But forceDebugWidget ensures it in release mode too
        expect(widget, isA<ErrorStackDebugWidget>());
      });

      test('custom error widget can be provided', () {
        Widget customWidget(FlutterErrorDetails details) =>
            const Text('Custom Error');

        config = ErrorStackConfig(customErrorWidget: customWidget);
        handler = ErrorStackHandler(config: config, storage: mockStorage);

        // In debug mode, debug widget is used regardless
        // Custom widget is only used in release mode
        final widget = handler.buildErrorWidget(errorDetails);
        expect(widget, isA<ErrorStackDebugWidget>());
      });
    });

    group('handleError', () {
      test('does not throw with valid error details', () {
        final errorDetails = FlutterErrorDetails(
          exception: Exception('Test error'),
          stack: StackTrace.fromString('''
#0      MyClass.myMethod (package:myapp/my_class.dart:42:10)
#1      main (package:myapp/main.dart:10:5)
'''),
        );

        // Should not throw
        expect(() => handler.handleError(errorDetails), returnsNormally);
      });

      test('handles null stack trace', () {
        final errorDetails = FlutterErrorDetails(
          exception: Exception('Test error'),
        );

        expect(() => handler.handleError(errorDetails), returnsNormally);
      });

      test('handles empty stack trace', () {
        final errorDetails = FlutterErrorDetails(
          exception: Exception('Test error'),
          stack: StackTrace.fromString(''),
        );

        expect(() => handler.handleError(errorDetails), returnsNormally);
      });
    });

    group('log level affects output', () {
      test('verbose level handler can be created', () {
        config = ErrorStackConfig(level: ErrorStackLogLevel.verbose);
        handler = ErrorStackHandler(config: config, storage: mockStorage);

        expect(handler.config.level, ErrorStackLogLevel.verbose);
      });

      test('minimal level handler can be created', () {
        config = ErrorStackConfig(level: ErrorStackLogLevel.minimal);
        handler = ErrorStackHandler(config: config, storage: mockStorage);

        expect(handler.config.level, ErrorStackLogLevel.minimal);
      });
    });

    group('theme persistence', () {
      testWidgets('onThemeChanged callback updates storage', (tester) async {
        final errorDetails = FlutterErrorDetails(
          exception: Exception('Test'),
        );

        final widget = handler.buildErrorWidget(errorDetails);
        final debugWidget = widget as ErrorStackDebugWidget;

        // Simulate theme change callback
        await debugWidget.onThemeChanged?.call('dark');

        expect(config.themeMode, 'dark');
        expect(mockStorage.setThemeModeCallCount, 1);
        expect(await mockStorage.getThemeMode(), 'dark');
      });

      testWidgets('theme changes are persisted to storage', (tester) async {
        final errorDetails = FlutterErrorDetails(
          exception: Exception('Test'),
        );

        final widget = handler.buildErrorWidget(errorDetails);
        final debugWidget = widget as ErrorStackDebugWidget;

        await debugWidget.onThemeChanged?.call('dark');
        await debugWidget.onThemeChanged?.call('light');

        expect(config.themeMode, 'light');
        expect(mockStorage.setThemeModeCallCount, 2);
      });
    });
  });

  group('ErrorStackReleaseWidget', () {
    testWidgets('can be instantiated', (tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test'),
      );

      final widget = ErrorStackReleaseWidget(errorDetails: errorDetails);

      expect(widget.errorDetails, errorDetails);
    });

    testWidgets('renders without errors', (tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.text('Oops, something went wrong!'), findsOneWidget);
      expect(find.text('An error occurred.'), findsOneWidget);
      expect(find.text('Please restart the app or report this issue.'),
          findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
