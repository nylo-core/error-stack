import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/data/models/route_entry.dart';

void main() {
  group('RouteAction', () {
    test('has four action types', () {
      expect(RouteAction.values.length, 4);
    });

    test('contains expected values', () {
      expect(RouteAction.values, contains(RouteAction.push));
      expect(RouteAction.values, contains(RouteAction.pop));
      expect(RouteAction.values, contains(RouteAction.replace));
      expect(RouteAction.values, contains(RouteAction.remove));
    });

    test('values have correct indices', () {
      expect(RouteAction.push.index, 0);
      expect(RouteAction.pop.index, 1);
      expect(RouteAction.replace.index, 2);
      expect(RouteAction.remove.index, 3);
    });
  });

  group('RouteEntry', () {
    group('constructor', () {
      test('creates with required parameters', () {
        final entry = RouteEntry(name: '/home');

        expect(entry.name, '/home');
        expect(entry.action, RouteAction.push);
        expect(entry.id, isNotEmpty);
        expect(entry.timestamp, isNotNull);
      });

      test('generates unique IDs', () {
        final entry1 = RouteEntry(name: '/page1');
        final entry2 = RouteEntry(name: '/page2');

        expect(entry1.id, isNot(entry2.id));
      });

      test('accepts custom id and timestamp', () {
        final customTime = DateTime(2024, 6, 20, 10, 15);
        final entry = RouteEntry(
          id: 'custom-route-id',
          name: '/settings',
          timestamp: customTime,
        );

        expect(entry.id, 'custom-route-id');
        expect(entry.timestamp, customTime);
      });

      test('accepts all optional parameters', () {
        final entry = RouteEntry(
          name: '/profile',
          arguments: {'userId': 42},
          action: RouteAction.replace,
          previousRoute: '/home',
          routeType: 'MaterialPageRoute',
          isFullscreenDialog: false,
          maintainState: true,
          opaque: true,
        );

        expect(entry.arguments, {'userId': 42});
        expect(entry.action, RouteAction.replace);
        expect(entry.previousRoute, '/home');
        expect(entry.routeType, 'MaterialPageRoute');
        expect(entry.isFullscreenDialog, false);
        expect(entry.maintainState, true);
        expect(entry.opaque, true);
      });
    });

    group('formattedTimestamp', () {
      test('formats timestamp as HH:MM:SS', () {
        final entry = RouteEntry(
          name: '/test',
          timestamp: DateTime(2024, 8, 5, 16, 45, 30),
        );

        expect(entry.formattedTimestamp, '16:45:30');
      });

      test('pads single digit values', () {
        final entry = RouteEntry(
          name: '/test',
          timestamp: DateTime(2024, 1, 1, 2, 4, 6),
        );

        expect(entry.formattedTimestamp, '02:04:06');
      });
    });

    group('formattedArguments', () {
      test('returns null when arguments is null', () {
        final entry = RouteEntry(name: '/test', arguments: null);

        expect(entry.formattedArguments, isNull);
      });

      test('formats Map arguments as string', () {
        final entry = RouteEntry(
          name: '/test',
          arguments: {'key': 'value', 'num': 42},
        );

        expect(entry.formattedArguments, '{key: value, num: 42}');
      });

      test('formats String arguments with quotes', () {
        final entry = RouteEntry(name: '/test', arguments: 'simple-string');

        expect(entry.formattedArguments, '"simple-string"');
      });

      test('formats other types using toString', () {
        final entry = RouteEntry(name: '/test', arguments: 12345);

        expect(entry.formattedArguments, '12345');
      });
    });

    group('isInternalRoute', () {
      test('returns true for routes starting with underscore', () {
        final entry = RouteEntry(
          name: '/internal',
          routeType: '_PrivateRoute',
        );

        expect(entry.isInternalRoute, true);
      });

      test('returns true for ModalBottomSheet routes', () {
        final entry = RouteEntry(
          name: '/sheet',
          routeType: 'ModalBottomSheetRoute<dynamic>',
        );

        expect(entry.isInternalRoute, true);
      });

      test('returns false for regular routes', () {
        final entry = RouteEntry(
          name: '/home',
          routeType: 'MaterialPageRoute<dynamic>',
        );

        expect(entry.isInternalRoute, false);
      });

      test('returns false when routeType is null', () {
        final entry = RouteEntry(name: '/test');

        expect(entry.isInternalRoute, false);
      });
    });
  });
}
