import 'package:flutter_test/flutter_test.dart';

// Config tests
import 'config/error_stack_config_test.dart' as config_test;
import 'config/error_stack_log_level_test.dart' as log_level_test;

// Storage tests
import 'storage/error_stack_storage_base_test.dart' as storage_base_test;

// Dev panel data tests
import 'dev_panel/data/collections/fifo_list_test.dart' as fifo_list_test;
import 'dev_panel/data/models/log_level_test.dart' as dev_panel_log_level_test;
import 'dev_panel/data/models/log_entry_test.dart' as log_entry_test;
import 'dev_panel/data/models/api_request_log_test.dart'
    as api_request_log_test;
import 'dev_panel/data/models/route_entry_test.dart' as route_entry_test;
import 'dev_panel/data/models/storage_entry_test.dart' as storage_entry_test;
import 'dev_panel/data/dev_panel_store_test.dart' as dev_panel_store_test;
import 'dev_panel/dev_panel_config_test.dart' as dev_panel_config_test;

// Dev panel observers tests
import 'dev_panel/observers/error_stack_navigator_observer_test.dart'
    as navigator_observer_test;

// Handler tests
import 'handler/error_stack_handler_test.dart' as handler_test;

void main() {
  group('ErrorStack Package Tests', () {
    group('Config', () {
      config_test.main();
      log_level_test.main();
    });

    group('Storage', () {
      storage_base_test.main();
    });

    group('Dev Panel', () {
      group('Collections', () {
        fifo_list_test.main();
      });

      group('Models', () {
        dev_panel_log_level_test.main();
        log_entry_test.main();
        api_request_log_test.main();
        route_entry_test.main();
        storage_entry_test.main();
      });

      group('Store', () {
        dev_panel_store_test.main();
      });

      group('Config', () {
        dev_panel_config_test.main();
      });

      group('Observers', () {
        navigator_observer_test.main();
      });
    });

    group('Handler', () {
      handler_test.main();
    });
  });
}
