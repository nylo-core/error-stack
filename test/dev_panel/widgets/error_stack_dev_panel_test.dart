import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/src/dev_panel/widgets/error_stack_dev_panel.dart';
import 'package:error_stack/src/dev_panel/data/dev_panel_store.dart';

void main() {
  group('ErrorStackDevPanel', () {
    setUp(() {
      DevPanelStore.init();
    });

    testWidgets('long-press on dev mode tab opens the dev panel sheet',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackDevPanel(
            child: const Scaffold(body: Center(child: Text('content'))),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.developer_mode);
      expect(iconFinder, findsOneWidget);

      await tester.longPress(iconFinder);
      await tester.pumpAndSettle();

      // The bottom sheet should be present (modal).
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets(
        'long-press works when used via MaterialApp.builder (real example structure)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => ErrorStackDevPanel(child: child!),
          home: const Scaffold(body: Center(child: Text('content'))),
        ),
      );

      final iconFinder = find.byIcon(Icons.developer_mode);
      expect(iconFinder, findsOneWidget);

      await tester.longPress(iconFinder);
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
    });
  });
}
