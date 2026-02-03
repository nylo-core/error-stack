import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/interceptors/error_stack_dio_interceptor.dart';
import 'package:error_stack/src/dev_panel/data/dev_panel_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorStackDioInterceptor', () {
    setUp(() {
      // Initialize the store before each test
      DevPanelStore.init();
      DevPanelStore.instance.clearApiLogs();
    });

    group('constructor', () {
      test('creates with default parameters', () {
        final interceptor = ErrorStackDioInterceptor();

        expect(interceptor.enabled, true);
        expect(interceptor.filter, isNull);
      });

      test('accepts enabled parameter', () {
        final interceptor = ErrorStackDioInterceptor(enabled: false);

        expect(interceptor.enabled, false);
      });

      test('accepts filter parameter', () {
        final interceptor = ErrorStackDioInterceptor(
          filter: (options) => true,
        );

        expect(interceptor.filter, isNotNull);
      });
    });

    group('onRequest', () {
      test('adds request time to extras when enabled', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestHandler();

        interceptor.onRequest(options, handler);

        expect(options.extra['_error_stack_request_time_'], isNotNull);
        expect(options.extra['_error_stack_request_time_'], isA<int>());
        expect(handler.nextCalled, true);
      });

      test('skips adding time when disabled', () {
        final interceptor = ErrorStackDioInterceptor(enabled: false);
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestHandler();

        interceptor.onRequest(options, handler);

        expect(options.extra['_error_stack_request_time_'], isNull);
        expect(handler.nextCalled, true);
      });

      test('skips when filter returns false', () {
        final interceptor = ErrorStackDioInterceptor(
          filter: (options) => false,
        );
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestHandler();

        interceptor.onRequest(options, handler);

        expect(options.extra['_error_stack_request_time_'], isNull);
        expect(handler.nextCalled, true);
      });

      test('processes when filter returns true', () {
        final interceptor = ErrorStackDioInterceptor(
          filter: (options) => true,
        );
        final options = RequestOptions(path: '/test');
        final handler = _MockRequestHandler();

        interceptor.onRequest(options, handler);

        expect(options.extra['_error_stack_request_time_'], isNotNull);
        expect(handler.nextCalled, true);
      });

      test('filter receives correct options', () {
        RequestOptions? receivedOptions;
        final interceptor = ErrorStackDioInterceptor(
          filter: (options) {
            receivedOptions = options;
            return true;
          },
        );
        final options = RequestOptions(
          path: '/api/users',
          method: 'POST',
        );
        final handler = _MockRequestHandler();

        interceptor.onRequest(options, handler);

        expect(receivedOptions, options);
        expect(receivedOptions?.path, '/api/users');
        expect(receivedOptions?.method, 'POST');
      });
    });

    group('onResponse', () {
      test('logs successful response to DevPanelStore', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(
          path: '/test',
          method: 'GET',
          baseUrl: 'https://api.example.com',
        );
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        expect(handler.nextCalled, true);
        expect(DevPanelStore.instance.apiLogs.length, 1);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.method, 'GET');
        expect(log.statusCode, 200);
        expect(log.responseBody, {'success': true});
      });

      test('does not log when request time is missing', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        // Not adding request time to extras

        final response = Response(
          requestOptions: options,
          statusCode: 200,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        expect(handler.nextCalled, true);
        expect(DevPanelStore.instance.apiLogs.length, 0);
      });

      test('calculates duration correctly', () async {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        final startTime = DateTime.now().millisecondsSinceEpoch;
        options.extra['_error_stack_request_time_'] = startTime;

        // Small delay to ensure measurable duration
        await Future.delayed(const Duration(milliseconds: 10));

        final response = Response(
          requestOptions: options,
          statusCode: 200,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.durationMs, greaterThanOrEqualTo(10));
      });
    });

    group('onError', () {
      test('logs error response to DevPanelStore', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(
          path: '/test',
          method: 'POST',
          baseUrl: 'https://api.example.com',
        );
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final error = DioException(
          requestOptions: options,
          message: 'Connection failed',
          response: Response(
            requestOptions: options,
            statusCode: 500,
            data: {'error': 'Internal server error'},
          ),
        );
        final handler = _MockErrorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, true);
        expect(DevPanelStore.instance.apiLogs.length, 1);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.method, 'POST');
        expect(log.statusCode, 500);
        expect(log.error, 'Connection failed');
        expect(log.responseBody, {'error': 'Internal server error'});
      });

      test('handles error without response', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final error = DioException(
          requestOptions: options,
          message: 'Network error',
          // No response
        );
        final handler = _MockErrorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, true);
        expect(DevPanelStore.instance.apiLogs.length, 1);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.statusCode, isNull);
        expect(log.error, 'Network error');
        expect(log.responseHeaders, isNull);
      });

      test('does not log when request time is missing', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        // Not adding request time

        final error = DioException(
          requestOptions: options,
          message: 'Error',
        );
        final handler = _MockErrorHandler();

        interceptor.onError(error, handler);

        expect(handler.nextCalled, true);
        expect(DevPanelStore.instance.apiLogs.length, 0);
      });
    });

    group('header conversion', () {
      test('converts request headers correctly', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(
          path: '/test',
          headers: {
            'Authorization': 'Bearer token123',
            'Content-Type': 'application/json',
          },
        );
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.requestHeaders['Authorization'], 'Bearer token123');
        expect(log.requestHeaders['Content-Type'], 'application/json');
      });
    });

    group('body sanitization', () {
      test('preserves normal response body', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
          data: {'users': [], 'count': 0},
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.responseBody, {'users': [], 'count': 0});
      });

      test('truncates very large string responses', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        // Create a string larger than 50000 characters
        final largeString = 'x' * 60000;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
          data: largeString,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.responseBody, contains('[truncated]'));
        expect((log.responseBody as String).length, lessThan(60000));
      });

      test('handles null body', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(path: '/test');
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 204,
          data: null,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.responseBody, isNull);
      });
    });

    group('URL handling', () {
      test('captures full URL with base URL', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(
          path: '/users/123',
          baseUrl: 'https://api.example.com',
        );
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.url, 'https://api.example.com/users/123');
      });

      test('handles query parameters', () {
        final interceptor = ErrorStackDioInterceptor();
        final options = RequestOptions(
          path: '/search',
          baseUrl: 'https://api.example.com',
          queryParameters: {'q': 'test', 'page': 1},
        );
        options.extra['_error_stack_request_time_'] =
            DateTime.now().millisecondsSinceEpoch;

        final response = Response(
          requestOptions: options,
          statusCode: 200,
        );
        final handler = _MockResponseHandler();

        interceptor.onResponse(response, handler);

        final log = DevPanelStore.instance.apiLogs.first;
        expect(log.url, contains('q=test'));
        expect(log.url, contains('page=1'));
      });
    });
  });
}

// Mock handlers for testing
class _MockRequestHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class _MockResponseHandler extends ResponseInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(Response response) {
    nextCalled = true;
  }
}

class _MockErrorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(DioException err) {
    nextCalled = true;
  }
}
