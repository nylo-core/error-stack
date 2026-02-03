import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/models/storage_entry.dart';

void main() {
  group('StorageSource', () {
    test('has two sources', () {
      expect(StorageSource.values.length, 2);
    });

    test('contains expected values', () {
      expect(StorageSource.values, contains(StorageSource.secureStorage));
      expect(StorageSource.values, contains(StorageSource.sharedPreferences));
    });

    test('values have correct indices', () {
      expect(StorageSource.secureStorage.index, 0);
      expect(StorageSource.sharedPreferences.index, 1);
    });
  });

  group('StorageEntry', () {
    group('constructor', () {
      test('creates with required parameters', () {
        final entry = StorageEntry(
          key: 'user_token',
          value: 'abc123',
          source: StorageSource.secureStorage,
        );

        expect(entry.key, 'user_token');
        expect(entry.value, 'abc123');
        expect(entry.source, StorageSource.secureStorage);
        expect(entry.lastAccessed, isNotNull);
      });

      test('accepts custom lastAccessed timestamp', () {
        final customTime = DateTime(2024, 7, 1, 12, 0);
        final entry = StorageEntry(
          key: 'test_key',
          value: 'test_value',
          source: StorageSource.sharedPreferences,
          lastAccessed: customTime,
        );

        expect(entry.lastAccessed, customTime);
      });

      test('works with different value types', () {
        final stringEntry = StorageEntry(
          key: 'string_key',
          value: 'string_value',
          source: StorageSource.secureStorage,
        );
        expect(stringEntry.value, 'string_value');

        final intEntry = StorageEntry(
          key: 'int_key',
          value: 42,
          source: StorageSource.sharedPreferences,
        );
        expect(intEntry.value, 42);

        final boolEntry = StorageEntry(
          key: 'bool_key',
          value: true,
          source: StorageSource.sharedPreferences,
        );
        expect(boolEntry.value, true);

        final mapEntry = StorageEntry(
          key: 'map_key',
          value: {'nested': 'data'},
          source: StorageSource.secureStorage,
        );
        expect(mapEntry.value, {'nested': 'data'});

        final listEntry = StorageEntry(
          key: 'list_key',
          value: [1, 2, 3],
          source: StorageSource.sharedPreferences,
        );
        expect(listEntry.value, [1, 2, 3]);

        final nullEntry = StorageEntry(
          key: 'null_key',
          value: null,
          source: StorageSource.secureStorage,
        );
        expect(nullEntry.value, isNull);
      });
    });

    group('isSecure', () {
      test('returns true for secureStorage source', () {
        final entry = StorageEntry(
          key: 'secure_key',
          value: 'secret',
          source: StorageSource.secureStorage,
        );

        expect(entry.isSecure, true);
      });

      test('returns false for sharedPreferences source', () {
        final entry = StorageEntry(
          key: 'prefs_key',
          value: 'not_secret',
          source: StorageSource.sharedPreferences,
        );

        expect(entry.isSecure, false);
      });
    });

    group('copyWith', () {
      test('creates copy with same values by default', () {
        final customTime = DateTime(2024, 1, 1, 10, 30);
        final original = StorageEntry(
          key: 'test_key',
          value: 'original_value',
          source: StorageSource.secureStorage,
          lastAccessed: customTime,
        );

        final copy = original.copyWith();

        expect(copy.key, original.key);
        expect(copy.value, original.value);
        expect(copy.source, original.source);
        // Note: lastAccessed gets a new timestamp by default in copyWith
      });

      test('allows overriding value', () {
        final original = StorageEntry(
          key: 'counter',
          value: 5,
          source: StorageSource.sharedPreferences,
        );

        final copy = original.copyWith(value: 10);

        expect(copy.key, original.key);
        expect(copy.value, 10);
        expect(copy.source, original.source);
      });

      test('allows overriding lastAccessed', () {
        final originalTime = DateTime(2024, 1, 1);
        final newTime = DateTime(2024, 6, 15, 14, 30);

        final original = StorageEntry(
          key: 'test',
          value: 'data',
          source: StorageSource.secureStorage,
          lastAccessed: originalTime,
        );

        final copy = original.copyWith(lastAccessed: newTime);

        expect(copy.lastAccessed, newTime);
      });

      test('preserves key and source (immutable)', () {
        final original = StorageEntry(
          key: 'immutable_key',
          value: 'initial',
          source: StorageSource.secureStorage,
        );

        final copy = original.copyWith(value: 'updated');

        expect(copy.key, 'immutable_key');
        expect(copy.source, StorageSource.secureStorage);
      });

      test('can update both value and lastAccessed', () {
        final newTime = DateTime(2024, 12, 25, 0, 0);
        final original = StorageEntry(
          key: 'dual_update',
          value: 'old_value',
          source: StorageSource.sharedPreferences,
        );

        final copy = original.copyWith(
          value: 'new_value',
          lastAccessed: newTime,
        );

        expect(copy.value, 'new_value');
        expect(copy.lastAccessed, newTime);
      });
    });
  });
}
