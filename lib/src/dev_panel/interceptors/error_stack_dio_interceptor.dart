// ignore_for_file: depend_on_referenced_packages
import 'package:dio/dio.dart';
import '../data/dev_panel_store.dart';
import '../data/models/api_request_log.dart';

/// Key used to store request timestamp in extras.
const _kRequestTimeKey = '_error_stack_request_time_';

/// Dio interceptor that captures request/response data for the dev panel.
///
/// Usage:
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(ErrorStackDioInterceptor());
/// ```
class ErrorStackDioInterceptor extends Interceptor {
  /// Whether the interceptor is enabled.
  final bool enabled;

  /// Optional filter function to exclude certain requests.
  /// Return true to log the request, false to skip it.
  final bool Function(RequestOptions options)? filter;

  /// Creates an [ErrorStackDioInterceptor].
  ///
  /// [enabled] - Whether capturing is enabled (default: true).
  /// [filter] - Optional filter to exclude certain requests from capture.
  ErrorStackDioInterceptor({
    this.enabled = true,
    this.filter,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled || (filter != null && !filter!(options))) {
      handler.next(options);
      return;
    }

    final requestTime = DateTime.now();

    // Store timing info in extras for response/error handlers
    options.extra[_kRequestTimeKey] = requestTime.millisecondsSinceEpoch;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _handleCompletion(
      response.requestOptions,
      statusCode: response.statusCode,
      responseData: response.data,
      responseHeaders: _convertDioHeaders(response.headers),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _handleCompletion(
      err.requestOptions,
      statusCode: err.response?.statusCode,
      responseData: err.response?.data,
      responseHeaders: err.response != null
          ? _convertDioHeaders(err.response!.headers)
          : null,
      isError: true,
      errorMessage: err.message,
    );

    handler.next(err);
  }

  void _handleCompletion(
    RequestOptions options, {
    int? statusCode,
    dynamic responseData,
    Map<String, dynamic>? responseHeaders,
    bool isError = false,
    String? errorMessage,
  }) {
    final requestTimeMs = options.extra[_kRequestTimeKey] as int?;
    if (requestTimeMs == null) return;

    final requestTime = DateTime.fromMillisecondsSinceEpoch(requestTimeMs);
    final responseTime = DateTime.now();
    final durationMs = responseTime.difference(requestTime).inMilliseconds;

    final log = ApiRequestLog(
      method: options.method,
      url: options.uri.toString(),
      statusCode: statusCode,
      durationMs: durationMs,
      timestamp: requestTime,
      requestHeaders: _convertHeaders(options.headers),
      requestBody: _sanitizeBody(options.data),
      responseHeaders: responseHeaders,
      responseBody: _sanitizeBody(responseData),
      error: isError ? errorMessage : null,
    );

    DevPanelStore.instance.logApiRequest(log);
  }

  /// Convert request headers to a simple Map.
  Map<String, dynamic> _convertHeaders(Map<String, dynamic> headers) {
    return Map<String, dynamic>.from(headers);
  }

  /// Convert Dio Headers to a simple Map.
  Map<String, dynamic> _convertDioHeaders(Headers headers) {
    final map = <String, dynamic>{};
    headers.forEach((name, values) {
      map[name] = values.length == 1 ? values.first : values;
    });
    return map;
  }

  /// Sanitize request/response body for storage.
  dynamic _sanitizeBody(dynamic data) {
    if (data == null) return null;
    if (data is FormData) {
      return {
        'type': 'FormData',
        'fields':
            data.fields.map((e) => {'key': e.key, 'value': e.value}).toList(),
        'files': data.files
            .map((e) => {'key': e.key, 'filename': e.value.filename})
            .toList(),
      };
    }
    // For very large responses, truncate
    if (data is String && data.length > 50000) {
      return '${data.substring(0, 50000)}... [truncated]';
    }
    return data;
  }
}
