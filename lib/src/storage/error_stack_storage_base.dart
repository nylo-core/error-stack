/// Abstract interface for ErrorStack storage operations.
///
/// Implement this interface to provide custom storage backends
/// for testing or alternative persistence mechanisms.
abstract class ErrorStackStorageBase {
  /// The base key prefix used for all ErrorStack storage entries.
  static const String storageKey = 'error_stack';

  /// Retrieves the stored theme mode.
  ///
  /// Returns the theme mode string ('light' or 'dark'), or null if not set.
  Future<String?> getThemeMode();

  /// Persists the theme mode.
  ///
  /// [mode] should be either 'light' or 'dark'.
  Future<void> setThemeMode(String mode);
}
