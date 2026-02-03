import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'collections/fifo_list.dart';
import 'models/api_request_log.dart';
import 'models/log_entry.dart';
import 'models/log_level.dart';
import 'models/route_entry.dart';
import '../dev_panel_config.dart';

/// Color blindness simulation modes.
enum ColorBlindnessMode {
  /// No color blindness simulation.
  none,

  /// Protanopia (red-blind).
  protanopia,

  /// Deuteranopia (green-blind).
  deuteranopia,

  /// Tritanopia (blue-blind).
  tritanopia,
}

/// Central data store for the dev panel.
///
/// A singleton that holds all debug data including API logs,
/// console logs, route history, and storage references.
///
/// ## Usage
///
/// ```dart
/// // Log an API request
/// DevPanelStore.instance.logApiRequest(
///   ApiRequestLog(
///     method: 'GET',
///     url: 'https://api.example.com/users',
///     statusCode: 200,
///     durationMs: 150,
///   ),
/// );
///
/// // Log a console message
/// DevPanelStore.instance.info('User logged in');
///
/// // Access the data
/// final apiLogs = DevPanelStore.instance.apiLogs;
/// final consoleLogs = DevPanelStore.instance.consoleLogs;
/// ```
class DevPanelStore extends ChangeNotifier {
  DevPanelStore._();

  /// The singleton instance of [DevPanelStore].
  static final DevPanelStore instance = DevPanelStore._();

  /// Whether the store has been initialized.
  static bool _initialized = false;

  /// The current configuration.
  DevPanelConfig _config = const DevPanelConfig();

  late FifoList<ApiRequestLog> _apiLogs;
  late FifoList<LogEntry> _consoleLogs;
  late FifoList<RouteEntry> _routeHistory;
  final Map<String, ApiRequestLog> _pendingRequests = {};

  /// Initializes the dev panel store with the given configuration.
  ///
  /// This should be called during app initialization, typically
  /// alongside [ErrorStack.init()].
  static void init({DevPanelConfig? config}) {
    final store = instance;
    store._config = config ?? const DevPanelConfig();
    store._apiLogs = FifoList(store._config.apiLogLimit);
    store._consoleLogs = FifoList(store._config.consoleLogLimit);
    store._routeHistory = FifoList(store._config.routeHistoryLimit);
    _initialized = true;
  }

  /// Returns true if the store has been initialized.
  static bool get isInitialized => _initialized;

  /// The current configuration.
  DevPanelConfig get config => _config;

