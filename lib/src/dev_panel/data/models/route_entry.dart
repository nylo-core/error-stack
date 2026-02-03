/// The type of navigation action that occurred.
enum RouteAction {
  /// A new route was pushed onto the stack.
  push,

  /// A route was popped from the stack.
  pop,

  /// The current route was replaced.
  replace,

  /// A route was removed from the stack.
  remove,
}

/// Represents a navigation route entry in the route history.
///
/// Tracks route navigation for debugging navigation flows.
class RouteEntry {
  /// Unique identifier for this route entry.
  final String id;

  /// The route name (e.g., '/home', '/settings').
  final String name;

  /// Route arguments passed during navigation.
  final Object? arguments;

  /// Timestamp when this route was navigated to.
  final DateTime timestamp;

  /// The type of navigation action.
  final RouteAction action;

  /// Previous route name (for push/replace actions).
  final String? previousRoute;

  /// The runtime type of the route (e.g., 'MaterialPageRoute').
  final String? routeType;

  /// Whether the route is presented as a fullscreen dialog.
  final bool? isFullscreenDialog;

  /// Whether the route maintains state when inactive.
  final bool? maintainState;

  /// Whether the route is opaque (obscures routes below).
  final bool? opaque;

  /// Creates a [RouteEntry] with the specified details.
  RouteEntry({
    String? id,
    required this.name,
    this.arguments,
    DateTime? timestamp,
    this.action = RouteAction.push,
    this.previousRoute,
    this.routeType,
    this.isFullscreenDialog,
    this.maintainState,
    this.opaque,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  /// Formatted timestamp string.
  String get formattedTimestamp {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Formatted arguments string.
  String? get formattedArguments {
    if (arguments == null) return null;
    if (arguments is Map) return arguments.toString();
    if (arguments is String) return '"$arguments"';
    return arguments.toString();
  }

  /// Whether this route appears to be an internal system route.
  ///
  /// Returns true for routes like _ModalBottomSheetRoute that are
  /// internal Flutter navigation and shouldn't be displayed in the dev panel.
  bool get isInternalRoute =>
      routeType != null &&
      (routeType!.startsWith('_') || routeType!.contains('ModalBottomSheet'));

  static int _idCounter = 0;
  static String _generateId() =>
      'route_${DateTime.now().millisecondsSinceEpoch}_${++_idCounter}';
}
