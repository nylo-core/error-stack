import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/api_request_log.dart';

/// Speed filter categories for API requests.
enum SpeedFilter {
  fast, // < 200ms
  acceptable, // 200-500ms
  slow, // 500ms-1s
  verySlow, // > 1s
  poor, // > 3s
}

/// Tab displaying API request logs.
class ApiTab extends StatefulWidget {
  final List<ApiRequestLog> apiRequests;
  final List<ApiRequestLog> filteredRequests;
  final TextEditingController searchController;
  final VoidCallback onClearLogs;
  final VoidCallback onSearchChanged;

  const ApiTab({
    super.key,
    required this.apiRequests,
    required this.filteredRequests,
    required this.searchController,
    required this.onClearLogs,
    required this.onSearchChanged,
  });

  @override
  State<ApiTab> createState() => _ApiTabState();
}

class _ApiTabState extends State<ApiTab> {
  // Filter state
  final Set<String> _selectedMethods = {};
  final Set<int> _selectedStatusCategories = {}; // 2, 4, 5 for 2xx, 4xx, 5xx
  final Set<SpeedFilter> _selectedSpeedFilters = {};

  List<ApiRequestLog> get _filteredWithFilters {
    var requests = widget.filteredRequests;

    // Apply method filter
    if (_selectedMethods.isNotEmpty) {
      requests = requests
          .where((r) => _selectedMethods.contains(r.method.toUpperCase()))
          .toList();
    }

    // Apply status code filter
    if (_selectedStatusCategories.isNotEmpty) {
      requests = requests.where((r) {
        if (r.statusCode == null) return false;
        final category = r.statusCode! ~/ 100;
        return _selectedStatusCategories.contains(category);
      }).toList();
    }

    // Apply speed filter
    if (_selectedSpeedFilters.isNotEmpty) {
      requests = requests.where((r) {
        final speed = _getSpeedCategory(r.durationMs);
        return _selectedSpeedFilters.contains(speed);
      }).toList();
    }

    return requests;
  }

  SpeedFilter _getSpeedCategory(int durationMs) {
    if (durationMs < 200) return SpeedFilter.fast;
    if (durationMs < 500) return SpeedFilter.acceptable;
    if (durationMs < 1000) return SpeedFilter.slow;
    if (durationMs < 3000) return SpeedFilter.verySlow;
    return SpeedFilter.poor;
  }

  bool get _hasActiveFilters =>
      _selectedMethods.isNotEmpty ||
      _selectedStatusCategories.isNotEmpty ||
      _selectedSpeedFilters.isNotEmpty;

  int get _errorCount => widget.apiRequests
      .where((r) => r.statusCode != null && r.statusCode! >= 400)
      .length;

  int get _slowCount =>
      widget.apiRequests.where((r) => r.durationMs >= 1000).length;

