import 'dart:async';
import 'package:flutter/material.dart';
import '../data/dev_panel_store.dart';
import '../data/models/api_request_log.dart';
import '../data/models/log_entry.dart';
import '../data/models/log_level.dart';
import '../data/models/route_entry.dart';
import 'tabs/api_tab.dart';
import 'tabs/logs_tab.dart';
import 'tabs/routes_tab.dart';
import 'tabs/local_storage_tab.dart';
import 'tabs/ui_tab.dart';

/// The main dev panel bottom sheet with tabs.
class ErrorStackDevPanelSheet extends StatefulWidget {
  const ErrorStackDevPanelSheet({super.key});

  @override
  State<ErrorStackDevPanelSheet> createState() =>
      _ErrorStackDevPanelSheetState();
}

class _ErrorStackDevPanelSheetState extends State<ErrorStackDevPanelSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search controllers
  final TextEditingController _apiSearchController = TextEditingController();
  final TextEditingController _logSearchController = TextEditingController();

  // Filter state
  final Set<DevPanelLogLevel> _selectedLogLevels = {};
  String _apiSearchQuery = '';
  String _logSearchQuery = '';

  // Debounce timer
  Timer? _debounce;

  // Local mutable state
  List<ApiRequestLog> _apiRequests = [];
  List<LogEntry> _logs = [];
  List<RouteEntry> _routeStack = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();

    // Listen for updates
    DevPanelStore.instance.addListener(_loadData);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _apiSearchController.dispose();
    _logSearchController.dispose();
    _debounce?.cancel();
    DevPanelStore.instance.removeListener(_loadData);
    super.dispose();
  }

  void _loadData() {
    if (!mounted) return;
    setState(() {
      _apiRequests = DevPanelStore.instance.apiLogsReversed;
      _logs = DevPanelStore.instance.consoleLogsReversed;
      _routeStack = DevPanelStore.instance.routeHistoryReversed;
    });
  }

  void _onApiSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _apiSearchQuery = _apiSearchController.text.toLowerCase();
        });
      }
    });
  }

  void _onLogSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _logSearchQuery = _logSearchController.text.toLowerCase();
        });
      }
    });
  }

  void _onLogLevelToggle(DevPanelLogLevel level) {
    setState(() {
      if (_selectedLogLevels.contains(level)) {
        _selectedLogLevels.remove(level);
      } else {
        _selectedLogLevels.add(level);
      }
    });
  }

  List<ApiRequestLog> get _filteredApiRequests {
    if (_apiSearchQuery.isEmpty) return _apiRequests;
    return _apiRequests.where((req) {
      return req.url.toLowerCase().contains(_apiSearchQuery) ||
          req.method.toLowerCase().contains(_apiSearchQuery) ||
          (req.statusCode?.toString().contains(_apiSearchQuery) ?? false);
    }).toList();
  }

  List<LogEntry> get _filteredLogs {
    var filtered = _logs;

    // Filter by level
    if (_selectedLogLevels.isNotEmpty) {
      filtered = filtered
          .where((log) => _selectedLogLevels.contains(log.level))
          .toList();
    }

    // Filter by search
    if (_logSearchQuery.isNotEmpty) {
      filtered = filtered
          .where((log) => log.message.toLowerCase().contains(_logSearchQuery))
          .toList();
    }

    return filtered;
  }

  void _clearApiLogs() {
    DevPanelStore.instance.clearApiLogs();
  }

  void _clearConsoleLogs() {
    DevPanelStore.instance.clearConsoleLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: _hexColor("#1e1e1e"),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ApiTab(
                  apiRequests: _apiRequests,
                  filteredRequests: _filteredApiRequests,
                  searchController: _apiSearchController,
                  onClearLogs: _clearApiLogs,
                  onSearchChanged: _onApiSearchChanged,
                ),
                LogsTab(
                  logs: _logs,
                  filteredLogs: _filteredLogs,
                  searchController: _logSearchController,
                  selectedLevels: _selectedLogLevels,
                  onClearLogs: _clearConsoleLogs,
                  onSearchChanged: _onLogSearchChanged,
                  onLevelToggle: _onLogLevelToggle,
                ),
                RoutesTab(routeStack: _routeStack),
                const LocalStorageTab(),
                const UITab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _hexColor("#282c34"),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.developer_mode, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Developer Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _hexColor("#1e1e1e"),
      child: TabBar(
        controller: _tabController,
        indicatorColor: _hexColor("#d8b576"),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        isScrollable: false,
        tabs: const [
          Tab(text: 'API'),
          Tab(text: 'Logs'),
          Tab(text: 'Routes'),
          Tab(text: 'Storage'),
          Tab(text: 'UI'),
        ],
      ),
    );
  }

  Color _hexColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse(hexColor, radix: 16));
  }
}
