import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/config/error_stack_config.dart';
import 'package:error_stack/src/config/error_stack_log_level.dart';

void main() {
  group('ErrorStackConfig', () {
    test('default values are correct', () {
      final config = ErrorStackConfig();

      expect(config.level, ErrorStackLogLevel.verbose);
      expect(config.initialRoute, '/');
      expect(config.customErrorWidget, isNull);
      expect(config.forceDebugWidget, false);
      expect(config.themeMode, 'light');
    });

    test('custom values are assigned correctly', () {
      Widget customWidget(FlutterErrorDetails details) =>
          const Text('Custom Error');

      final config = ErrorStackConfig(
        level: ErrorStackLogLevel.minimal,
        initialRoute: '/home',
        customErrorWidget: customWidget,
        forceDebugWidget: true,
        themeMode: 'dark',
      );

      expect(config.level, ErrorStackLogLevel.minimal);
      expect(config.initialRoute, '/home');
      expect(config.customErrorWidget, isNotNull);
      expect(config.forceDebugWidget, true);
      expect(config.themeMode, 'dark');
    });

    test('themeMode can be modified', () {
      final config = ErrorStackConfig();

      expect(config.themeMode, 'light');

      config.themeMode = 'dark';

      expect(config.themeMode, 'dark');
    });

    test('customErrorWidget can be called when provided', () {
      bool widgetCalled = false;
      Widget customWidget(FlutterErrorDetails details) {
        widgetCalled = true;
        return const Text('Error');
      }

      final config = ErrorStackConfig(customErrorWidget: customWidget);

      final errorDetails = FlutterErrorDetails(
        exception: Exception('Test'),
      );

      config.customErrorWidget!(errorDetails);

      expect(widgetCalled, true);
    });
  });
}
