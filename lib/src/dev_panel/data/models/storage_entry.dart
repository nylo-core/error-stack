/// Sentinel value for distinguishing between "not provided" and "explicitly null".
const _undefined = Object();

/// The source of stored data.
enum StorageSource {
  /// Flutter Secure Storage (encrypted).
  secureStorage,

  /// Shared Preferences (unencrypted).
  sharedPreferences,
}

/// Represents a reference to a stored value.
///
/// Used to display and manage local storage data in the dev panel.
class StorageEntry {
  /// The storage key.
  final String key;

  /// The stored value (may be any type).
  final dynamic value;

  /// Which storage backend this entry came from.
  final StorageSource source;

  /// Timestamp when this entry was last read/updated.
  final DateTime lastAccessed;

  /// Creates a [StorageEntry] with the specified details.
  StorageEntry({
    required this.key,
    required this.value,
    required this.source,
    DateTime? lastAccessed,
  }) : lastAccessed = lastAccessed ?? DateTime.now();

  /// Whether this entry is from secure storage.
  bool get isSecure => source == StorageSource.secureStorage;

  /// Creates a copy with a new value.
  ///
  /// The [value] parameter can be explicitly set to null.
  StorageEntry copyWith({Object? value = _undefined, DateTime? lastAccessed}) {
    return StorageEntry(
      key: key,
      value: value == _undefined ? this.value : value,
      source: source,
      lastAccessed: lastAccessed ?? DateTime.now(),
    );
  }
}