  /// Defers notifyListeners() to avoid setState during build phase.
  void _deferredNotify() {
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  /// Updates the configuration.
  void updateConfig(DevPanelConfig config) {
    _config = config;
    notifyListeners();
  }

  // ============================================================
  // API Request Logging
  // ============================================================

  /// All API request logs (oldest first).
  List<ApiRequestLog> get apiLogs =>
      _initialized ? _apiLogs.toList() : <ApiRequestLog>[];

  /// All API request logs in reverse order (newest first).
  List<ApiRequestLog> get apiLogsReversed =>
      _initialized ? _apiLogs.reversed : <ApiRequestLog>[];

  /// Logs an API request.
  ///
  /// If [config.enableApiLogging] is false, this is a no-op.
  void logApiRequest(ApiRequestLog log) {
    if (!_initialized || !_config.enableApiLogging) return;
    _apiLogs.add(log);
    _deferredNotify();
  }

  /// Starts tracking a pending API request.
  /// Returns the request ID for later completion.
  String startApiRequest({
    required String method,
    required String url,
    Map<String, dynamic> requestHeaders = const {},
    dynamic requestBody,
  }) {
    final log = ApiRequestLog(
      method: method,
      url: url,
      durationMs: 0,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
    );
    _pendingRequests[log.id] = log;
    return log.id;
  }

  /// Completes a pending API request with response data.
  void completeApiRequest({
    required String requestId,
    required int statusCode,
    required int durationMs,
    Map<String, dynamic>? responseHeaders,
    dynamic responseBody,
    String? error,
  }) {
    final pending = _pendingRequests.remove(requestId);
    if (pending == null) return;

    final completed = pending.copyWith(
      statusCode: statusCode,
      durationMs: durationMs,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      error: error,
    );
    logApiRequest(completed);
  }

  /// Creates and logs an API request from individual parameters.
  ///
  /// Returns the created [ApiRequestLog] for reference.
  ApiRequestLog logApi({
    required String method,
    required String url,
    int? statusCode,
    required int durationMs,
    Map<String, dynamic> requestHeaders = const {},
    dynamic requestBody,
    Map<String, dynamic>? responseHeaders,
    dynamic responseBody,
    String? error,
  }) {
    final log = ApiRequestLog(
      method: method,
      url: url,
      statusCode: statusCode,
      durationMs: durationMs,
      requestHeaders: requestHeaders,
      requestBody: requestBody,
      responseHeaders: responseHeaders,
      responseBody: responseBody,
      error: error,
    );
    logApiRequest(log);
    return log;
  }

  /// Clears all API logs.
  void clearApiLogs() {
    if (!_initialized) return;
    _apiLogs.clear();
    _pendingRequests.clear();
    notifyListeners();
  }

  // ============================================================
  // Console Logging
  // ============================================================

  /// All console logs (oldest first).
  List<LogEntry> get consoleLogs =>
      _initialized ? _consoleLogs.toList() : <LogEntry>[];

  /// All console logs in reverse order (newest first).
  List<LogEntry> get consoleLogsReversed =>
      _initialized ? _consoleLogs.reversed : <LogEntry>[];

  /// Logs a console message.
  ///
  /// If [config.enableConsoleLogging] is false, this is a no-op.
  void logEntry(LogEntry entry) {
    if (!_initialized || !_config.enableConsoleLogging) return;
    _consoleLogs.add(entry);
    _deferredNotify();
  }

  /// Logs a message with the specified level.
  ///
  /// Returns the created [LogEntry] for reference.
  LogEntry log(
    String message, {
    DevPanelLogLevel level = DevPanelLogLevel.info,
    String? tag,
    Map<String, dynamic>? metadata,
    String? stackTrace,
  }) {
    final entry = LogEntry(
      level: level,
      message: message,
      tag: tag,
      metadata: metadata,
      stackTrace: stackTrace,
    );
    logEntry(entry);
    return entry;
  }

  /// Logs a debug message.
  LogEntry debug(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    return log(message,
        level: DevPanelLogLevel.debug, tag: tag, metadata: metadata);
  }

  /// Logs an info message.
  LogEntry info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    return log(message,
        level: DevPanelLogLevel.info, tag: tag, metadata: metadata);
  }

  /// Logs a warning message.
  LogEntry warning(String message,
      {String? tag, Map<String, dynamic>? metadata}) {
    return log(message,
        level: DevPanelLogLevel.warning, tag: tag, metadata: metadata);
  }

  /// Logs an error message.
  LogEntry error(String message,
      {String? tag, String? stackTrace, Map<String, dynamic>? metadata}) {
    return log(message,
        level: DevPanelLogLevel.error,
        tag: tag,
        stackTrace: stackTrace,
        metadata: metadata);
  }

  /// Clears all console logs.
  void clearConsoleLogs() {
    if (!_initialized) return;
    _consoleLogs.clear();
    notifyListeners();
  }

  // ============================================================
  // Route History
  // ============================================================

  /// All route entries (oldest first).
  List<RouteEntry> get routeHistory =>
      _initialized ? _routeHistory.toList() : <RouteEntry>[];

  /// All route entries in reverse order (newest first).
  List<RouteEntry> get routeHistoryReversed =>
      _initialized ? _routeHistory.reversed : <RouteEntry>[];

  /// The current route (most recent push that hasn't been popped).
  RouteEntry? get currentRoute {
    if (!_initialized || _routeHistory.isEmpty) return null;
    // Find the most recent route that was pushed
    final history = _routeHistory.reversed;
    for (final entry in history) {
      if (entry.action == RouteAction.push ||
          entry.action == RouteAction.replace) {
        return entry;
      }
    }
    return null;
  }

  /// Tracks a route navigation.
  ///
  /// If [config.enableRouteTracking] is false, this is a no-op.
  ///
  /// Note: Notification is deferred to avoid calling setState during build.
  void trackRoute(RouteEntry entry) {
    if (!_initialized || !_config.enableRouteTracking) return;
    _routeHistory.add(entry);
    _deferredNotify();
  }

  /// Tracks a route push.
  RouteEntry trackRoutePush(String name,
      {Object? arguments, String? previousRoute}) {
    final entry = RouteEntry(
      name: name,
      arguments: arguments,
      action: RouteAction.push,
      previousRoute: previousRoute,
    );
    trackRoute(entry);
    return entry;
  }

