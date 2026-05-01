import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'error_stack_dev_panel_sheet.dart';

/// ErrorStackDevPanel
///
/// Wraps the app content and provides a "Dev Mode" tab on the right edge
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

    final childContext = _childKey.currentContext;
    if (childContext == null) return;

    // When ErrorStackDevPanel sits below a Navigator (e.g. as a route body),
    // the child's own context can locate the Navigator via ancestors.
    if (Navigator.maybeOf(childContext) != null) {
      ErrorStackDevPanel.showDevPanel(childContext);
      return;
    }

    // When used via MaterialApp.builder, the Navigator is *inside* widget.child
    // (MaterialApp passes its Navigator as the builder's child argument), so
    // walking ancestors finds nothing. Walk descendants to find a context that
    // is below the Navigator and use that to show the modal.
    final navigatorChildContext =
        _findDescendantNavigatorChildContext(childContext as Element);
    if (navigatorChildContext != null) {
      ErrorStackDevPanel.showDevPanel(navigatorChildContext);
    }
  }

  /// Searches descendants of [root] for the first [Navigator] and returns
  /// one of its child contexts (so [Navigator.of] can find it via ancestors).
  static BuildContext? _findDescendantNavigatorChildContext(Element root) {
    Element? navigatorElement;
    void findNavigator(Element element) {
      if (navigatorElement != null) return;
      if (element.widget is Navigator) {
        navigatorElement = element;
        return;
      }
      element.visitChildren(findNavigator);
    }

    findNavigator(root);
    if (navigatorElement == null) return null;

    BuildContext? descendantContext;
    navigatorElement!.visitChildren((child) {
      descendantContext ??= child;
    });
    return descendantContext;
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
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onLongPress: _onLongPress,
              child: Container(
                height: 100,
                width: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
        ),
      ],
    );
  }
}
