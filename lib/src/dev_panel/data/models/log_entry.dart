import 'log_level.dart';

/// Represents a console log entry.
///
/// Captures log messages with severity levels and timestamps
/// for debugging and monitoring purposes.
class LogEntry {
  /// Unique identifier for this log entry.
  final String id;

  /// The severity level of this log entry.
  final DevPanelLogLevel level;

  /// The log message content.
  final String message;

  /// Timestamp when the log was created.
  final DateTime timestamp;

  /// Optional tag/category for filtering logs.
  final String? tag;

  /// Optional additional data attached to the log.
  final Map<String, dynamic>? metadata;

  /// Stack trace if this log was created from an error.
  final String? stackTrace;

  /// Creates a [LogEntry] with the specified details.
  LogEntry({
    String? id,
    required this.level,
    required this.message,
    DateTime? timestamp,
    this.tag,
    this.metadata,
    this.stackTrace,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  /// Convenience constructor for debug logs.
  factory LogEntry.debug(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    return LogEntry(
        level: DevPanelLogLevel.debug,
        message: message,
        tag: tag,
        metadata: metadata);
  }

  /// Convenience constructor for info logs.
  factory LogEntry.info(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    return LogEntry(
        level: DevPanelLogLevel.info,
        message: message,
        tag: tag,
        metadata: metadata);
  }

  /// Convenience constructor for warning logs.
  factory LogEntry.warning(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    return LogEntry(
        level: DevPanelLogLevel.warning,
        message: message,
        tag: tag,
        metadata: metadata);
  }

  /// Convenience constructor for error logs.
  factory LogEntry.error(String message,
      {String? tag, String? stackTrace, Map<String, dynamic>? metadata}) {
    return LogEntry(
      level: DevPanelLogLevel.error,
      message: message,
      tag: tag,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }

  /// Human-readable level name.
  String get levelName => level.name.toUpperCase();

  /// Formatted timestamp string.
  String get formattedTimestamp {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Human-readable relative time (e.g., "19 secs ago").
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} secs ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  static int _idCounter = 0;
  static String _generateId() =>
      'log_${DateTime.now().millisecondsSinceEpoch}_${++_idCounter}';
}
