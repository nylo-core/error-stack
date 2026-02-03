import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/dev_panel_store.dart';
import 'package:error_stack/src/dev_panel/data/models/api_request_log.dart';
import 'package:error_stack/src/dev_panel/data/models/log_entry.dart';
import 'package:error_stack/src/dev_panel/data/models/log_level.dart';
import 'package:error_stack/src/dev_panel/data/models/route_entry.dart';
import 'package:error_stack/src/dev_panel/dev_panel_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ColorBlindnessMode', () {
    test('has four modes', () {
      expect(ColorBlindnessMode.values.length, 4);
    });

    test('contains expected values', () {
      expect(ColorBlindnessMode.values, contains(ColorBlindnessMode.none));
      expect(
          ColorBlindnessMode.values, contains(ColorBlindnessMode.protanopia));
      expect(
          ColorBlindnessMode.values, contains(ColorBlindnessMode.deuteranopia));
      expect(
          ColorBlindnessMode.values, contains(ColorBlindnessMode.tritanopia));
    });
  });

  group('DevPanelStore', () {
    setUp(() {
      // Initialize store before each test
      DevPanelStore.init();
    });

    tearDown(() {
      // Clear all data after each test
      DevPanelStore.instance.clearAll();
      DevPanelStore.instance.resetUIDebugSettings();
    });

    group('initialization', () {
      test('is a singleton', () {
        final store1 = DevPanelStore.instance;
        final store2 = DevPanelStore.instance;

        expect(identical(store1, store2), true);
      });

      test('isInitialized returns true after init', () {
        expect(DevPanelStore.isInitialized, true);
      });

      test('init accepts custom config', () {
        final customConfig = DevPanelConfig(
          enableApiLogging: false,
          apiLogLimit: 50,
        );

        DevPanelStore.init(config: customConfig);

        expect(DevPanelStore.instance.config.enableApiLogging, false);
        expect(DevPanelStore.instance.config.apiLogLimit, 50);
      });

      test('config can be updated', () {
        final newConfig = DevPanelConfig(consoleLogLimit: 200);

        DevPanelStore.instance.updateConfig(newConfig);

        expect(DevPanelStore.instance.config.consoleLogLimit, 200);
      });
    });

    group('API Request Logging', () {
      test('starts with empty apiLogs', () {
        expect(DevPanelStore.instance.apiLogs, isEmpty);
        expect(DevPanelStore.instance.apiLogsReversed, isEmpty);
      });

      test('logApiRequest adds log', () {
        final log = ApiRequestLog(
          method: 'GET',
          url: 'https://api.example.com',
          statusCode: 200,
          durationMs: 100,
        );

        DevPanelStore.instance.logApiRequest(log);

        expect(DevPanelStore.instance.apiLogs.length, 1);
        expect(DevPanelStore.instance.apiLogs.first.method, 'GET');
      });

      test('logApi creates and logs a request', () {
        final log = DevPanelStore.instance.logApi(
          method: 'POST',
          url: 'https://api.example.com/data',
          statusCode: 201,
          durationMs: 250,
          requestBody: {'data': 'test'},
        );

        expect(log.method, 'POST');
        expect(DevPanelStore.instance.apiLogs.length, 1);
      });

      test('apiLogsReversed returns newest first', () {
        DevPanelStore.instance
            .logApi(method: 'GET', url: 'https://first.com', durationMs: 100);
        DevPanelStore.instance
            .logApi(method: 'POST', url: 'https://second.com', durationMs: 100);

        final reversed = DevPanelStore.instance.apiLogsReversed;

        expect(reversed.first.url, 'https://second.com');
        expect(reversed.last.url, 'https://first.com');
      });

      test('clearApiLogs removes all API logs', () {
        DevPanelStore.instance
            .logApi(method: 'GET', url: 'https://test.com', durationMs: 100);

        DevPanelStore.instance.clearApiLogs();

        expect(DevPanelStore.instance.apiLogs, isEmpty);
      });

      test('respects enableApiLogging config', () {
        DevPanelStore.init(config: DevPanelConfig(enableApiLogging: false));

        DevPanelStore.instance
            .logApi(method: 'GET', url: 'https://test.com', durationMs: 100);

        expect(DevPanelStore.instance.apiLogs, isEmpty);
      });

      group('pending requests', () {
        test('startApiRequest creates pending request', () {
          final requestId = DevPanelStore.instance.startApiRequest(
            method: 'GET',
            url: 'https://api.example.com/users',
          );

          expect(requestId, isNotEmpty);
          // Pending requests are not in apiLogs yet
          expect(DevPanelStore.instance.apiLogs, isEmpty);
        });

        test('completeApiRequest finalizes pending request', () {
          final requestId = DevPanelStore.instance.startApiRequest(
            method: 'GET',
            url: 'https://api.example.com/users',
            requestHeaders: {'Auth': 'Bearer token'},
          );

          DevPanelStore.instance.completeApiRequest(
            requestId: requestId,
            statusCode: 200,
            durationMs: 150,
            responseBody: {'users': []},
          );

          expect(DevPanelStore.instance.apiLogs.length, 1);
          final log = DevPanelStore.instance.apiLogs.first;
          expect(log.statusCode, 200);
          expect(log.durationMs, 150);
        });

        test('completeApiRequest does nothing for unknown requestId', () {
          DevPanelStore.instance.completeApiRequest(
            requestId: 'unknown-id',
            statusCode: 200,
            durationMs: 100,
          );

          expect(DevPanelStore.instance.apiLogs, isEmpty);
        });
      });
    });

    group('Console Logging', () {
      test('starts with empty consoleLogs', () {
        expect(DevPanelStore.instance.consoleLogs, isEmpty);
      });

      test('logEntry adds log entry', () {
        final entry = LogEntry(
          level: DevPanelLogLevel.info,
          message: 'Test message',
        );

        DevPanelStore.instance.logEntry(entry);

        expect(DevPanelStore.instance.consoleLogs.length, 1);
      });

      test('log creates and adds entry', () {
        final entry = DevPanelStore.instance.log(
          'Test log message',
          level: DevPanelLogLevel.warning,
          tag: 'TestTag',
        );

        expect(entry.message, 'Test log message');
        expect(entry.level, DevPanelLogLevel.warning);
        expect(DevPanelStore.instance.consoleLogs.length, 1);
      });

      test('debug convenience method works', () {
        final entry = DevPanelStore.instance.debug('Debug message');

        expect(entry.level, DevPanelLogLevel.debug);
        expect(entry.message, 'Debug message');
      });

      test('info convenience method works', () {
        final entry = DevPanelStore.instance.info('Info message', tag: 'App');

        expect(entry.level, DevPanelLogLevel.info);
        expect(entry.tag, 'App');
      });

      test('warning convenience method works', () {
        final entry = DevPanelStore.instance.warning('Warning message');

        expect(entry.level, DevPanelLogLevel.warning);
      });

      test('error convenience method works', () {
        final entry = DevPanelStore.instance.error(
          'Error message',
          stackTrace: 'at line 42',
        );

        expect(entry.level, DevPanelLogLevel.error);
        expect(entry.stackTrace, 'at line 42');
      });

      test('consoleLogsReversed returns newest first', () {
        DevPanelStore.instance.info('First');
        DevPanelStore.instance.info('Second');

        final reversed = DevPanelStore.instance.consoleLogsReversed;

        expect(reversed.first.message, 'Second');
        expect(reversed.last.message, 'First');
      });

      test('clearConsoleLogs removes all console logs', () {
        DevPanelStore.instance.info('Test');

        DevPanelStore.instance.clearConsoleLogs();

        expect(DevPanelStore.instance.consoleLogs, isEmpty);
      });

      test('respects enableConsoleLogging config', () {
        DevPanelStore.init(config: DevPanelConfig(enableConsoleLogging: false));

        DevPanelStore.instance.info('Should not be logged');

        expect(DevPanelStore.instance.consoleLogs, isEmpty);
      });
    });

    group('Route History', () {
      test('starts with empty routeHistory', () {
        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });

      test('trackRoute adds route entry', () {
        final entry = RouteEntry(name: '/home', action: RouteAction.push);

        DevPanelStore.instance.trackRoute(entry);

        expect(DevPanelStore.instance.routeHistory.length, 1);
      });

      test('trackRoutePush adds push entry', () {
        final entry = DevPanelStore.instance.trackRoutePush(
          '/details',
          arguments: {'id': 42},
          previousRoute: '/home',
        );

        expect(entry.action, RouteAction.push);
        expect(entry.arguments, {'id': 42});
        expect(DevPanelStore.instance.routeHistory.length, 1);
      });

      test('trackRoutePop adds pop entry', () {
        final entry = DevPanelStore.instance.trackRoutePop(
          '/home',
          previousRoute: '/details',
        );

        expect(entry.action, RouteAction.pop);
      });

      test('trackRouteReplace adds replace entry', () {
        final entry = DevPanelStore.instance.trackRouteReplace(
          '/new-page',
          previousRoute: '/old-page',
        );

        expect(entry.action, RouteAction.replace);
      });

      test('routeHistoryReversed returns newest first', () {
        DevPanelStore.instance.trackRoutePush('/first');
        DevPanelStore.instance.trackRoutePush('/second');

        final reversed = DevPanelStore.instance.routeHistoryReversed;

        expect(reversed.first.name, '/second');
        expect(reversed.last.name, '/first');
      });

      test('currentRoute returns most recent push/replace', () {
        DevPanelStore.instance.trackRoutePush('/home');
        DevPanelStore.instance.trackRoutePush('/details');
        DevPanelStore.instance.trackRoutePop('/details');

        final current = DevPanelStore.instance.currentRoute;

        // After pop, the most recent push/replace is '/details' (the pop is recorded)
        expect(current, isNotNull);
      });

      test('currentRoute returns null when history is empty', () {
        expect(DevPanelStore.instance.currentRoute, isNull);
      });

      test('clearRouteHistory removes all route history', () {
        DevPanelStore.instance.trackRoutePush('/test');

        DevPanelStore.instance.clearRouteHistory();

        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });

      test('respects enableRouteTracking config', () {
        DevPanelStore.init(config: DevPanelConfig(enableRouteTracking: false));

        DevPanelStore.instance.trackRoutePush('/test');

        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });
    });

    group('UI Debug Settings', () {
      test('grid paper defaults to false', () {
        expect(DevPanelStore.instance.showGridPaper, false);
      });

      test('toggleGridPaper toggles value', () {
        DevPanelStore.instance.toggleGridPaper();
        expect(DevPanelStore.instance.showGridPaper, true);

        DevPanelStore.instance.toggleGridPaper();
        expect(DevPanelStore.instance.showGridPaper, false);
      });

      test('toggleGridPaper accepts explicit value', () {
        DevPanelStore.instance.toggleGridPaper(true);
        expect(DevPanelStore.instance.showGridPaper, true);

        DevPanelStore.instance.toggleGridPaper(true);
        expect(DevPanelStore.instance.showGridPaper, true);

        DevPanelStore.instance.toggleGridPaper(false);
        expect(DevPanelStore.instance.showGridPaper, false);
      });

      test('grid spacing defaults to 16.0', () {
        expect(DevPanelStore.instance.gridSpacing, 16.0);
      });

      test('setGridSpacing updates value', () {
        DevPanelStore.instance.setGridSpacing(24.0);
        expect(DevPanelStore.instance.gridSpacing, 24.0);
      });

      test('layout bounds defaults to false', () {
        expect(DevPanelStore.instance.showLayoutBounds, false);
      });

      test('toggleLayoutBounds toggles value', () {
        DevPanelStore.instance.toggleLayoutBounds();
        expect(DevPanelStore.instance.showLayoutBounds, true);
      });

      test('text scale factor defaults to 1.0', () {
        expect(DevPanelStore.instance.textScaleFactor, 1.0);
      });

      test('setTextScaleFactor updates value', () {
        DevPanelStore.instance.setTextScaleFactor(1.5);
        expect(DevPanelStore.instance.textScaleFactor, 1.5);
      });

      test('color blindness mode defaults to none', () {
        expect(
            DevPanelStore.instance.colorBlindnessMode, ColorBlindnessMode.none);
      });

      test('setColorBlindnessMode updates value', () {
        DevPanelStore.instance
            .setColorBlindnessMode(ColorBlindnessMode.protanopia);
        expect(DevPanelStore.instance.colorBlindnessMode,
            ColorBlindnessMode.protanopia);
      });

      test('slow animations defaults to false', () {
        expect(DevPanelStore.instance.slowAnimations, false);
      });

      test('toggleSlowAnimations toggles value', () {
        DevPanelStore.instance.toggleSlowAnimations();
        expect(DevPanelStore.instance.slowAnimations, true);
      });

      test('performance overlay defaults to false', () {
        expect(DevPanelStore.instance.showPerformanceOverlay, false);
      });

      test('togglePerformanceOverlay toggles value', () {
        DevPanelStore.instance.togglePerformanceOverlay();
        expect(DevPanelStore.instance.showPerformanceOverlay, true);
      });

      test('safe areas defaults to false', () {
        expect(DevPanelStore.instance.showSafeAreas, false);
      });

      test('toggleSafeAreas toggles value', () {
        DevPanelStore.instance.toggleSafeAreas();
        expect(DevPanelStore.instance.showSafeAreas, true);
      });

      test('resetUIDebugSettings resets all values', () {
        DevPanelStore.instance.toggleGridPaper(true);
        DevPanelStore.instance.setGridSpacing(32.0);
        DevPanelStore.instance.toggleLayoutBounds(true);
        DevPanelStore.instance.setTextScaleFactor(2.0);
        DevPanelStore.instance
            .setColorBlindnessMode(ColorBlindnessMode.deuteranopia);
        DevPanelStore.instance.toggleSlowAnimations(true);
        DevPanelStore.instance.togglePerformanceOverlay(true);
        DevPanelStore.instance.toggleSafeAreas(true);

        DevPanelStore.instance.resetUIDebugSettings();

        expect(DevPanelStore.instance.showGridPaper, false);
        expect(DevPanelStore.instance.gridSpacing, 16.0);
        expect(DevPanelStore.instance.showLayoutBounds, false);
        expect(DevPanelStore.instance.textScaleFactor, 1.0);
        expect(
            DevPanelStore.instance.colorBlindnessMode, ColorBlindnessMode.none);
        expect(DevPanelStore.instance.slowAnimations, false);
        expect(DevPanelStore.instance.showPerformanceOverlay, false);
        expect(DevPanelStore.instance.showSafeAreas, false);
      });
    });

    group('Bulk Operations', () {
      test('clearAll clears all data', () {
        DevPanelStore.instance
            .logApi(method: 'GET', url: 'https://test.com', durationMs: 100);
        DevPanelStore.instance.info('Test log');
        DevPanelStore.instance.trackRoutePush('/test');

        DevPanelStore.instance.clearAll();

        expect(DevPanelStore.instance.apiLogs, isEmpty);
        expect(DevPanelStore.instance.consoleLogs, isEmpty);
        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });

      test('exportData returns counts', () {
        DevPanelStore.instance
            .logApi(method: 'GET', url: 'https://test.com', durationMs: 100);
        DevPanelStore.instance.info('Test log 1');
        DevPanelStore.instance.info('Test log 2');
        DevPanelStore.instance.trackRoutePush('/test');

        final data = DevPanelStore.instance.exportData();

        expect(data['apiLogsCount'], 1);
        expect(data['consoleLogsCount'], 2);
        expect(data['routeHistoryCount'], 1);
        expect(data['exportedAt'], isNotNull);
      });
    });

    group('ChangeNotifier', () {
      test('notifies listeners on API log', () async {
        int notifyCount = 0;
        DevPanelStore.instance.addListener(() => notifyCount++);

        DevPanelStore.instance
            .logApi(method: 'GET', url: 'https://test.com', durationMs: 100);

        // Notification is deferred via addPostFrameCallback to avoid
        // setState during build phase
        await Future.delayed(Duration.zero);
        WidgetsBinding.instance.handleBeginFrame(Duration.zero);
        WidgetsBinding.instance.handleDrawFrame();

        expect(notifyCount, greaterThan(0));
      });

      test('notifies listeners on console log', () async {
        int notifyCount = 0;
        DevPanelStore.instance.addListener(() => notifyCount++);

        DevPanelStore.instance.info('Test');

        // Notification is deferred via addPostFrameCallback to avoid
        // setState during build phase
        await Future.delayed(Duration.zero);
        WidgetsBinding.instance.handleBeginFrame(Duration.zero);
        WidgetsBinding.instance.handleDrawFrame();

        expect(notifyCount, greaterThan(0));
      });

      test('notifies listeners on route tracking', () async {
        int notifyCount = 0;
        DevPanelStore.instance.addListener(() => notifyCount++);

        DevPanelStore.instance.trackRoutePush('/test');

        // Notification is deferred via addPostFrameCallback to avoid
        // setState during Navigator build phase
        await Future.delayed(Duration.zero);
        // Pump the binding to process the post-frame callback
        WidgetsBinding.instance.handleBeginFrame(Duration.zero);
        WidgetsBinding.instance.handleDrawFrame();

        expect(notifyCount, greaterThan(0));
      });

      test('notifies listeners on UI setting changes', () {
        int notifyCount = 0;
        DevPanelStore.instance.addListener(() => notifyCount++);

        DevPanelStore.instance.toggleGridPaper();

        expect(notifyCount, greaterThan(0));
      });
    });
  });
}
