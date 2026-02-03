import 'package:flutter/widgets.dart';
import '../data/dev_panel_store.dart';
import '../data/models/route_entry.dart';

/// A [NavigatorObserver] that automatically tracks route changes.
///
/// Add this to your [MaterialApp.navigatorObservers] to enable
/// automatic route history tracking in the dev panel.
///
/// ## Usage
///
/// ```dart
/// MaterialApp(
///   navigatorObservers: [
///     ErrorStackNavigatorObserver(),
///   ],
/// )
/// ```
class ErrorStackNavigatorObserver extends NavigatorObserver {
  /// Whether the observer is enabled.
  final bool enabled;

  /// Creates an [ErrorStackNavigatorObserver].
  ErrorStackNavigatorObserver({this.enabled = true});

  String? _getRouteName(Route<dynamic>? route) {
    if (route == null) return null;
    return route.settings.name ?? _inferRouteName(route);
  }

  /// Try to infer route name from the route type.
  String _inferRouteName(Route<dynamic> route) {
    final runtimeType = route.runtimeType.toString();
    if (runtimeType.contains('MaterialPageRoute') ||
        runtimeType.contains('CupertinoPageRoute')) {
      return '[${route.runtimeType}]';
    }
    return runtimeType;
  }

  /// Extract metadata from a route if it's a PageRoute.
  _RouteMetadata _extractMetadata(Route<dynamic>? route) {
    if (route == null) return _RouteMetadata();

    final routeType = route.runtimeType.toString();

    if (route is PageRoute) {
      return _RouteMetadata(
        routeType: routeType,
        isFullscreenDialog: route.fullscreenDialog,
        maintainState: route.maintainState,
        opaque: route.opaque,
      );
    }

    return _RouteMetadata(routeType: routeType);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!enabled) return;

    final metadata = _extractMetadata(route);
    DevPanelStore.instance.trackRoute(RouteEntry(
      name: _getRouteName(route) ?? 'unknown',
      arguments: route.settings.arguments,
      action: RouteAction.push,
      previousRoute: _getRouteName(previousRoute),
      routeType: metadata.routeType,
      isFullscreenDialog: metadata.isFullscreenDialog,
      maintainState: metadata.maintainState,
      opaque: metadata.opaque,
    ));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!enabled) return;

    final metadata = _extractMetadata(route);
    DevPanelStore.instance.trackRoute(RouteEntry(
      name: _getRouteName(route) ?? 'unknown',
      action: RouteAction.pop,
      previousRoute: _getRouteName(previousRoute),
      routeType: metadata.routeType,
      isFullscreenDialog: metadata.isFullscreenDialog,
      maintainState: metadata.maintainState,
      opaque: metadata.opaque,
    ));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (!enabled) return;

    final metadata = _extractMetadata(newRoute);
    DevPanelStore.instance.trackRoute(RouteEntry(
      name: _getRouteName(newRoute) ?? 'unknown',
      arguments: newRoute?.settings.arguments,
      action: RouteAction.replace,
      previousRoute: _getRouteName(oldRoute),
      routeType: metadata.routeType,
      isFullscreenDialog: metadata.isFullscreenDialog,
      maintainState: metadata.maintainState,
      opaque: metadata.opaque,
    ));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (!enabled) return;

    final metadata = _extractMetadata(route);
    DevPanelStore.instance.trackRoute(RouteEntry(
      name: _getRouteName(route) ?? 'unknown',
      action: RouteAction.remove,
      previousRoute: _getRouteName(previousRoute),
      routeType: metadata.routeType,
      isFullscreenDialog: metadata.isFullscreenDialog,
      maintainState: metadata.maintainState,
      opaque: metadata.opaque,
    ));
  }
}

/// Helper class for route metadata extraction.
class _RouteMetadata {
  final String? routeType;
  final bool? isFullscreenDialog;
  final bool? maintainState;
  final bool? opaque;

  _RouteMetadata({
    this.routeType,
    this.isFullscreenDialog,
    this.maintainState,
    this.opaque,
  });
}
