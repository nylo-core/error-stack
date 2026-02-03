import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/dev_panel_config.dart';

void main() {
  group('DevPanelConfig', () {
    group('constructor', () {
      test('default values are correct', () {
        const config = DevPanelConfig();

        expect(config.enableApiLogging, true);
        expect(config.enableConsoleLogging, true);
        expect(config.enableRouteTracking, true);
        expect(config.apiLogLimit, 100);
        expect(config.consoleLogLimit, 100);
        expect(config.routeHistoryLimit, 50);
      });

      test('custom values are assigned correctly', () {
        const config = DevPanelConfig(
          enableApiLogging: false,
          enableConsoleLogging: false,
          enableRouteTracking: false,
          apiLogLimit: 50,
          consoleLogLimit: 200,
          routeHistoryLimit: 25,
        );

        expect(config.enableApiLogging, false);
        expect(config.enableConsoleLogging, false);
        expect(config.enableRouteTracking, false);
        expect(config.apiLogLimit, 50);
        expect(config.consoleLogLimit, 200);
        expect(config.routeHistoryLimit, 25);
      });
    });

    group('copyWith', () {
      test('creates copy with same values by default', () {
        const original = DevPanelConfig(
          enableApiLogging: false,
          apiLogLimit: 75,
        );

        final copy = original.copyWith();

        expect(copy.enableApiLogging, original.enableApiLogging);
        expect(copy.enableConsoleLogging, original.enableConsoleLogging);
        expect(copy.enableRouteTracking, original.enableRouteTracking);
        expect(copy.apiLogLimit, original.apiLogLimit);
        expect(copy.consoleLogLimit, original.consoleLogLimit);
        expect(copy.routeHistoryLimit, original.routeHistoryLimit);
      });

      test('allows overriding enableApiLogging', () {
        const original = DevPanelConfig(enableApiLogging: true);

        final copy = original.copyWith(enableApiLogging: false);

        expect(copy.enableApiLogging, false);
      });

      test('allows overriding enableConsoleLogging', () {
        const original = DevPanelConfig(enableConsoleLogging: true);

        final copy = original.copyWith(enableConsoleLogging: false);

        expect(copy.enableConsoleLogging, false);
      });

      test('allows overriding enableRouteTracking', () {
        const original = DevPanelConfig(enableRouteTracking: true);

        final copy = original.copyWith(enableRouteTracking: false);

        expect(copy.enableRouteTracking, false);
      });

      test('allows overriding apiLogLimit', () {
        const original = DevPanelConfig(apiLogLimit: 100);

        final copy = original.copyWith(apiLogLimit: 500);

        expect(copy.apiLogLimit, 500);
      });

      test('allows overriding consoleLogLimit', () {
        const original = DevPanelConfig(consoleLogLimit: 100);

        final copy = original.copyWith(consoleLogLimit: 300);

        expect(copy.consoleLogLimit, 300);
      });

      test('allows overriding routeHistoryLimit', () {
        const original = DevPanelConfig(routeHistoryLimit: 50);

        final copy = original.copyWith(routeHistoryLimit: 100);

        expect(copy.routeHistoryLimit, 100);
      });

      test('allows overriding multiple fields at once', () {
        const original = DevPanelConfig();

        final copy = original.copyWith(
          enableApiLogging: false,
          enableConsoleLogging: false,
          apiLogLimit: 250,
        );

        expect(copy.enableApiLogging, false);
        expect(copy.enableConsoleLogging, false);
        expect(copy.enableRouteTracking, true); // Unchanged
        expect(copy.apiLogLimit, 250);
        expect(copy.consoleLogLimit, 100); // Unchanged
      });
    });

    group('const constructor', () {
      test('can be used as const', () {
        const config1 = DevPanelConfig();
        const config2 = DevPanelConfig();

        expect(identical(config1, config2), true);
      });

      test('different values are not identical', () {
        const config1 = DevPanelConfig(apiLogLimit: 100);
        const config2 = DevPanelConfig(apiLogLimit: 200);

        expect(identical(config1, config2), false);
      });
    });
  });
}
