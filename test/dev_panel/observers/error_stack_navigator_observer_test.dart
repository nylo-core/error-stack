import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/observers/error_stack_navigator_observer.dart';
import 'package:error_stack/src/dev_panel/data/dev_panel_store.dart';
import 'package:error_stack/src/dev_panel/data/models/route_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorStackNavigatorObserver', () {
    late ErrorStackNavigatorObserver observer;

    setUp(() {
      // Initialize the store before each test
      DevPanelStore.init();
      DevPanelStore.instance.clearAll();
      observer = ErrorStackNavigatorObserver();
    });

    tearDown(() {
      DevPanelStore.instance.clearAll();
    });

    group('constructor', () {
      test('enabled is true by default', () {
        final obs = ErrorStackNavigatorObserver();
        expect(obs.enabled, true);
      });

      test('enabled can be set to false', () {
        final obs = ErrorStackNavigatorObserver(enabled: false);
        expect(obs.enabled, false);
      });
    });

    group('didPush', () {
      test('tracks route push with name', () {
        final route = _createMockRoute('/home');
        final previousRoute = _createMockRoute('/splash');

        observer.didPush(route, previousRoute);

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 1);
        expect(history.first.name, '/home');
        expect(history.first.action, RouteAction.push);
        expect(history.first.previousRoute, '/splash');
      });

      test('tracks route with arguments', () {
        final route = _createMockRoute('/details', arguments: {'id': 123});

        observer.didPush(route, null);

        final entry = DevPanelStore.instance.routeHistory.first;
        expect(entry.arguments, {'id': 123});
      });

      test('handles null route name', () {
        final route = _MockRoute(null);

        observer.didPush(route, null);

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 1);
        // Should use runtime type as fallback
        expect(history.first.name, contains('_MockRoute'));
      });

      test('does not track when disabled', () {
        observer = ErrorStackNavigatorObserver(enabled: false);
        final route = _createMockRoute('/test');

        observer.didPush(route, null);

        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });
    });

    group('didPop', () {
      test('tracks route pop', () {
        final route = _createMockRoute('/details');
        final previousRoute = _createMockRoute('/home');

        observer.didPop(route, previousRoute);

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 1);
        expect(history.first.name, '/details');
        expect(history.first.action, RouteAction.pop);
        expect(history.first.previousRoute, '/home');
      });

      test('does not track when disabled', () {
        observer = ErrorStackNavigatorObserver(enabled: false);
        final route = _createMockRoute('/test');

        observer.didPop(route, null);

        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });
    });

    group('didReplace', () {
      test('tracks route replacement', () {
        final newRoute = _createMockRoute('/new-page', arguments: 'arg');
        final oldRoute = _createMockRoute('/old-page');

        observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 1);
        expect(history.first.name, '/new-page');
        expect(history.first.action, RouteAction.replace);
        expect(history.first.previousRoute, '/old-page');
        expect(history.first.arguments, 'arg');
      });

      test('handles null newRoute', () {
        final oldRoute = _createMockRoute('/old');

        observer.didReplace(newRoute: null, oldRoute: oldRoute);

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 1);
        expect(history.first.name, 'unknown');
      });

      test('does not track when disabled', () {
        observer = ErrorStackNavigatorObserver(enabled: false);

        observer.didReplace(
            newRoute: _createMockRoute('/new'),
            oldRoute: _createMockRoute('/old'));

        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });
    });

    group('didRemove', () {
      test('tracks route removal', () {
        final route = _createMockRoute('/removed');
        final previousRoute = _createMockRoute('/remaining');

        observer.didRemove(route, previousRoute);

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 1);
        expect(history.first.name, '/removed');
        expect(history.first.action, RouteAction.remove);
        expect(history.first.previousRoute, '/remaining');
      });

      test('does not track when disabled', () {
        observer = ErrorStackNavigatorObserver(enabled: false);

        observer.didRemove(_createMockRoute('/test'), null);

        expect(DevPanelStore.instance.routeHistory, isEmpty);
      });
    });

    group('route metadata extraction', () {
      test('extracts PageRoute metadata', () {
        // Use a mock PageRoute
        final route = _MockPageRoute(
          '/settings',
          fullscreenDialog: true,
          maintainState: false,
          opaque: false,
        );

        observer.didPush(route, null);

        final entry = DevPanelStore.instance.routeHistory.first;
        expect(entry.isFullscreenDialog, true);
        expect(entry.maintainState, false);
        expect(entry.opaque, false);
        expect(entry.routeType, contains('_MockPageRoute'));
      });

      test('handles non-PageRoute routes', () {
        final route = _MockRoute('/basic');

        observer.didPush(route, null);

        final entry = DevPanelStore.instance.routeHistory.first;
        expect(entry.routeType, contains('_MockRoute'));
        // Non-PageRoute won't have these properties
        expect(entry.isFullscreenDialog, isNull);
      });
    });

    group('integration with DevPanelStore', () {
      test('multiple navigation actions are recorded in order', () {
        observer.didPush(_createMockRoute('/page1'), null);
        observer.didPush(
            _createMockRoute('/page2'), _createMockRoute('/page1'));
        observer.didPop(_createMockRoute('/page2'), _createMockRoute('/page1'));

        final history = DevPanelStore.instance.routeHistory;
        expect(history.length, 3);
        expect(history[0].name, '/page1');
        expect(history[0].action, RouteAction.push);
        expect(history[1].name, '/page2');
        expect(history[1].action, RouteAction.push);
        expect(history[2].name, '/page2');
        expect(history[2].action, RouteAction.pop);
      });
    });
  });
}

// Helper function to create mock routes
Route<dynamic> _createMockRoute(String name, {Object? arguments}) {
  return _MockRoute(name, arguments: arguments);
}

// Mock Route implementation for testing
class _MockRoute extends Route<dynamic> {
  final String? _name;
  final Object? _arguments;

  _MockRoute(this._name, {Object? arguments}) : _arguments = arguments;

  @override
  RouteSettings get settings =>
      RouteSettings(name: _name, arguments: _arguments);
}

// Mock PageRoute implementation for testing
class _MockPageRoute extends PageRoute<dynamic> {
  final String? _name;
  @override
  final bool maintainState;
  @override
  final bool opaque;

  _MockPageRoute(
    this._name, {
    super.fullscreenDialog = false,
    this.maintainState = true,
    this.opaque = true,
  });

  @override
  RouteSettings get settings => RouteSettings(name: _name);

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const SizedBox();
  }

  @override
  Duration get transitionDuration => Duration.zero;
}
