import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/route_argument_data.dart';
import '../../data/models/route_entry.dart';

/// Tab displaying navigation route history.
class RoutesTab extends StatefulWidget {
  final List<RouteEntry> routeStack;

  const RoutesTab({
    super.key,
    required this.routeStack,
  });

  @override
  State<RoutesTab> createState() => _RoutesTabState();
}

class _RoutesTabState extends State<RoutesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get routes filtered by search query (excludes internal routes).
  List<RouteEntry> get _filteredRoutes {
    // Filter out internal routes (like _ModalBottomSheetRoute from dev panel)
    var routes = widget.routeStack.where((r) => !r.isInternalRoute).toList();
    if (_searchQuery.isEmpty) return routes;
    return routes
        .where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _hexColor("#1e1e1e"),
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(),
          ),
          // Results
          Expanded(
            child: _filteredRoutes.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredRoutes.length,
                    itemBuilder: (context, index) {
                      final route = _filteredRoutes[index];
                      final isCurrent = index == 0;
                      return _RouteEntryItem(
                        entry: route,
                        isCurrent: isCurrent,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _onSearchChanged(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search routes...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    String subtitle;
    IconData icon;

    if (widget.routeStack.isEmpty) {
      message = 'No routes tracked';
      subtitle = 'Add ErrorStackNavigatorObserver\nto your MaterialApp';
      icon = Icons.route;
    } else if (_searchQuery.isNotEmpty) {
      message = 'No matching routes';
      subtitle = 'Try a different search term';
      icon = Icons.search_off;
    } else {
      message = 'No routes found';
      subtitle = 'Navigate through your app to see routes';
      icon = Icons.route;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
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

class _RouteEntryItem extends StatelessWidget {
  final RouteEntry entry;
  final bool isCurrent;

  const _RouteEntryItem({
    required this.entry,
    required this.isCurrent,
  });

  void _showRouteDetails(BuildContext context) {
    final actionColor = _getActionColor(entry.action);

    bool nameCopied = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              void copyName() {
                Clipboard.setData(ClipboardData(text: entry.name));
                setModalState(() => nameCopied = true);
                Future.delayed(const Duration(milliseconds: 1500), () {
                  setModalState(() => nameCopied = false);
                });
              }

              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.route,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Route Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  // Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Route name section
                        _buildDetailSection(
                          'Route Name',
                          entry.name,
                          icon: Icons.route,
                          valueColor: isCurrent ? Colors.green : Colors.white,
                          trailing: nameCopied
                              ? Text(
                                  'Copied!',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: copyName,
                                  child: Icon(
                                    Icons.copy,
                                    color: Colors.grey[500],
                                    size: 16,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Action and timestamp
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailCard(
                                'Action',
                                _getActionLabel(entry.action),
                                badgeColor:
                                    isCurrent ? Colors.green : actionColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDetailCard(
                                'Timestamp',
                                _formatFullTimestamp(entry.timestamp),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Previous route
                        if (entry.previousRoute != null) ...[
                          _buildDetailSection(
                            'Previous Route',
                            entry.previousRoute!,
                            icon: Icons.history,
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Arguments
                        if (entry.arguments != null) ...[
                          _buildArgumentsWidget(entry.arguments),
                          const SizedBox(height: 16),
                        ],
                        // Route settings section
                        if (_hasRouteSettings()) ...[
                          _buildSettingsSection(),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value,
      {IconData? icon, Color? valueColor, Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.grey[500], size: 14),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDetailCard(String label, String value, {Color? badgeColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          if (badgeColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCodeSection(String label, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            code,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  bool _hasRouteSettings() {
    return entry.routeType != null ||
        entry.isFullscreenDialog != null ||
        entry.maintainState != null ||
        entry.opaque != null;
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: Colors.grey[500], size: 14),
            const SizedBox(width: 6),
            Text(
              'Route Settings',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              if (entry.routeType != null)
                _buildSettingRow('Type', entry.routeType!),
              if (entry.isFullscreenDialog != null)
                _buildSettingRow('Fullscreen Dialog',
                    entry.isFullscreenDialog! ? 'Yes' : 'No'),
              if (entry.maintainState != null)
                _buildSettingRow(
                    'Maintain State', entry.maintainState! ? 'Yes' : 'No'),
              if (entry.opaque != null)
                _buildSettingRow('Opaque', entry.opaque! ? 'Yes' : 'No'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullTimestamp(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Builds the arguments widget based on the type of arguments.
  Widget _buildArgumentsWidget(Object? args) {
    if (args == null) {
      return _buildCodeSection('Arguments', 'null');
    }

    // Handle serialized map from nylo_support's ArgumentsWrapper.toMap()
    if (RouteArgumentData.isArgumentsWrapperMap(args)) {
      try {
        final argsJson = jsonDecode(args.toString());
        return _buildRouteArgumentDataSection(
          RouteArgumentData.fromMap(argsJson),
        );
      } catch (_) {
        // Fallback to raw string display
        return _buildCodeSection('Arguments', args.toString());
      }
    }

    if (args is Map) {
      return _buildCodeSection('Arguments', _formatMapAsString(args));
    }

    return _buildCodeSection('Arguments', args.toString());
  }

  /// Formats a Map as a pretty-printed JSON string.
  String _formatMapAsString(Map args) {
    try {
      return const JsonEncoder.withIndent('  ').convert(args);
    } catch (_) {
      // Fallback for non-JSON-encodable maps
      final buffer = StringBuffer('{\n');
      args.forEach((key, value) {
        buffer.writeln('  "$key": ${_formatValue(value)},');
      });
      buffer.write('}');
      return buffer.toString();
    }
  }

  /// Formats any dynamic value for display.
  String _formatDynamic(dynamic data) {
    if (data == null) return 'null';
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  String _formatValue(dynamic value) {
    if (value is String) return '"$value"';
    if (value is Map || value is List) return value.toString();
    return value.toString();
  }

  /// Builds a section for displaying RouteArgumentData properties.
  Widget _buildRouteArgumentDataSection(RouteArgumentData wrapper) {
    List<Widget> detailSection = [
      // Base Arguments data
      if (wrapper.data != null)
        _buildSubSection('Data', _formatDynamic(wrapper.data)),

      // Query Parameters
      if (wrapper.queryParameters != null &&
          wrapper.queryParameters!.isNotEmpty)
        _buildQueryParametersSection(wrapper.queryParameters!),

      // Simple properties container
      if (_hasSimpleProperties(wrapper)) _buildSimplePropertiesSection(wrapper),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.data_object, color: Colors.grey[500], size: 14),
            const SizedBox(width: 6),
            Text(
              'Details',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Detail sections
        if (detailSection.isNotEmpty) ...detailSection,
        if (detailSection.isEmpty)
          Text(
            'No data available.',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
          ),
      ],
    );
  }

  /// Checks if wrapper has any simple properties to display.
  bool _hasSimpleProperties(RouteArgumentData wrapper) {
    return wrapper.prefix != null ||
        wrapper.pageTransitionType != null ||
        wrapper.transitionType != null;
  }

  /// Builds a subsection with label and code content.
  /// Content is scrollable if it exceeds max height.
  Widget _buildSubSection(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: SelectableText(
                content,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section for query parameters as key-value rows.
  Widget _buildQueryParametersSection(Map<String, String> params) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Query Parameters',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: params.entries
                  .map((e) => _buildKeyValueRow(e.key, e.value))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds simple properties (prefix, transition types) in a card.
  Widget _buildSimplePropertiesSection(RouteArgumentData wrapper) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            if (wrapper.prefix != null)
              _buildKeyValueRow('Prefix', wrapper.prefix!),
            if (wrapper.pageTransitionType != null)
              _buildKeyValueRow(
                'Page Transition',
                _formatEnumString(wrapper.pageTransitionType!),
              ),
            if (wrapper.transitionType != null)
              _buildKeyValueRow(
                'Transition Type',
                _formatEnumString(wrapper.transitionType!),
              ),
          ],
        ),
      ),
    );
  }

  /// Formats an enum string for display (extracts the name after the dot).
  String _formatEnumString(String enumStr) {
    final dotIndex = enumStr.lastIndexOf('.');
    return dotIndex >= 0 ? enumStr.substring(dotIndex + 1) : enumStr;
  }

  /// Builds a key-value row for displaying properties.
  Widget _buildKeyValueRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ),
          Center(
              child:
                  Icon(Icons.arrow_forward, color: Colors.grey[600], size: 10)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor(entry.action);

    return GestureDetector(
      onTap: () => _showRouteDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrent
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: isCurrent ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? Colors.green : actionColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrent)
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 12),
                      if (isCurrent) const SizedBox(width: 4),
                      Text(
                        isCurrent ? 'CURRENT' : _getActionLabel(entry.action),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Route name
                Expanded(
                  child: Text(
                    entry.name,
                    style: TextStyle(
                      color: isCurrent ? Colors.green : Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Timestamp
                Text(
                  entry.formattedTimestamp,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(width: 8),
                // Tap indicator
                Icon(Icons.chevron_right, color: Colors.grey[600], size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(RouteAction action) {
    switch (action) {
      case RouteAction.push:
        return Colors.blue;
      case RouteAction.pop:
        return Colors.orange;
      case RouteAction.replace:
        return Colors.purple;
      case RouteAction.remove:
        return Colors.red;
    }
  }

  String _getActionLabel(RouteAction action) {
    switch (action) {
      case RouteAction.push:
        return 'PUSH';
      case RouteAction.pop:
        return 'POP';
      case RouteAction.replace:
        return 'REPLACE';
      case RouteAction.remove:
        return 'REMOVE';
    }
  }
}
