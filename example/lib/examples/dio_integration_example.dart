import 'package:flutter/material.dart';
import 'package:error_stack/error_stack.dart';
import 'package:error_stack/error_stack_dio.dart';
import 'package:dio/dio.dart';

/// Dio Integration Example
///
/// This example demonstrates HTTP request/response logging with Dio
/// using the ErrorStackDioInterceptor.
///
/// Key concepts:
/// - ErrorStackDioInterceptor setup
/// - Making API calls and viewing in dev panel
/// - Request filtering to exclude certain endpoints
/// - Viewing request/response details in the API tab
///
/// Note: This example requires the 'dio' package as a dependency.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ErrorStack.init(
    initialRoute: '/',
    level: ErrorStackLogLevel.verbose,
  );

  runApp(const DioIntegrationApp());
}

class DioIntegrationApp extends StatelessWidget {
  const DioIntegrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Integration Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      builder: ErrorStack.builder,
      home: const DioIntegrationHomePage(),
    );
  }
}

class DioIntegrationHomePage extends StatefulWidget {
  const DioIntegrationHomePage({super.key});

  @override
  State<DioIntegrationHomePage> createState() => _DioIntegrationHomePageState();
}

class _DioIntegrationHomePageState extends State<DioIntegrationHomePage> {
  late final Dio _dio;
  bool _isLoading = false;
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Add the ErrorStack interceptor for API logging
    _dio.interceptors.add(
      ErrorStackDioInterceptor(
        enabled: true,
        // Optional: Filter out certain requests from logging
        filter: (options) {
          // Don't log requests to analytics endpoints
          if (options.path.contains('/analytics')) {
            return false;
          }
          return true;
        },
      ),
    );
  }

  Future<void> _makeGetRequest() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await _dio.get(
        'https://jsonplaceholder.typicode.com/posts/1',
      );
      setState(() {
        _result = 'GET Success!\n\nTitle: ${response.data['title']}';
      });
    } on DioException catch (e) {
      setState(() {
        _error = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makePostRequest() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final response = await _dio.post(
        'https://jsonplaceholder.typicode.com/posts',
        data: {
          'title': 'Error Stack Test',
          'body': 'Testing Dio integration with Error Stack',
          'userId': 1,
        },
      );
      setState(() {
        _result =
            'POST Success!\n\nCreated post with ID: ${response.data['id']}';
      });
    } on DioException catch (e) {
      setState(() {
        _error = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeFailingRequest() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      await _dio.get(
        'https://jsonplaceholder.typicode.com/posts/999999',
      );
    } on DioException catch (e) {
      setState(() {
        _error = 'Expected Error: ${e.response?.statusCode ?? e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _makeMultipleRequests() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      // Make several requests in sequence
      await _dio.get('https://jsonplaceholder.typicode.com/users/1');
      await _dio.get('https://jsonplaceholder.typicode.com/posts?userId=1');
      await _dio.get('https://jsonplaceholder.typicode.com/comments?postId=1');

      setState(() {
        _result =
            'Made 3 API requests!\nCheck the Dev Panel API tab to see all requests.';
      });
    } on DioException catch (e) {
      setState(() {
        _error = 'Error: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dio Integration'),
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
            // Setup code card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        const Text(
                          'Setup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                      child: const Text(
                        'final dio = Dio();\n'
                        'dio.interceptors.add(\n'
                        '  ErrorStackDioInterceptor(),\n'
                        ');',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // API Requests section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.http, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        const Text(
                          'Make API Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All requests are logged to the Dev Panel API tab.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _isLoading ? null : _makeGetRequest,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('GET'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _isLoading ? null : _makePostRequest,
                          icon: const Icon(Icons.upload, size: 18),
                          label: const Text('POST'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _isLoading ? null : _makeFailingRequest,
                          icon: const Icon(Icons.error_outline, size: 18),
                          label: const Text('404 Error'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: _isLoading ? null : _makeMultipleRequests,
                          icon: const Icon(Icons.repeat, size: 18),
                          label: const Text('Multiple'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result/Error display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.indigo.shade400),
                        const SizedBox(width: 8),
                        const Text(
                          'Result',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _error != null
                              ? Colors.red.shade200
                              : _result != null
                                  ? Colors.green.shade200
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _error != null
                              ? Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                )
                              : _result != null
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _result!,
                                            style: const TextStyle(
                                                color: Colors.green),
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      'Make a request to see results here.\n\nOpen the Dev Panel to view request details including headers, body, and timing.',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Request filtering info
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_alt, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Request Filtering',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use the filter parameter to exclude certain requests from logging:',
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ErrorStackDioInterceptor(\n'
                        '  filter: (options) {\n'
                        '    // Skip analytics endpoints\n'
                        '    if (options.path.contains(\'/analytics\')) {\n'
                        '      return false;\n'
                        '    }\n'
                        '    return true;\n'
                        '  },\n'
                        ')',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Open Dev Panel button
            FilledButton.icon(
              onPressed: () => ErrorStack.showDevPanel(context),
              icon: const Icon(Icons.developer_board),
              label: const Text('Open Dev Panel to View API Logs'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
