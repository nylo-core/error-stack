import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';

/// Dev Panel Example
///
/// This example demonstrates the full developer panel capabilities
/// including route tracking, console logging, and UI debug tools.
///
/// Key concepts:
/// - ErrorStackNavigatorObserver for route tracking
/// - DevPanelStore.instance for console logging
/// - All log levels (debug, info, warning, error)
/// - ErrorStack.showDevPanel() programmatic access
/// - UI debug tools (grid paper, layout bounds, color blindness)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorStack.init(
    initialRoute: '/',
    level: ErrorStackLogLevel.verbose,
  );

  runApp(const DevPanelExampleApp());
}

class DevPanelExampleApp extends StatelessWidget {
  const DevPanelExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Panel Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      builder: ErrorStack.builder,
      // Add the navigator observer for route tracking
      navigatorObservers: [
        ErrorStackNavigatorObserver(),
      ],
      home: const DevPanelHomePage(),
    );
  }
}

class DevPanelHomePage extends StatelessWidget {
  const DevPanelHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Panel Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.developer_mode),
            tooltip: 'Open Dev Panel',
            onPressed: () => ErrorStack.showDevPanel(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Console Logging'),
            _buildLoggingSection(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Route Tracking'),
            _buildNavigationSection(context),
            const SizedBox(height: 24),
            _buildSectionHeader('UI Debug Tools'),
            _buildUIToolsSection(context),
            const SizedBox(height: 24),
            _buildSectionHeader('Dev Panel Access'),
            _buildDevPanelAccessSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoggingSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap buttons to add logs. View them in the Dev Panel\'s Logs tab.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _LogButton(
                  label: 'Debug',
                  color: Colors.grey,
                  icon: Icons.bug_report,
                  onPressed: () {
                    DevPanelStore.instance.debug(
                      'Debug message at ${DateTime.now()}',
                      tag: 'DevPanel',
                    );
                    _showSnackBar(context, 'Debug log added');
                  },
                ),
                _LogButton(
                  label: 'Info',
                  color: Colors.blue,
                  icon: Icons.info,
                  onPressed: () {
                    DevPanelStore.instance.info(
                      'User viewed the dev panel example',
                      tag: 'Analytics',
                      metadata: {'screen': 'dev_panel_example'},
                    );
                    _showSnackBar(context, 'Info log added');
                  },
                ),
                _LogButton(
                  label: 'Warning',
                  color: Colors.orange,
                  icon: Icons.warning,
                  onPressed: () {
                    DevPanelStore.instance.warning(
                      'Memory usage is above 80%',
                      tag: 'Performance',
                      metadata: {'memoryUsage': '82%'},
                    );
                    _showSnackBar(context, 'Warning log added');
                  },
                ),
                _LogButton(
                  label: 'Error',
                  color: Colors.red,
                  icon: Icons.error,
                  onPressed: () {
                    DevPanelStore.instance.error(
                      'Failed to load user preferences',
                      tag: 'Storage',
                      stackTrace: StackTrace.current.toString(),
                      metadata: {'errorCode': 'E_PREF_001'},
                    );
                    _showSnackBar(context, 'Error log added');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Add multiple logs at once for demonstration
                DevPanelStore.instance.debug('App started');
                DevPanelStore.instance.info('Loading user data...');
                DevPanelStore.instance.info('User data loaded successfully');
                DevPanelStore.instance
                    .warning('Network latency detected: 500ms');
                DevPanelStore.instance.info('Rendering home screen');
                _showSnackBar(context, '5 logs added');
              },
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add Multiple Logs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigate to different pages. View route history in the Routes tab.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/profile'),
                        builder: (context) => const _SamplePage(
                          title: 'Profile',
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('Profile'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(
                          name: '/settings',
                          arguments: {'theme': 'dark'},
                        ),
                        builder: (context) => const _SamplePage(
                          title: 'Settings',
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/notifications'),
                        builder: (context) => const _SamplePage(
                          title: 'Notifications',
                          color: Colors.orange,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text('Notifications'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIToolsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Toggle UI debug overlays to inspect layout and accessibility.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ListenableBuilder(
              listenable: DevPanelStore.instance,
              builder: (context, _) {
                return Column(
                  children: [
                    _buildToggleTile(
                      'Grid Paper',
                      'Show grid overlay for alignment',
                      Icons.grid_4x4,
                      DevPanelStore.instance.showGridPaper,
                      (value) => DevPanelStore.instance.toggleGridPaper(value),
                    ),
                    _buildToggleTile(
                      'Layout Bounds',
                      'Show widget boundaries',
                      Icons.crop_square,
                      DevPanelStore.instance.showLayoutBounds,
                      (value) =>
                          DevPanelStore.instance.toggleLayoutBounds(value),
                    ),
                    _buildToggleTile(
                      'Slow Animations',
                      'Slow down all animations',
                      Icons.slow_motion_video,
                      DevPanelStore.instance.slowAnimations,
                      (value) =>
                          DevPanelStore.instance.toggleSlowAnimations(value),
                    ),
                    _buildToggleTile(
                      'Performance Overlay',
                      'Show FPS and render times',
                      Icons.speed,
                      DevPanelStore.instance.showPerformanceOverlay,
                      (value) => DevPanelStore.instance
                          .togglePerformanceOverlay(value),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Color Blindness Simulation',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: DevPanelStore.instance,
              builder: (context, _) {
                return SegmentedButton<ColorBlindnessMode>(
                  segments: const [
                    ButtonSegment(
                      value: ColorBlindnessMode.none,
                      label: Text('None'),
                    ),
                    ButtonSegment(
                      value: ColorBlindnessMode.protanopia,
                      label: Text('Prot.'),
                    ),
                    ButtonSegment(
                      value: ColorBlindnessMode.deuteranopia,
                      label: Text('Deut.'),
                    ),
                    ButtonSegment(
                      value: ColorBlindnessMode.tritanopia,
                      label: Text('Trit.'),
                    ),
                  ],
                  selected: {DevPanelStore.instance.colorBlindnessMode},
                  onSelectionChanged: (modes) {
                    DevPanelStore.instance.setColorBlindnessMode(modes.first);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                DevPanelStore.instance.resetUIDebugSettings();
                _showSnackBar(context, 'UI debug settings reset');
              },
              icon: const Icon(Icons.restore),
              label: const Text('Reset All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }

  Widget _buildDevPanelAccessSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Access the dev panel programmatically from anywhere in your app.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => ErrorStack.showDevPanel(context),
                    icon: const Icon(Icons.developer_board),
                    label: const Text('Open Dev Panel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Code:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ErrorStack.showDevPanel(context);',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;

  const _LogButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _SamplePage extends StatelessWidget {
  final String title;
  final Color color;

  const _SamplePage({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Log page view
    DevPanelStore.instance.info('Viewed $title page', tag: 'Navigation');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color.withValues(alpha: 0.2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pages,
              size: 64,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Page',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This navigation was tracked by\nErrorStackNavigatorObserver',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
