import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:error_stack/widgets/error_stack_debug_widget.dart';

void main() {
  group('ErrorStackDebugWidget', () {
    late FlutterErrorDetails errorDetails;

    setUp(() {
      errorDetails = FlutterErrorDetails(
        exception: Exception('Test error message'),
        stack: StackTrace.fromString('''
#0      main (package:my_app/main.dart:10:5)
#1      _runMainZoned (dart:ui/hooks.dart:142:25)
'''),
        library: 'test library',
        context: ErrorDescription('test context'),
      );
    });

    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackDebugWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(ErrorStackDebugWidget), findsOneWidget);
    });

    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackDebugWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.textContaining('Test error message'), findsOneWidget);
    });

    testWidgets('contains Scaffold', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackDebugWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('contains SafeArea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorStackDebugWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    group('constructor', () {
      testWidgets('accepts required errorDetails', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.byType(ErrorStackDebugWidget), findsOneWidget);
      });

      testWidgets('accepts custom initialRoute', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(
              errorDetails: errorDetails,
              initialRoute: '/home',
            ),
          ),
        );

        expect(find.byType(ErrorStackDebugWidget), findsOneWidget);
      });

      testWidgets('accepts initialThemeMode light', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(
              errorDetails: errorDetails,
              initialThemeMode: 'light',
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.white);
      });

      testWidgets('accepts initialThemeMode dark', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(
              errorDetails: errorDetails,
              initialThemeMode: 'dark',
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNot(Colors.white));
      });

      testWidgets('accepts onThemeChanged callback', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(
              errorDetails: errorDetails,
              onThemeChanged: (theme) async {},
            ),
          ),
        );

        expect(find.byType(ErrorStackDebugWidget), findsOneWidget);
      });
    });

    group('theme mode', () {
      testWidgets('defaults to light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.white);
      });

      testWidgets('invalid theme mode defaults to light', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(
              errorDetails: errorDetails,
              initialThemeMode: 'invalid',
            ),
          ),
        );

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, Colors.white);
      });
    });

    group('layout', () {
      testWidgets('uses ListView', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('uses Stack for layering', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.byType(Stack), findsWidgets);
      });

      testWidgets('content is centered', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.byType(Center), findsWidgets);
      });
    });

    group('error display', () {
      testWidgets('displays error occurred header', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.text('Error Occurred!'), findsOneWidget);
      });

      testWidgets('has Google search link', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.textContaining('Google'), findsOneWidget);
      });
    });

    group('different error types', () {
      testWidgets('handles Exception', (tester) async {
        final exceptionError = FlutterErrorDetails(
          exception: Exception('Exception message'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: exceptionError),
          ),
        );

        expect(find.textContaining('Exception message'), findsOneWidget);
      });

      testWidgets('handles Error', (tester) async {
        final stateError = FlutterErrorDetails(
          exception: StateError('State error message'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: stateError),
          ),
        );

        expect(find.textContaining('State error message'), findsOneWidget);
      });

      testWidgets('handles null stack trace', (tester) async {
        final nullStackError = FlutterErrorDetails(
          exception: Exception('No stack'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: nullStackError),
          ),
        );

        expect(find.byType(ErrorStackDebugWidget), findsOneWidget);
      });
    });

    group('version display', () {
      testWidgets('displays ErrorStack version', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        expect(find.textContaining('ErrorStack'), findsOneWidget);
      });
    });

    group('interactive elements', () {
      testWidgets('has theme toggle button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        // Look for brightness icons (light/dark mode toggle)
        expect(
          find.byIcon(Icons.brightness_4).evaluate().isNotEmpty ||
              find.byIcon(Icons.brightness_7).evaluate().isNotEmpty,
          isTrue,
        );
      });

      testWidgets('has copy button', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ErrorStackDebugWidget(errorDetails: errorDetails),
          ),
        );

        // Two copy icons: one for exception text, one for markdown report
        expect(find.byIcon(Icons.copy), findsNWidgets(2));
      });
    });
  });
}
