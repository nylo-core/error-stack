import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';

/// Custom Error Widget Example
///
/// This example demonstrates how to customize the error display
/// for release mode with your own branded error widget.
///
/// Key concepts:
/// - errorWidget parameter for custom release mode errors
/// - Custom recovery actions (retry, go home, report bug)
/// - Branded error screens matching your app's design

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorStack.init(
    initialRoute: '/',
    level: ErrorStackLogLevel.verbose,
    // Provide a custom error widget for release mode
    errorWidget: (errorDetails) => CustomErrorScreen(
      errorDetails: errorDetails,
    ),
  );

  runApp(const CustomErrorWidgetApp());
}

class CustomErrorWidgetApp extends StatelessWidget {
  const CustomErrorWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Error Widget Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      builder: ErrorStack.builder,
      home: const CustomErrorHomePage(),
    );
  }
}

class CustomErrorHomePage extends StatelessWidget {
  const CustomErrorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Error Widget'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.palette,
              size: 64,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Custom Error Widget Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'In release mode, errors show a custom branded screen '
                'instead of the default. In debug mode, you\'ll still see '
                'the debug widget.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _triggerError(context),
              icon: const Icon(Icons.error_outline),
              label: const Text('Trigger Error'),
            ),
            const SizedBox(height: 24),
            const Divider(indent: 40, endIndent: 40),
            const SizedBox(height: 16),
            const Text(
              'Preview custom error screen:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomErrorScreen(
                      errorDetails: FlutterErrorDetails(
                        exception: Exception('Preview: Custom error screen'),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.preview),
              label: const Text('Preview Error Screen'),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerError(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BrokenWidget(),
      ),
    );
  }
}

class BrokenWidget extends StatelessWidget {
  const BrokenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    throw Exception('Something went wrong loading this content!');
  }
}

/// Custom branded error screen for release mode
///
/// This widget demonstrates how to create a user-friendly error screen
/// with recovery actions that match your app's branding.
class CustomErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorScreen({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Branded error illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sentiment_dissatisfied,
                  size: 64,
                  color: Colors.deepPurple.shade400,
                ),
              ),
              const SizedBox(height: 32),

              // Error title
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error description
              Text(
                'We encountered an unexpected error. '
                'Don\'t worry, your data is safe.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Recovery actions
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _handleRetry(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleGoHome(context),
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: () => _handleReportBug(context),
                icon: const Icon(Icons.bug_report),
                label: const Text('Report this issue'),
              ),

              const Spacer(),

              // Error code for support
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Error ID: ${errorDetails.exception.hashCode.toRadixString(16).toUpperCase()}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRetry(BuildContext context) {
    // Pop back and let the user try again
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleGoHome(BuildContext context) {
    // Navigate to home and clear the stack
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleReportBug(BuildContext context) {
    // Show a dialog to report the bug
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Would you like to report this issue to our team?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                errorDetails.exception.toString(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bug report submitted. Thank you!'),
                ),
              );
            },
            child: const Text('Send Report'),
          ),
        ],
      ),
    );
  }
}
