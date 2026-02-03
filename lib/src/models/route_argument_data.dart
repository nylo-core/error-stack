/// Lightweight representation of route arguments for display purposes.
/// Used to avoid circular dependency with nylo_support.
class RouteArgumentData {
  final dynamic data;
  final Map<String, String>? queryParameters;
  final String? prefix;
  final String? pageTransitionType;
  final String? transitionType;

  RouteArgumentData({
    this.data,
    this.queryParameters,
    this.prefix,
    this.pageTransitionType,
    this.transitionType,
  });

  /// Creates from a Map (typically from nylo_support's ArgumentsWrapper.toMap())
  factory RouteArgumentData.fromMap(Map<String, dynamic> map) {
    return RouteArgumentData(
      data: map['data'],
      queryParameters: map['queryParameters'] != null
          ? Map<String, String>.from(map['queryParameters'])
          : null,
      prefix: map['prefix'],
      pageTransitionType: map['pageTransitionType'],
      transitionType: map['transitionType'],
    );
  }

  /// Check if this looks like an ArgumentsWrapper map
  static bool isArgumentsWrapperMap(Object? obj) {
    return obj.runtimeType.toString() == 'ArgumentsWrapper';
  }
}
