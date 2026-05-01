import 'package:error_stack/error_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage Tab Example
///
/// This example demonstrates the Dev Panel's Storage tab, which inspects
/// `SharedPreferences` and `FlutterSecureStorage` at runtime.
///
/// Key concepts:
/// - Writing typed values to SharedPreferences (String, bool, int, double, List)
/// - Writing secrets to FlutterSecureStorage (encrypted)
/// - Inspecting, editing, searching, and deleting entries from the Storage tab
/// - ErrorStack.showDevPanel() to jump straight into the inspector

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorStack.init(
    initialRoute: '/',
    level: ErrorStackLogLevel.verbose,
  );

  runApp(const StorageTabExampleApp());
}

class StorageTabExampleApp extends StatelessWidget {
  const StorageTabExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storage Tab Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      builder: ErrorStack.builder,
      home: const StorageTabHomePage(),
    );
  }
}

class StorageTabHomePage extends StatefulWidget {
  const StorageTabHomePage({super.key});

  @override
  State<StorageTabHomePage> createState() => _StorageTabHomePageState();
}

class _StorageTabHomePageState extends State<StorageTabHomePage> {
  static const _secureStorage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Tab Demo'),
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
            _buildSectionHeader('Shared Preferences'),
            _buildSharedPreferencesSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Secure Storage'),
            _buildSecureStorageSection(),
            const SizedBox(height: 24),
            _buildSectionHeader('Inspect in Dev Panel'),
            _buildDevPanelAccessSection(),
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

  Widget _buildSharedPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unencrypted key-value storage. Tap a button to write a value, '
              'then open the Dev Panel\'s Storage tab to view it.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _saveUsername,
                  icon: const Icon(Icons.person, size: 18),
                  label: const Text('String: username'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saveDarkMode,
                  icon: const Icon(Icons.dark_mode, size: 18),
                  label: const Text('Bool: dark_mode'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _incrementLaunchCount,
                  icon: const Icon(Icons.add_circle, size: 18),
                  label: const Text('Int: launch_count++'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saveFontScale,
                  icon: const Icon(Icons.format_size, size: 18),
                  label: const Text('Double: font_scale'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saveRecentSearches,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('List: recent_searches'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addBulkSampleData,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Add bulk sample data'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _clearSharedPreferences,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Remove all SharedPreferences',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureStorageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Encrypted storage suited for tokens, API keys, and other '
              'secrets. Backed by Keychain on iOS and EncryptedSharedPreferences '
              'on Android.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _saveAuthToken,
                  icon: const Icon(Icons.vpn_key, size: 18),
                  label: const Text('Save auth_token'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saveApiKey,
                  icon: const Icon(Icons.api, size: 18),
                  label: const Text('Save api_key'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saveUserPin,
                  icon: const Icon(Icons.pin, size: 18),
                  label: const Text('Save user_pin'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearSecureStorage,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Remove all SecureStorage',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevPanelAccessSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open the Dev Panel and switch to the Storage tab to view, '
              'edit, search, and delete entries.',
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

  Future<void> _saveUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', 'jane_doe');
    _showSnackBar('Saved username = "jane_doe"');
  }

  Future<void> _saveDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool('dark_mode_enabled') ?? false;
    await prefs.setBool('dark_mode_enabled', !current);
    _showSnackBar('Saved dark_mode_enabled = ${!current}');
  }

  Future<void> _incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final next = (prefs.getInt('launch_count') ?? 0) + 1;
    await prefs.setInt('launch_count', next);
    _showSnackBar('Saved launch_count = $next');
  }

  Future<void> _saveFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', 1.25);
    _showSnackBar('Saved font_scale = 1.25');
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', [
      'flutter widgets',
      'error stack dev panel',
      'shared preferences',
    ]);
    _showSnackBar('Saved recent_searches (3 items)');
  }

  Future<void> _addBulkSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', 'en_US');
    await prefs.setString('last_route', '/dashboard');
    await prefs.setBool('onboarding_complete', true);
    await prefs.setInt('app_version_code', 142);
    await prefs.setDouble('cache_size_mb', 24.5);
    _showSnackBar('5 sample entries added');
  }

  Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _showSnackBar('SharedPreferences cleared');
  }

  Future<void> _saveAuthToken() async {
    await _secureStorage.write(
      key: 'auth_token',
      value:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJqYW5lX2RvZSIsImlhdCI6MTcxNzAwMDAwMH0.sample',
    );
    _showSnackBar('Saved auth_token');
  }

  Future<void> _saveApiKey() async {
    await _secureStorage.write(
      key: 'api_key',
      value: 'demo_api_key_4eC39HqLyjWDarjtT1zdp7dc',
    );
    _showSnackBar('Saved api_key');
  }

  Future<void> _saveUserPin() async {
    await _secureStorage.write(key: 'user_pin', value: '1234');
    _showSnackBar('Saved user_pin');
  }

  Future<void> _clearSecureStorage() async {
    await _secureStorage.deleteAll();
    _showSnackBar('SecureStorage cleared');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
