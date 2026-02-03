import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';

/// Basic Example - Minimal Error Stack Setup
///
/// This example demonstrates the simplest way to integrate Error Stack
/// into your Flutter application.
///
/// Key concepts:
/// - ErrorStack.init() - Initialize the package
/// - ErrorStack.builder - Wrap your app with debug tools
/// - Triggering errors to see the debug widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Error Stack with default settings
  await ErrorStack.init(
    initialRoute: '/',
    level: ErrorStackLogLevel.verbose,
  );

  runApp(const BasicExampleApp());
}

class BasicExampleApp extends StatelessWidget {
  const BasicExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Error Stack Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Wrap your app with ErrorStack.builder to enable debug tools
      builder: ErrorStack.builder,
      home: const BasicHomePage(),
    );
  }
}

class BasicHomePage extends StatelessWidget {
  const BasicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bug_report,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Stack Basic Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to trigger an error\nand see the debug widget in action.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _triggerError(context),
              icon: const Icon(Icons.error_outline),
              label: const Text('Trigger Error'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _triggerNullError(context),
              icon: const Icon(Icons.warning_amber),
              label: const Text('Trigger Null Error'),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'In debug mode, you\'ll see a detailed error screen '
                'with stack trace and Google search link.\n\n'
                'Look for the floating button at the bottom to access the Dev Panel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerError(BuildContext context) {
    // Navigate to a widget that will throw an error during build
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ErrorWidget(),
      ),
    );
  }

  void _triggerNullError(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NullErrorWidget(),
      ),
    );
  }
}

/// Widget that throws an error during build
class ErrorWidget extends StatelessWidget {
  const ErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // This will throw a TypeError
    throw Exception('This is a test error to demonstrate Error Stack!');
  }
}

/// Widget that throws a null error
class NullErrorWidget extends StatelessWidget {
  const NullErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Deliberately access null to trigger error
    dynamic data;
    return Text(data['key']); // Throws null error
  }
}
