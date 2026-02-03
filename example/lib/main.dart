import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';

// Import all examples
import 'examples/basic_example.dart' as basic;
import 'examples/custom_error_widget_example.dart' as custom_error;
import 'examples/dev_panel_example.dart' as dev_panel;
import 'examples/dio_integration_example.dart' as dio_integration;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorStack.init(
    initialRoute: '/',
    level: ErrorStackLogLevel.verbose,
  );

  runApp(const ExampleLauncherApp());
}

class ExampleLauncherApp extends StatelessWidget {
  const ExampleLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error Stack Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      builder: ErrorStack.builder,
      home: const ExampleLauncherPage(),
    );
  }
}

class ExampleLauncherPage extends StatelessWidget {
  const ExampleLauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Stack Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.developer_mode),
            tooltip: 'Open Dev Panel',
            onPressed: () => ErrorStack.showDevPanel(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildExampleCard(
            context,
            title: 'Basic Example',
            description: 'Minimal Error Stack setup with ErrorStack.init() '
                'and ErrorStack.builder integration.',
            icon: Icons.play_arrow,
            color: Colors.blue,
            onTap: () => _navigateToExample(
              context,
              const basic.BasicExampleApp(),
            ),
          ),
          _buildExampleCard(
            context,
            title: 'Custom Error Widget',
            description: 'Customize the error display for release mode with '
                'branded screens and recovery actions.',
            icon: Icons.palette,
            color: Colors.deepPurple,
            onTap: () => _navigateToExample(
              context,
              const custom_error.CustomErrorWidgetApp(),
            ),
          ),
          _buildExampleCard(
            context,
            title: 'Dev Panel',
            description: 'Full developer panel demo with route tracking, '
                'console logging, and UI debug tools.',
            icon: Icons.developer_board,
            color: Colors.teal,
            onTap: () => _navigateToExample(
              context,
              const dev_panel.DevPanelExampleApp(),
            ),
          ),
          _buildExampleCard(
            context,
            title: 'Dio Integration',
            description: 'HTTP request/response logging with Dio using '
                'ErrorStackDioInterceptor.',
            icon: Icons.http,
            color: Colors.indigo,
            onTap: () => _navigateToExample(
              context,
              const dio_integration.DioIntegrationApp(),
            ),
          ),
          const SizedBox(height: 24),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.bug_report,
            size: 40,
            color: Colors.red.shade400,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Error Stack',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Custom error handling for Flutter applications\nwith developer-friendly debugging tools.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tip: Look for the ',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Icon(Icons.developer_mode, size: 16, color: Colors.grey.shade600),
            const Text(
              ' button to open the Dev Panel',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => ErrorStack.showDevPanel(context),
          child: const Text('Open Dev Panel'),
        ),
      ],
    );
  }

  void _navigateToExample(BuildContext context, Widget app) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => app,
      ),
    );
  }
}
