/// Sentinel value for distinguishing between "not provided" and "explicitly null".
const _undefined = Object();

/// Represents a logged HTTP API request and its response.
///
/// Captures all relevant information about an HTTP request including
/// timing, headers, body, and response data for debugging purposes.
class ApiRequestLog {
  /// Unique identifier for this log entry.
  final String id;

  /// HTTP method (GET, POST, PUT, DELETE, etc.).
  final String method;

  /// The full request URL.
  final String url;

  /// HTTP status code of the response (null if request failed/pending).
  final int? statusCode;

  /// Request duration in milliseconds.
  final int durationMs;

  /// Timestamp when the request was initiated.
  final DateTime timestamp;

  /// Request headers as key-value pairs.
  final Map<String, dynamic> requestHeaders;

  /// Request body (may be null for GET requests).
  final dynamic requestBody;

  /// Response headers as key-value pairs.
  final Map<String, dynamic>? responseHeaders;

  /// Response body (parsed JSON or raw string).
  final dynamic responseBody;

  /// Error message if the request failed.
  final String? error;

  /// Creates an [ApiRequestLog] with the specified details.
  ApiRequestLog({
    String? id,
    required this.method,
    required this.url,
    this.statusCode,
    required this.durationMs,
    DateTime? timestamp,
    this.requestHeaders = const {},
    this.requestBody,
    this.responseHeaders,
    this.responseBody,
    this.error,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  /// Whether the request completed successfully (2xx status code).
  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Whether the request failed (non-2xx or error).
  bool get isError => !isSuccess || error != null;

  /// Formatted duration string (e.g., "123ms" or "1.5s").
  String get formattedDuration {
    if (durationMs < 1000) {
      return '${durationMs}ms';
    }
    return '${(durationMs / 1000).toStringAsFixed(1)}s';
  }

  /// Formatted timestamp string.
  String get formattedTimestamp {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Creates a copy with modified fields.
  ///
  /// Nullable fields can be explicitly set to null by passing null.
  ApiRequestLog copyWith({
    String? method,
    String? url,
    Object? statusCode = _undefined,
    int? durationMs,
    DateTime? timestamp,
    Map<String, dynamic>? requestHeaders,
    Object? requestBody = _undefined,
    Object? responseHeaders = _undefined,
    Object? responseBody = _undefined,
    Object? error = _undefined,
  }) {
    return ApiRequestLog(
      id: id,
      method: method ?? this.method,
      url: url ?? this.url,
      statusCode:
          statusCode == _undefined ? this.statusCode : statusCode as int?,
      durationMs: durationMs ?? this.durationMs,
      timestamp: timestamp ?? this.timestamp,
      requestHeaders: requestHeaders ?? this.requestHeaders,
      requestBody: requestBody == _undefined ? this.requestBody : requestBody,
      responseHeaders: responseHeaders == _undefined
          ? this.responseHeaders
          : responseHeaders as Map<String, dynamic>?,
      responseBody:
          responseBody == _undefined ? this.responseBody : responseBody,
      error: error == _undefined ? this.error : error as String?,
    );
  }

  static int _idCounter = 0;
  static String _generateId() =>
      'api_${DateTime.now().millisecondsSinceEpoch}_${++_idCounter}';
}
