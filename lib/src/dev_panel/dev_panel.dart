/// Dev Panel - A developer debugging panel for Flutter applications.
///
/// This module provides runtime debugging capabilities including:
/// - API request logging
/// - Console log capture
/// - Route navigation tracking
/// - Local storage viewing
library;

// Configuration
export 'dev_panel_config.dart';

// Data store
export 'data/dev_panel_store.dart';

// Models
export 'data/models/api_request_log.dart';
export 'data/models/log_entry.dart';
export 'data/models/log_level.dart';
export 'data/models/route_entry.dart';
export 'data/models/storage_entry.dart';

// Observers
export 'observers/error_stack_navigator_observer.dart';

// Widgets
export 'widgets/error_stack_dev_panel.dart';
export 'widgets/error_stack_dev_panel_sheet.dart';
export 'widgets/ui_debug_overlay.dart';
