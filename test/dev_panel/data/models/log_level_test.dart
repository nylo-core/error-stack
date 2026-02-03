import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/models/log_level.dart';

void main() {
  group('DevPanelLogLevel', () {
    test('has four log levels', () {
      expect(DevPanelLogLevel.values.length, 4);
    });

    test('contains expected values', () {
      expect(DevPanelLogLevel.values, contains(DevPanelLogLevel.debug));
      expect(DevPanelLogLevel.values, contains(DevPanelLogLevel.info));
      expect(DevPanelLogLevel.values, contains(DevPanelLogLevel.warning));
      expect(DevPanelLogLevel.values, contains(DevPanelLogLevel.error));
    });

    test('values are in correct order (severity)', () {
      expect(DevPanelLogLevel.debug.index, 0);
      expect(DevPanelLogLevel.info.index, 1);
      expect(DevPanelLogLevel.warning.index, 2);
      expect(DevPanelLogLevel.error.index, 3);
    });

    test('name property returns correct strings', () {
      expect(DevPanelLogLevel.debug.name, 'debug');
      expect(DevPanelLogLevel.info.name, 'info');
      expect(DevPanelLogLevel.warning.name, 'warning');
      expect(DevPanelLogLevel.error.name, 'error');
    });
  });
}
