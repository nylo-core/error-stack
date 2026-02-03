import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/models/api_request_log.dart';

void main() {
  group('ApiRequestLog', () {
    group('constructor', () {
      test('creates with required parameters', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'https://api.example.com/users',
          durationMs: 150,
        );

        expect(log.method, 'GET');
        expect(log.url, 'https://api.example.com/users');
        expect(log.durationMs, 150);
        expect(log.id, isNotEmpty);
        expect(log.timestamp, isNotNull);
      });

      test('generates unique IDs', () {
        final log1 =
            ApiRequestLog(method: 'GET', url: 'https://a.com', durationMs: 100);
        final log2 = ApiRequestLog(
            method: 'POST', url: 'https://b.com', durationMs: 200);

        expect(log1.id, isNot(log2.id));
      });

      test('accepts custom id and timestamp', () {
        final customTime = DateTime(2024, 3, 15, 14, 30);
        final log = ApiRequestLog(
          id: 'custom-api-123',
          method: 'PUT',
          url: 'https://api.example.com',
          durationMs: 500,
          timestamp: customTime,
        );

        expect(log.id, 'custom-api-123');
        expect(log.timestamp, customTime);
      });

      test('accepts all optional parameters', () {
        final log = ApiRequestLog(
          method: 'POST',
          url: 'https://api.example.com/login',
          statusCode: 200,
          durationMs: 250,
          requestHeaders: {'Content-Type': 'application/json'},
          requestBody: {'username': 'test'},
          responseHeaders: {'X-Request-Id': 'abc123'},
          responseBody: {'token': 'xyz'},
          error: null,
        );

        expect(log.statusCode, 200);
        expect(log.requestHeaders, {'Content-Type': 'application/json'});
        expect(log.requestBody, {'username': 'test'});
        expect(log.responseHeaders, {'X-Request-Id': 'abc123'});
        expect(log.responseBody, {'token': 'xyz'});
        expect(log.error, isNull);
      });

      test('default requestHeaders is empty map', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'https://api.example.com',
          durationMs: 100,
        );

        expect(log.requestHeaders, isEmpty);
      });
    });

    group('isSuccess', () {
      test('returns true for 2xx status codes', () {
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 200, durationMs: 100)
              .isSuccess,
          true,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 201, durationMs: 100)
              .isSuccess,
          true,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 204, durationMs: 100)
              .isSuccess,
          true,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 299, durationMs: 100)
              .isSuccess,
          true,
        );
      });

      test('returns false for non-2xx status codes', () {
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 400, durationMs: 100)
              .isSuccess,
          false,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 404, durationMs: 100)
              .isSuccess,
          false,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 500, durationMs: 100)
              .isSuccess,
          false,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 199, durationMs: 100)
              .isSuccess,
          false,
        );
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: 300, durationMs: 100)
              .isSuccess,
          false,
        );
      });

      test('returns false when statusCode is null', () {
        expect(
          ApiRequestLog(
                  method: 'GET', url: 'x', statusCode: null, durationMs: 100)
              .isSuccess,
          false,
        );
      });
    });

    group('isError', () {
      test('returns false for successful requests', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'x',
          statusCode: 200,
          durationMs: 100,
        );

        expect(log.isError, false);
      });

      test('returns true for non-2xx status codes', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'x',
          statusCode: 500,
          durationMs: 100,
        );

        expect(log.isError, true);
      });

      test('returns true when error message is present', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'x',
          statusCode: 200,
          durationMs: 100,
          error: 'Network error',
        );

        expect(log.isError, true);
      });

      test('returns true when statusCode is null', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'x',
          durationMs: 100,
        );

        expect(log.isError, true);
      });
    });

    group('formattedDuration', () {
      test('returns milliseconds for durations under 1 second', () {
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 0)
              .formattedDuration,
          '0ms',
        );
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 50)
              .formattedDuration,
          '50ms',
        );
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 999)
              .formattedDuration,
          '999ms',
        );
      });

      test('returns seconds for durations 1 second or more', () {
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 1000)
              .formattedDuration,
          '1.0s',
        );
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 1500)
              .formattedDuration,
          '1.5s',
        );
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 2500)
              .formattedDuration,
          '2.5s',
        );
        expect(
          ApiRequestLog(method: 'GET', url: 'x', durationMs: 10000)
              .formattedDuration,
          '10.0s',
        );
      });
    });

    group('formattedTimestamp', () {
      test('formats timestamp as HH:MM:SS', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'x',
          durationMs: 100,
          timestamp: DateTime(2024, 5, 10, 14, 30, 45),
        );

        expect(log.formattedTimestamp, '14:30:45');
      });

      test('pads single digit values', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'x',
          durationMs: 100,
          timestamp: DateTime(2024, 1, 1, 5, 3, 9),
        );

        expect(log.formattedTimestamp, '05:03:09');
      });
    });

    group('copyWith', () {
      test('creates copy with all same values by default', () {
        final original = ApiRequestLog(
          id: 'test-id',
          method: 'POST',
          url: 'https://api.example.com',
          statusCode: 201,
          durationMs: 300,
          requestHeaders: {'Auth': 'Bearer token'},
          requestBody: {'data': 123},
          responseHeaders: {'X-Id': 'abc'},
          responseBody: {'result': 'ok'},
          error: null,
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.method, original.method);
        expect(copy.url, original.url);
        expect(copy.statusCode, original.statusCode);
        expect(copy.durationMs, original.durationMs);
        expect(copy.requestHeaders, original.requestHeaders);
        expect(copy.requestBody, original.requestBody);
        expect(copy.responseHeaders, original.responseHeaders);
        expect(copy.responseBody, original.responseBody);
        expect(copy.error, original.error);
      });

      test('allows overriding specific fields', () {
        final original = ApiRequestLog(
          method: 'GET',
          url: 'https://api.example.com',
          durationMs: 100,
        );

        final copy = original.copyWith(
          statusCode: 200,
          durationMs: 250,
          responseBody: {'success': true},
        );

        expect(copy.id, original.id);
        expect(copy.method, 'GET');
        expect(copy.url, 'https://api.example.com');
        expect(copy.statusCode, 200);
        expect(copy.durationMs, 250);
        expect(copy.responseBody, {'success': true});
      });

      test('preserves id when copying', () {
        final original = ApiRequestLog(
          id: 'fixed-id',
          method: 'DELETE',
          url: 'https://api.example.com/item/1',
          durationMs: 50,
        );

        final copy = original.copyWith(statusCode: 204);

        expect(copy.id, 'fixed-id');
      });
    });
  });
}
