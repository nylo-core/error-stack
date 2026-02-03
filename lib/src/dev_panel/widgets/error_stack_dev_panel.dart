import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'error_stack_dev_panel_sheet.dart';

/// ErrorStackDevPanel
///
/// Wraps the app content and provides a "Dev Mode" bar at the bottom
/// that opens the dev panel on long-press.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   builder: (context, child) => ErrorStackDevPanel(child: child!),
/// )
/// ```
class ErrorStackDevPanel extends StatefulWidget {
  /// The child widget to wrap.
  final Widget child;

  /// Whether the dev panel bar is visible.
  final bool enabled;

  /// Creates an [ErrorStackDevPanel].
  const ErrorStackDevPanel({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<ErrorStackDevPanel> createState() => _ErrorStackDevPanelState();

  /// Shows the dev panel programmatically.
  static void showDevPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (modalContext) => const ErrorStackDevPanelSheet(),
    );
  }
}

class _ErrorStackDevPanelState extends State<ErrorStackDevPanel> {
  /// Key to access the child widget's context (which has Navigator access).
  final GlobalKey _childKey = GlobalKey();

  void _onLongPress() {
    HapticFeedback.mediumImpact();

    // Use the child's context to access the Navigator.
    // The child contains the Navigator when used with MaterialApp.builder.
    final childContext = _childKey.currentContext;
    if (childContext != null) {
      ErrorStackDevPanel.showDevPanel(childContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Stack(
      children: [
        KeyedSubtree(
          key: _childKey,
          child: widget.child,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onLongPress: _onLongPress,
            child: Container(
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Dev Panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.developer_mode,
                    size: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
