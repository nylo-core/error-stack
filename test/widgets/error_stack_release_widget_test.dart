import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/widgets/error_stack_release_widget.dart';

void main() {
  group('ErrorStackReleaseWidget', () {
    late FlutterErrorDetails errorDetails;

    setUp(() {
      errorDetails = FlutterErrorDetails(
        exception: Exception('Test error'),
        stack: StackTrace.current,
        library: 'test library',
        context: ErrorDescription('test context'),
      );
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(ErrorStackReleaseWidget), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.text('Oops, something went wrong!'), findsOneWidget);
    });

    testWidgets('displays instructions to restart', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.text('An error occurred.'), findsOneWidget);
      expect(
        find.text('Please restart the app or report this issue.'),
        findsOneWidget,
      );
    });

    testWidgets('has red error icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(iconWidget.color, Colors.red);
    });

    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(iconWidget.size, 50.0);
    });

    testWidgets('contains Scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('contains SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('title has correct style', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      final textWidget = tester.widget<Text>(
        find.text('Oops, something went wrong!'),
      );
      expect(textWidget.style?.fontSize, 18.0);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('has divider between title and description', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('content is centered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('handles different error types', (tester) async {
      final differentError = FlutterErrorDetails(
        exception: StateError('State error'),
        library: 'widgets library',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: differentError),
        ),
      );

      // Should still display the generic error message
      expect(find.text('Oops, something went wrong!'), findsOneWidget);
    });

    testWidgets('handles null stack trace', (tester) async {
      final errorWithNullStack = FlutterErrorDetails(
        exception: Exception('No stack trace'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackReleaseWidget(errorDetails: errorWithNullStack),
        ),
      );

      expect(find.byType(ErrorStackReleaseWidget), findsOneWidget);
      expect(find.text('Oops, something went wrong!'), findsOneWidget);
    });

    group('layout', () {
      testWidgets('uses ListView for scrolling', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackReleaseWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('ListView shrinkWraps content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackReleaseWidget(errorDetails: errorDetails),
          ),
        );

        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.shrinkWrap, true);
      });

      testWidgets('uses Stack for positioning', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackReleaseWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.byType(Stack), findsWidgets);
      });

      testWidgets('has SizedBox with fixed height', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackReleaseWidget(errorDetails: errorDetails),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.byType(SizedBox).first,
        );
        expect(sizedBox.height, 450);
      });
    });

    group('accessibility', () {
      testWidgets('text is readable', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackReleaseWidget(errorDetails: errorDetails),
          ),
        );

        // Verify all text elements are present and visible
        expect(find.text('Oops, something went wrong!'), findsOneWidget);
        expect(find.text('An error occurred.'), findsOneWidget);
        expect(
          find.text('Please restart the app or report this issue.'),
          findsOneWidget,
        );
      });
    });
  });
}
