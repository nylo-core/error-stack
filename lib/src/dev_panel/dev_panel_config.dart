/// Configuration for the dev panel.
///
/// Controls which features are enabled and how data is collected.
class DevPanelConfig {
  /// Whether API request logging is enabled.
  final bool enableApiLogging;

  /// Whether console log capture is enabled.
  final bool enableConsoleLogging;

  /// Whether route tracking is enabled.
  final bool enableRouteTracking;

  /// Maximum number of API requests to store.
  final int apiLogLimit;

  /// Maximum number of console logs to store.
  final int consoleLogLimit;

  /// Maximum number of route entries to store.
  final int routeHistoryLimit;

  /// Creates a [DevPanelConfig] with the specified settings.
  const DevPanelConfig({
    this.enableApiLogging = true,
    this.enableConsoleLogging = true,
    this.enableRouteTracking = true,
    this.apiLogLimit = 100,
    this.consoleLogLimit = 100,
    this.routeHistoryLimit = 50,
  });

  /// Creates a copy with modified fields.
  DevPanelConfig copyWith({
    bool? enableApiLogging,
    bool? enableConsoleLogging,
    bool? enableRouteTracking,
    int? apiLogLimit,
    int? consoleLogLimit,
    int? routeHistoryLimit,
  }) {
    return DevPanelConfig(
      enableApiLogging: enableApiLogging ?? this.enableApiLogging,
      enableConsoleLogging: enableConsoleLogging ?? this.enableConsoleLogging,
      enableRouteTracking: enableRouteTracking ?? this.enableRouteTracking,
      apiLogLimit: apiLogLimit ?? this.apiLogLimit,
      consoleLogLimit: consoleLogLimit ?? this.consoleLogLimit,
      routeHistoryLimit: routeHistoryLimit ?? this.routeHistoryLimit,
    );
  }
}