  void _showClearConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text(
          'Clear API Logs',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to clear all ${widget.apiRequests.length} API logs?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              widget.onClearLogs();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Color(0xFF1e1e1e),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Filter Requests',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_hasActiveFilters)
                          GestureDetector(
                            onTap: () {
                              setSheetState(() {
                                _selectedMethods.clear();
                                _selectedStatusCategories.clear();
                                _selectedSpeedFilters.clear();
                              });
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => Navigator.of(sheetContext).pop(),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection(
                            title: 'HTTP Method',
                            setSheetState: setSheetState,
                            children: [
                              _buildFilterChip('GET', _selectedMethods,
                                  Colors.blue, setSheetState),
                              _buildFilterChip('POST', _selectedMethods,
                                  Colors.green, setSheetState),
                              _buildFilterChip('PUT', _selectedMethods,
                                  Colors.orange, setSheetState),
                              _buildFilterChip('DELETE', _selectedMethods,
                                  Colors.red, setSheetState),
                              _buildFilterChip('PATCH', _selectedMethods,
                                  Colors.purple, setSheetState),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildFilterSection(
                            title: 'Status Code',
                            setSheetState: setSheetState,
                            children: [
                              _buildStatusFilterChip('2xx Success', 2,
                                  Colors.green, setSheetState),
                              _buildStatusFilterChip('4xx Client Error', 4,
                                  Colors.orange, setSheetState),
                              _buildStatusFilterChip('5xx Server Error', 5,
                                  Colors.red, setSheetState),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildFilterSection(
                            title: 'Response Speed',
                            setSheetState: setSheetState,
                            children: [
                              _buildSpeedFilterChip(
                                '< 200ms',
                                'Fast',
                                SpeedFilter.fast,
                                Colors.green,
                                setSheetState,
                              ),
                              _buildSpeedFilterChip(
                                '200-500ms',
                                'Acceptable',
                                SpeedFilter.acceptable,
                                Colors.lightGreen,
                                setSheetState,
                              ),
                              _buildSpeedFilterChip(
                                '500ms-1s',
                                'Slow',
                                SpeedFilter.slow,
                                Colors.yellow[700]!,
                                setSheetState,
                              ),
                              _buildSpeedFilterChip(
                                '> 1s',
                                'Very Slow',
                                SpeedFilter.verySlow,
                                Colors.orange,
                                setSheetState,
                              ),
                              _buildSpeedFilterChip(
                                '> 3s',
                                'Poor',
                                SpeedFilter.poor,
                                Colors.red,
                                setSheetState,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required StateSetter setSheetState,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    Set<String> selectedSet,
    Color color,
    StateSetter setSheetState,
  ) {
    final isSelected = selectedSet.contains(label);
    return GestureDetector(
      onTap: () {
        setSheetState(() {
          if (isSelected) {
            selectedSet.remove(label);
          } else {
            selectedSet.add(label);
          }
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(
    String label,
    int category,
    Color color,
    StateSetter setSheetState,
  ) {
    final isSelected = _selectedStatusCategories.contains(category);
    return GestureDetector(
      onTap: () {
        setSheetState(() {
          if (isSelected) {
            _selectedStatusCategories.remove(category);
          } else {
            _selectedStatusCategories.add(category);
          }
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[700]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedFilterChip(
    String time,
    String label,
    SpeedFilter filter,
    Color color,
    StateSetter setSheetState,
  ) {
    final isSelected = _selectedSpeedFilters.contains(filter);
    return GestureDetector(
      onTap: () {
        setSheetState(() {
          if (isSelected) {
            _selectedSpeedFilters.remove(filter);
          } else {
            _selectedSpeedFilters.add(filter);
          }
        });
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[700]!,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[300],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedRequests = _filteredWithFilters;

    return Container(
      color: _hexColor("#1e1e1e"),
      child: Column(
        children: [
          // Search bar and action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchBar(),
                ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showFilterSheet(context),
                      icon: Icon(
                        Icons.filter_list,
                        color:
                            _hasActiveFilters ? Colors.blue : Colors.grey[400],
                      ),
                      tooltip: 'Filter requests',
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: widget.apiRequests.isEmpty
                      ? null
                      : () => _showClearConfirmation(context),
                  icon: Icon(
                    Icons.block,
                    color: widget.apiRequests.isEmpty
                        ? Colors.grey[700]
                        : Colors.red,
                  ),
                  tooltip: 'Clear API logs',
                ),
              ],
            ),
          ),
          // Stats row
          if (widget.apiRequests.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _buildStatsRow(displayedRequests.length),
            ),
          // Results
          Expanded(
            child: displayedRequests.isEmpty
                ? _buildEmptyState(
                    widget.apiRequests.isEmpty
                        ? 'No API requests logged'
                        : 'No matching requests',
                    Icons.http,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: displayedRequests.length,
                    itemBuilder: (context, index) {
                      final request = displayedRequests[index];
                      return _ApiRequestItem(request: request);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int displayedCount) {
    final total = widget.apiRequests.length;
    final errors = _errorCount;
    final slow = _slowCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.http, color: Colors.grey[500], size: 16),
          const SizedBox(width: 6),
          Text(
            _hasActiveFilters ? '$displayedCount / $total' : '$total',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _hasActiveFilters ? ' requests' : ' total requests',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const Spacer(),
          if (slow > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$slow slow',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (errors > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$errors errors',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
        controller: widget.searchController,
        onChanged: (_) => widget.onSearchChanged(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by URL',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          suffixIcon: widget.searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 18),
                  onPressed: () {
                    widget.searchController.clear();
                    widget.onSearchChanged();
                  },
                )
              : null,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
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

class _ApiRequestItem extends StatefulWidget {
  final ApiRequestLog request;

  const _ApiRequestItem({required this.request});

  @override
  State<_ApiRequestItem> createState() => _ApiRequestItemState();
}

class _ApiRequestItemState extends State<_ApiRequestItem> {
  ApiRequestLog get request => widget.request;

  String _formatRequestForCopy() {
    final buffer = StringBuffer();
    buffer.writeln('=== REQUEST DETAILS ===');
    buffer.writeln();
    buffer.writeln('URL: ${request.url}');
    buffer.writeln('Method: ${request.method}');
    if (request.statusCode != null) {
      buffer.writeln('Status: ${request.statusCode}');
    }
    buffer.writeln('Duration: ${request.formattedDuration}');
    buffer.writeln('Timestamp: ${request.formattedTimestamp}');
    if (request.error != null) {
      buffer.writeln('Error: ${request.error}');
    }
    buffer.writeln();
    buffer.writeln('=== REQUEST HEADERS ===');
    buffer.writeln(_formatData(request.requestHeaders));
    buffer.writeln();
    buffer.writeln('=== REQUEST BODY ===');
    buffer.writeln(_formatData(request.requestBody));
    buffer.writeln();
    buffer.writeln('=== RESPONSE DATA ===');
    buffer.writeln(_formatData(request.responseBody));
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isError = request.statusCode != null && request.statusCode! >= 400;
    final statusColor = isError ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: () => _showRequestDetails(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMethodColor(request.method),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.method,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    request.url,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (request.statusCode != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.statusCode.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  request.formattedDuration,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, color: Colors.grey[400], size: 16),
                const SizedBox(width: 4),
                Text(
                  request.formattedTimestamp,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(BuildContext context) {
    final methodColor = _getMethodColor(request.method);
    final statusColor = request.statusCode != null && request.statusCode! >= 400
        ? Colors.red
        : Colors.green;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        bool showCopied = false;
        final copiedSections = <String>{};
        final copiedFields = <String>{};
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            void copyDetails() {
              Clipboard.setData(ClipboardData(text: _formatRequestForCopy()));
              setModalState(() => showCopied = true);
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (modalContext.mounted) {
                  setModalState(() => showCopied = false);
                }
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Color(0xFF1e1e1e),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.http, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Request Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (showCopied)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Copied!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: copyDetails,
                            child: const Icon(Icons.copy,
                                color: Colors.white, size: 20),
                          ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => Navigator.of(modalContext).pop(),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMetaRow(
                            'URL',
                            request.url,
                            color: Colors.white,
                            copyable: true,
                            setModalState: setModalState,
                            copiedFields: copiedFields,
                          ),
                          _buildMetaRow('Method', request.method,
                              color: methodColor, bold: true),
                          if (request.statusCode != null)
                            _buildMetaRow(
                                'Status', request.statusCode.toString(),
                                color: statusColor, bold: true),
                          _buildMetaRow('Duration', request.formattedDuration,
                              color: Colors.white),
                          _buildMetaRow(
                              'Requested at', request.formattedTimestamp,
                              color: Colors.white),
                          if (request.error != null)
                            _buildMetaRow('Error', request.error!,
                                color: Colors.red),
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            title: 'Request Headers',
                            content: _formatData(request.requestHeaders),
                            setModalState: setModalState,
                            copiedSections: copiedSections,
                          ),
                          _buildDetailSection(
                            title: 'Request Body',
                            content: _formatData(request.requestBody),
                            setModalState: setModalState,
                            copiedSections: copiedSections,
                          ),
                          _buildDetailSection(
                            title: 'Response Data',
                            content: _formatData(request.responseBody),
                            setModalState: setModalState,
                            copiedSections: copiedSections,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetaRow(
    String label,
    String value, {
    Color color = Colors.white,
    bool bold = false,
    bool copyable = false,
    StateSetter? setModalState,
    Set<String>? copiedFields,
  }) {
    final isCopied = copiedFields?.contains(label) ?? false;

    void copyValue() {
      Clipboard.setData(ClipboardData(text: value));
      if (setModalState != null && copiedFields != null) {
        setModalState(() => copiedFields.add(label));
        Future.delayed(const Duration(milliseconds: 1500), () {
          setModalState(() => copiedFields.remove(label));
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            if (isCopied)
              Text(
                'Copied!',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              GestureDetector(
                onTap: copyValue,
                child: Icon(
                  Icons.copy,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required String content,
    required StateSetter setModalState,
    required Set<String> copiedSections,
    bool isError = false,
  }) {
    final baseColor = isError ? Colors.red : Colors.white;
    final isCopied = copiedSections.contains(title);

    void copySection() {
      Clipboard.setData(ClipboardData(text: content));
      setModalState(() => copiedSections.add(title));
      Future.delayed(const Duration(milliseconds: 1500), () {
        setModalState(() => copiedSections.remove(title));
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha: 0.4)
              : Colors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: baseColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isCopied)
                Text(
                  'Copied!',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                GestureDetector(
                  onTap: copySection,
                  child: Icon(
                    Icons.copy,
                    color: Colors.grey[500],
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatData(dynamic data) {
    if (data == null) return 'None';
    try {
      if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      }
    } catch (_) {
      // Fallback to toString if encoding fails.
    }
    return data.toString();
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
