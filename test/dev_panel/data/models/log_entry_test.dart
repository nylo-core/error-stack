import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/models/log_entry.dart';
import 'package:error_stack/src/dev_panel/data/models/log_level.dart';

void main() {
  group('LogEntry', () {
    group('constructor', () {
      test('creates with required parameters', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test message',
        );

        expect(entry.level, DevPanelLogLevel.info);
        expect(entry.message, 'Test message');
        expect(entry.id, isNotEmpty);
        expect(entry.timestamp, isNotNull);
      });

      test('generates unique IDs', () {
        final entry1 = LogEntry(level: DevPanelLogLevel.info, message: 'Msg 1');
        final entry2 = LogEntry(level: DevPanelLogLevel.info, message: 'Msg 2');

        expect(entry1.id, isNot(entry2.id));
      });

      test('accepts custom id', () {
        final entry = LogEntry(
          id: 'custom-id-123',
          level: DevPanelLogLevel.debug,
          message: 'Test',
        );

        expect(entry.id, 'custom-id-123');
      });

      test('accepts custom timestamp', () {
        final customTime = DateTime(2024, 1, 15, 10, 30, 45);
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test',
          timestamp: customTime,
        );

        expect(entry.timestamp, customTime);
      });

      test('accepts optional parameters', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.error,
          message: 'Error occurred',
          tag: 'Network',
          metadata: {'userId': 123, 'requestId': 'abc'},
          stackTrace: 'at line 42...',
        );

        expect(entry.tag, 'Network');
        expect(entry.metadata, {'userId': 123, 'requestId': 'abc'});
        expect(entry.stackTrace, 'at line 42...');
      });
    });

    group('factory constructors', () {
      test('LogEntry.debug creates debug level entry', () {
        final entry = LogEntry.debug('Debug message', tag: 'Test');

        expect(entry.level, DevPanelLogLevel.debug);
        expect(entry.message, 'Debug message');
        expect(entry.tag, 'Test');
      });

      test('LogEntry.info creates info level entry', () {
        final entry = LogEntry.info('Info message');

        expect(entry.level, DevPanelLogLevel.info);
        expect(entry.message, 'Info message');
      });

      test('LogEntry.warning creates warning level entry', () {
        final entry = LogEntry.warning(
          'Warning message',
          metadata: {'reason': 'test'},
        );

        expect(entry.level, DevPanelLogLevel.warning);
        expect(entry.message, 'Warning message');
        expect(entry.metadata, {'reason': 'test'});
      });

      test('LogEntry.error creates error level entry with stackTrace', () {
        final entry = LogEntry.error(
          'Error message',
          tag: 'Fatal',
          stackTrace: 'Stack trace here',
          metadata: {'code': 500},
        );

        expect(entry.level, DevPanelLogLevel.error);
        expect(entry.message, 'Error message');
        expect(entry.tag, 'Fatal');
        expect(entry.stackTrace, 'Stack trace here');
        expect(entry.metadata, {'code': 500});
      });
    });

    group('levelName', () {
      test('returns uppercase level name', () {
        expect(
          LogEntry(level: DevPanelLogLevel.debug, message: 'x').levelName,
          'DEBUG',
        );
        expect(
          LogEntry(level: DevPanelLogLevel.info, message: 'x').levelName,
          'INFO',
        );
        expect(
          LogEntry(level: DevPanelLogLevel.warning, message: 'x').levelName,
          'WARNING',
        );
        expect(
          LogEntry(level: DevPanelLogLevel.error, message: 'x').levelName,
          'ERROR',
        );
      });
    });

    group('formattedTimestamp', () {
      test('formats timestamp as HH:MM:SS', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test',
          timestamp: DateTime(2024, 1, 15, 9, 5, 3),
        );

        expect(entry.formattedTimestamp, '09:05:03');
      });

      test('pads single digit values', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test',
          timestamp: DateTime(2024, 1, 1, 1, 2, 3),
        );

        expect(entry.formattedTimestamp, '01:02:03');
      });

      test('handles midnight', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test',
          timestamp: DateTime(2024, 1, 1, 0, 0, 0),
        );

        expect(entry.formattedTimestamp, '00:00:00');
      });

      test('handles noon', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test',
          timestamp: DateTime(2024, 1, 1, 12, 30, 45),
        );

        expect(entry.formattedTimestamp, '12:30:45');
      });
    });
  });
}
