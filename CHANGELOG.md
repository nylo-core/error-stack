## [2.1.2] - 2026-05-01

### Fixed

* Dev Panel long-press failed to open when `ErrorStackDevPanel` was used via `MaterialApp.builder`. The panel now locates the `Navigator` whether it sits above or below the dev panel widget in the element tree.

### Tests

* Added widget tests covering the long-press path for both `home:` and `MaterialApp.builder` configurations.

### Example

* Added a "Storage Tab" example demonstrating the Dev Panel's `SharedPreferences` and `FlutterSecureStorage` inspector with view, edit, search, and delete flows.

## [2.1.1] - 2026-04-26

### Documentation

* Documented the 2.1.0 copy-to-clipboard features in the README (Logs, Routes, and Storage tab sections)

## [2.1.0] - 2026-04-26

### Added

* Copy-to-clipboard support across the Dev Panel:
  * Logs tab: copy a full log entry (level, timestamp, tag, message, and stack trace) from each row
  * Routes tab: copy the route name from the route details sheet
  * Local Storage tab: copy the key or value from the edit modal
* "Copied!" confirmation feedback on each copy action

### Changed

* Bumped `shared_preferences` from `^2.5.4` to `^2.5.5`
* Bumped `dio` from `^5.9.1` to `^5.9.2`

## [2.0.1] - 2026-02-25

### Changed

* Redesigned Dev Panel trigger from a horizontal bar at the bottom to a compact vertical tab on the right edge of the screen
* Increased error display container height from 580 to 610 to prevent content overflow

## [2.0.0] - 2026-02-04

### Breaking Changes

* Refactored `ErrorStack` into multiple single-responsibility classes following SOLID principles
* `ErrorStack.init()` now accepts optional `storage` and `devPanelConfig` parameters
* `ErrorStackDebugWidget` now uses constructor injection instead of accessing `ErrorStack.instance`

### New Features

#### Dev Panel
A comprehensive runtime debugging tool accessible via long-press on the "Dev Panel" bar or programmatically via `ErrorStack.showDevPanel(context)`:

* **API Tab** - HTTP request/response logging with timing, headers, and body data
* **Logs Tab** - Console logging with severity levels (debug, info, warning, error)
* **Routes Tab** - Navigation history tracking with route names and arguments
* **Storage Tab** - View local storage data (Secure Storage & Shared Preferences)
* **UI Tab** - Visual debugging tools:
  * Grid paper overlay
  * Layout bounds visualization
  * Text scale adjustment (0.5-3.0x)
  * Color blindness simulation (protanopia, deuteranopia, tritanopia)
  * Slow animations (5x)
  * Performance overlay
  * Safe area visualization

#### Dio Integration
* **`ErrorStackDioInterceptor`** - Automatic HTTP logging for Dio requests
* Separate import: `import 'package:error_stack/error_stack_dio.dart'`

#### Navigator Observer
* **`ErrorStackNavigatorObserver`** - Automatic route tracking for navigation history

#### Core Architecture
* **`ErrorStackConfig`** - Configuration class for level, initialRoute, themeMode, customErrorWidget, forceDebugWidget
* **`ErrorStackStorageBase`** - Abstract interface for storage (enables custom implementations/mocking)
* **`ErrorStackStorage`** - Default FlutterSecureStorage implementation
* **`ErrorStackHandler`** - Encapsulates error handling logic, stack trace parsing, widget building
* **`DevPanelConfig`** - Configuration for dev panel features and log limits
* **`DevPanelStore`** - Central data store for all debug data (ChangeNotifier)

#### New APIs
* `ErrorStack.builder` - Builder function for MaterialApp to add dev panel and UI overlays
* `ErrorStack.showDevPanel(context)` - Programmatically show the dev panel
* `ErrorStack.isInitialized` - Check if ErrorStack has been initialized
* `DevPanelStore.instance` - Access logging APIs (debug, info, warning, error, logApi, trackRoute)

#### Copy Markdown Button
    - The "Copy markdown" button in `ErrorStackDebugWidget` now copies a structured markdown report to the clipboard (instead of opening a Google search). The report includes:
    * Exception message
    * Full stack trace
    * Source file path
    * Environment info (platform, OS version, timestamp, debug mode)

### Tests

* Comprehensive test suite with ~490 tests covering all components

### File Structure

```
lib/
├── error_stack.dart              # Main entry point & exports
├── error_stack_dio.dart          # Dio interceptor export
├── src/
│   ├── config/                   # Configuration classes
│   ├── storage/                  # Storage abstraction
│   ├── handler/                  # Error handling logic
│   └── dev_panel/                # Dev panel components
│       ├── data/                 # Store, models, collections
│       ├── widgets/              # Panel UI & tabs
│       ├── interceptors/         # Dio interceptor
│       └── observers/            # Navigator observer
└── widgets/                      # Error display widgets
```

## [1.10.4] - 2025-12-13

* fix dart analysis issues
* Update pubspec.yaml

## [1.10.3] - 2025-02-23

* Update GitHub workflows
* Update pubspec.yaml

## [1.10.2] - 2025-02-04

* Update the pubspec.yaml

## [1.10.1] - 2025-01-04

* Update the pubspec.yaml

## [1.10.0] - 2024-12-31

* Refactor as per flutter_lints suggestions
* Update copyright year
* Update the pubspec.yaml

## [1.9.1] - 2024-08-09

* Update debug widget

## [1.9.0] - 2024-07-24

* Merge PR from @SalihCanBinboga to allow the debug widget to be shown in release mode  

## [1.8.1] - 2024-07-20

* Update debug widget

## [1.8.0] - 2024-07-06

* Update default height of the debug widget to 580.0
* Set maxLines to 5 for the `exceptionAsString` value in the debug widget
* Update README.md

## [1.7.3] - 2024-06-15

* Update README.md

## [1.7.2] - 2024-06-15

* Update README.md

## [1.7.1] - 2024-06-14

* Add extra check in `ErrorWidget.builder` to get file name from the stack trace

## [1.7.0] - 2024-06-14

* Fix error with Web not working
* Add new Regex to catch more `classNames` in the stack trace
* `ErrorStackLogLevel.verbose` (default)
* Fix example project
* Update README.md

## [1.6.0] - 2024-06-12

* Update screenshots

## [1.5.0] - 2024-06-10

* Add `errorWidget` to ErrorStack init method. This allows you to set a custom error widget to be displayed when an error occurs in production.
 
## [1.4.0] - 2024-06-05

* Update debug and release widget to support responsive design.

## [1.3.4] - 2024-05-22

* Update pubspec.yaml

## [1.3.3] - 2024-05-17

* Update pubspec.yaml

## [1.3.2] - 2024-05-14

* Update pubspec.yaml

## [1.3.1] - 2024-05-12

* Update pubspec.yaml
* Update workflow

## [1.3.0] - 2024-05-11

* Update pubspec.yaml

## [1.2.1] - 2024-05-04

* Update logo
* Update README.md
* Small tweak to storage key

## [1.2.0] - 2024-05-01

* Update README.md

## [1.1.0] - 2024-05-01

* Remove `nylo` dependency.
* Add `flutter_secure_storage` dependency.
* Update debug and release widget.

## [1.0.0] - 2024-05-01

* Initial release.
