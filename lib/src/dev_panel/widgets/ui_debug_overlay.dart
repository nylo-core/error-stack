import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../data/dev_panel_store.dart';

/// A widget that applies UI debug overlays based on DevPanelStore settings.
///
/// Wraps the child widget with various debug overlays including:
/// - Grid paper for alignment checking
/// - Layout bounds visualization
/// - Touch target warnings
/// - Safe area visualization
/// - Color blindness simulation
/// - Performance overlay
/// - Text scale override
class UIDebugOverlay extends StatelessWidget {
  /// The child widget to wrap with debug overlays.
  final Widget child;

  /// Creates a [UIDebugOverlay].
  const UIDebugOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DevPanelStore.instance,
      builder: (context, _) {
        final store = DevPanelStore.instance;

        // Apply layout bounds debug flag
        debugPaintSizeEnabled = store.showLayoutBounds;

        Widget result = child;

        // Apply text scale factor
        if (store.textScaleFactor != 1.0) {
          result = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(store.textScaleFactor),
            ),
            child: result,
          );
        }

        // Apply color blindness filter
        if (store.colorBlindnessMode != ColorBlindnessMode.none) {
          result = ColorFiltered(
            colorFilter: ColorFilter.matrix(
              _getColorBlindnessMatrix(store.colorBlindnessMode),
            ),
            child: result,
          );
        }

        // Stack overlays on top
        result = Stack(
          children: [
            result,
            // Grid paper overlay
            if (store.showGridPaper)
              Positioned.fill(
                child: IgnorePointer(
                  child: GridPaper(
                    color: Colors.cyan.withValues(alpha: 0.3),
                    interval: store.gridSpacing,
                    divisions: 1,
                    subdivisions: 1,
                  ),
                ),
              ),
            // Safe areas overlay
            if (store.showSafeAreas) const _SafeAreaOverlay(),
            // Performance overlay
            if (store.showPerformanceOverlay)
              Positioned.fill(
                child: PerformanceOverlay.allEnabled(),
              ),
          ],
        );

        return result;
      },
    );
  }

  /// Returns the color matrix for the specified color blindness mode.
  List<double> _getColorBlindnessMatrix(ColorBlindnessMode mode) {
    switch (mode) {
      case ColorBlindnessMode.none:
        return _identityMatrix;
      case ColorBlindnessMode.protanopia:
        return _protanopiaMatrix;
      case ColorBlindnessMode.deuteranopia:
        return _deuteranopiaMatrix;
      case ColorBlindnessMode.tritanopia:
        return _tritanopiaMatrix;
    }
  }

  static const List<double> _identityMatrix = [
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  // Protanopia (red-blind)
  static const List<double> _protanopiaMatrix = [
    0.567,
    0.433,
    0.0,
    0.0,
    0.0,
    0.558,
    0.442,
    0.0,
    0.0,
    0.0,
    0.0,
    0.242,
    0.758,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
  ];

  // Deuteranopia (green-blind)
  static const List<double> _deuteranopiaMatrix = [
    0.625,
    0.375,
    0.0,
    0.0,
    0.0,
    0.7,
    0.3,
    0.0,
    0.0,
    0.0,
    0.0,
    0.3,
    0.7,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
  ];

  // Tritanopia (blue-blind)
  static const List<double> _tritanopiaMatrix = [
    0.95,
    0.05,
    0.0,
    0.0,
    0.0,
    0.0,
    0.433,
    0.567,
    0.0,
    0.0,
    0.0,
    0.475,
    0.525,
    0.0,
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    0.0,
  ];
}

/// Overlay that visualizes device safe areas.
class _SafeAreaOverlay extends StatelessWidget {
  const _SafeAreaOverlay();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final viewInsets = mediaQuery.viewInsets;

    return IgnorePointer(
      child: Stack(
        children: [
          // Top safe area
          if (padding.top > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: padding.top,
              child: Container(
                color: Colors.red.withValues(alpha: 0.3),
                child: Center(
                  child: Text(
                    'Top: ${padding.top.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          // Bottom safe area
          if (padding.bottom > 0)
            Positioned(
              bottom: viewInsets.bottom,
              left: 0,
              right: 0,
              height: padding.bottom,
              child: Container(
                color: Colors.red.withValues(alpha: 0.3),
                child: Center(
                  child: Text(
                    'Bottom: ${padding.bottom.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          // Left safe area
          if (padding.left > 0)
            Positioned(
              top: padding.top,
              bottom: padding.bottom + viewInsets.bottom,
              left: 0,
              width: padding.left,
              child: Container(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
          // Right safe area
          if (padding.right > 0)
            Positioned(
              top: padding.top,
              bottom: padding.bottom + viewInsets.bottom,
              right: 0,
              width: padding.right,
              child: Container(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
          // Keyboard area
          if (viewInsets.bottom > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: viewInsets.bottom,
              child: Container(
                color: Colors.purple.withValues(alpha: 0.3),
                child: Center(
                  child: Text(
                    'Keyboard: ${viewInsets.bottom.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