  /// Tracks a route pop.
  RouteEntry trackRoutePop(String name, {String? previousRoute}) {
    final entry = RouteEntry(
      name: name,
      action: RouteAction.pop,
      previousRoute: previousRoute,
    );
    trackRoute(entry);
    return entry;
  }

  /// Tracks a route replacement.
  RouteEntry trackRouteReplace(String name,
      {Object? arguments, String? previousRoute}) {
    final entry = RouteEntry(
      name: name,
      arguments: arguments,
      action: RouteAction.replace,
      previousRoute: previousRoute,
    );
    trackRoute(entry);
    return entry;
  }

  /// Clears all route history.
  void clearRouteHistory() {
    if (!_initialized) return;
    _routeHistory.clear();
    notifyListeners();
  }

  // ============================================================
  // UI Debug Settings
  // ============================================================

  /// Whether to show the grid paper overlay.
  bool _showGridPaper = false;
  bool get showGridPaper => _showGridPaper;

  /// Grid paper spacing in pixels.
  double _gridSpacing = 16.0;
  double get gridSpacing => _gridSpacing;

  /// Whether to show layout bounds (widget boundaries).
  bool _showLayoutBounds = false;
  bool get showLayoutBounds => _showLayoutBounds;

  /// Text scale factor override.
  double _textScaleFactor = 1.0;
  double get textScaleFactor => _textScaleFactor;

  /// Color blindness simulation mode.
  ColorBlindnessMode _colorBlindnessMode = ColorBlindnessMode.none;
  ColorBlindnessMode get colorBlindnessMode => _colorBlindnessMode;

  /// Whether to slow down animations.
  bool _slowAnimations = false;
  bool get slowAnimations => _slowAnimations;

  /// Whether to show the performance overlay.
  bool _showPerformanceOverlay = false;
  bool get showPerformanceOverlay => _showPerformanceOverlay;

  /// Whether to show safe area boundaries.
  bool _showSafeAreas = false;
  bool get showSafeAreas => _showSafeAreas;

  /// Toggle grid paper overlay.
  void toggleGridPaper([bool? value]) {
    _showGridPaper = value ?? !_showGridPaper;
    notifyListeners();
  }

  /// Set grid paper spacing.
  void setGridSpacing(double spacing) {
    _gridSpacing = spacing;
    notifyListeners();
  }

  /// Toggle layout bounds display.
  void toggleLayoutBounds([bool? value]) {
    _showLayoutBounds = value ?? !_showLayoutBounds;
    notifyListeners();
  }

  /// Set text scale factor.
  void setTextScaleFactor(double factor) {
    _textScaleFactor = factor;
    notifyListeners();
  }

  /// Set color blindness simulation mode.
  void setColorBlindnessMode(ColorBlindnessMode mode) {
    _colorBlindnessMode = mode;
    notifyListeners();
  }

  /// Toggle slow animations.
  void toggleSlowAnimations([bool? value]) {
    final newValue = value ?? !_slowAnimations;
    _slowAnimations = newValue;
    timeDilation = newValue ? 5.0 : 1.0;
    notifyListeners();
  }

  /// Toggle performance overlay.
  void togglePerformanceOverlay([bool? value]) {
    _showPerformanceOverlay = value ?? !_showPerformanceOverlay;
    notifyListeners();
  }

  /// Toggle safe area display.
  void toggleSafeAreas([bool? value]) {
    _showSafeAreas = value ?? !_showSafeAreas;
    notifyListeners();
  }

  /// Reset all UI debug settings to defaults.
  void resetUIDebugSettings() {
    _showGridPaper = false;
    _gridSpacing = 16.0;
    _showLayoutBounds = false;
    _textScaleFactor = 1.0;
    _colorBlindnessMode = ColorBlindnessMode.none;
    if (_slowAnimations) {
      _slowAnimations = false;
      timeDilation = 1.0;
    }
    _showPerformanceOverlay = false;
    _showSafeAreas = false;
    notifyListeners();
  }

  // ============================================================
  // Bulk Operations
  // ============================================================

  /// Clears all data from the store.
  void clearAll() {
    if (!_initialized) return;
    _apiLogs.clear();
    _consoleLogs.clear();
    _routeHistory.clear();
    _pendingRequests.clear();
    notifyListeners();
  }

  /// Exports all data as a JSON-serializable map.
  Map<String, dynamic> exportData() {
    return {
      'apiLogsCount': _initialized ? _apiLogs.length : 0,
      'consoleLogsCount': _initialized ? _consoleLogs.length : 0,
      'routeHistoryCount': _initialized ? _routeHistory.length : 0,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}
