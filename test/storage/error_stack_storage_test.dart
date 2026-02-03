import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/storage/error_stack_storage.dart';
import 'package:error_stack/src/storage/error_stack_storage_base.dart';

void main() {
  group('ErrorStackStorage', () {
    group('constructor', () {
      test('creates instance successfully', () {
        final storage = ErrorStackStorage();

        expect(storage, isNotNull);
        expect(storage, isA<ErrorStackStorageBase>());
      });
    });

    group('implements ErrorStackStorageBase', () {
      test('has getThemeMode method', () {
        final storage = ErrorStackStorage();

        expect(storage.getThemeMode, isA<Function>());
      });

      test('has setThemeMode method', () {
        final storage = ErrorStackStorage();

        expect(storage.setThemeMode, isA<Function>());
      });
    });

    group('storage key', () {
      test('uses correct storage key prefix', () {
        expect(
          ErrorStackStorageBase.storageKey,
          'error_stack',
        );
      });

      test('storage key is a valid string', () {
        expect(ErrorStackStorageBase.storageKey, isA<String>());
        expect(ErrorStackStorageBase.storageKey, isNotEmpty);
      });
    });

    group('interface compliance', () {
      test('can be used as ErrorStackStorageBase', () {
        ErrorStackStorageBase storage = ErrorStackStorage();

        expect(storage, isA<ErrorStackStorageBase>());
      });
    });
  });
}
