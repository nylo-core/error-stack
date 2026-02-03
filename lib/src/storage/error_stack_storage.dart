import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'error_stack_storage_base.dart';

/// Default storage implementation using [FlutterSecureStorage].
///
/// Provides secure, encrypted storage for ErrorStack preferences
/// including theme mode and other settings.
class ErrorStackStorage implements ErrorStackStorageBase {
  /// The underlying secure storage instance.
  final FlutterSecureStorage _storage;

  /// Creates an [ErrorStackStorage] with optional custom storage instance.
  ///
  /// If [storage] is not provided, creates a default instance with
  /// Android-specific options for encryption.
  ErrorStackStorage({FlutterSecureStorage? storage})
      : _storage =
            storage ?? const FlutterSecureStorage(aOptions: AndroidOptions());

  @override
  Future<String?> getThemeMode() async {
    return _storage.read(
      key: '${ErrorStackStorageBase.storageKey}_theme_mode',
    );
  }

  @override
  Future<void> setThemeMode(String mode) async {
    await _storage.write(
      key: '${ErrorStackStorageBase.storageKey}_theme_mode',
      value: mode,
    );
  }
}
