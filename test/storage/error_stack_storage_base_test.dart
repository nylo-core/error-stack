import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/storage/error_stack_storage_base.dart';

/// Mock implementation of ErrorStackStorageBase for testing
class MockErrorStackStorage implements ErrorStackStorageBase {
  String? _themeMode;

  @override
  Future<String?> getThemeMode() async => _themeMode;

  @override
  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
  }
}

void main() {
  group('ErrorStackStorageBase', () {
    test('storageKey constant has expected value', () {
      expect(ErrorStackStorageBase.storageKey, 'error_stack');
    });

    group('MockErrorStackStorage', () {
      late MockErrorStackStorage storage;

      setUp(() {
        storage = MockErrorStackStorage();
      });

      test('getThemeMode returns null when not set', () async {
        final result = await storage.getThemeMode();
        expect(result, isNull);
      });

      test('setThemeMode stores value correctly', () async {
        await storage.setThemeMode('dark');
        final result = await storage.getThemeMode();
        expect(result, 'dark');
      });

      test('setThemeMode can update value', () async {
        await storage.setThemeMode('dark');
        await storage.setThemeMode('light');
        final result = await storage.getThemeMode();
        expect(result, 'light');
      });
    });
  });
}
