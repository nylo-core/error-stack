import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/log_entry.dart';
import '../../data/models/log_level.dart';

/// Tab displaying console logs.
class LogsTab extends StatelessWidget {
  final List<LogEntry> logs;
  final List<LogEntry> filteredLogs;
  final TextEditingController searchController;
  final Set<DevPanelLogLevel> selectedLevels;
  final VoidCallback onClearLogs;
  final VoidCallback onSearchChanged;
  final void Function(DevPanelLogLevel) onLevelToggle;

  const LogsTab({
    super.key,
    required this.logs,
    required this.filteredLogs,
    required this.searchController,
    required this.selectedLevels,
    required this.onClearLogs,
    required this.onSearchChanged,
    required this.onLevelToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _hexColor("#1e1e1e"),
      child: Column(
        children: [
          // Search bar and clear button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchBar(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: logs.isEmpty ? null : onClearLogs,
                  icon: Icon(
                    Icons.delete_outline,
                    color: logs.isEmpty ? Colors.grey[700] : Colors.red,
                  ),
                  tooltip: 'Clear logs',
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                _buildFilterChip(DevPanelLogLevel.debug, 'Debug'),
                const SizedBox(width: 8),
                _buildFilterChip(DevPanelLogLevel.info, 'Info'),
                const SizedBox(width: 8),
                _buildFilterChip(DevPanelLogLevel.warning, 'Warning'),
                const SizedBox(width: 8),
                _buildFilterChip(DevPanelLogLevel.error, 'Error'),
              ],
            ),
          ),
          // Results
          Expanded(
            child: filteredLogs.isEmpty
                ? _buildEmptyState(
                    logs.isEmpty ? 'No logs captured' : 'No matching logs',
                    Icons.article_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _LogEntryItem(entry: log);
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
        controller: searchController,
        onChanged: (_) => onSearchChanged(),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search logs...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 18),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterChip(DevPanelLogLevel level, String label) {
    final isSelected = selectedLevels.contains(level);
    final color = _getLogLevelColor(level);

    return GestureDetector(
      onTap: () => onLevelToggle(level),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.grey[400],
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
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

  Color _getLogLevelColor(DevPanelLogLevel level) {
    switch (level) {
      case DevPanelLogLevel.debug:
        return Colors.blue;
      case DevPanelLogLevel.info:
        return Colors.green;
      case DevPanelLogLevel.warning:
        return Colors.orange;
      case DevPanelLogLevel.error:
        return Colors.red;
    }
  }

  Color _hexColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse(hexColor, radix: 16));
  }
}

class _LogEntryItem extends StatefulWidget {
  final LogEntry entry;

  const _LogEntryItem({required this.entry});

  @override
  State<_LogEntryItem> createState() => _LogEntryItemState();
}

class _LogEntryItemState extends State<_LogEntryItem> {
  bool _showCopied = false;

  LogEntry get entry => widget.entry;

  String _formatEntryForCopy() {
    final buffer = StringBuffer();
    buffer.writeln('[${entry.levelName}] ${entry.formattedTimestamp}');
    if (entry.tag != null) {
      buffer.writeln('Tag: ${entry.tag}');
    }
    buffer.writeln('Message:');
    buffer.writeln(entry.message);
    if (entry.stackTrace != null) {
      buffer.writeln();
      buffer.writeln('Stack trace:');
      buffer.writeln(entry.stackTrace);
    }
    return buffer.toString();
  }

  void _copyEntry() {
    Clipboard.setData(ClipboardData(text: _formatEntryForCopy()));
    setState(() => _showCopied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showCopied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLogLevelColor(entry.level);
    final icon = _getLogLevelIcon(entry.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: color, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.levelName,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (_showCopied)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    'Copied!',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: _copyEntry,
                    child: Icon(
                      Icons.copy,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.formattedTimestamp,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  Text(
                    entry.timeAgo,
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          if (entry.tag != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tag: ${entry.tag}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
          if (entry.stackTrace != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.stackTrace!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontFamily: 'monospace',
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLogLevelColor(DevPanelLogLevel level) {
    switch (level) {
      case DevPanelLogLevel.debug:
        return Colors.blue;
      case DevPanelLogLevel.info:
        return Colors.green;
      case DevPanelLogLevel.warning:
        return Colors.orange;
      case DevPanelLogLevel.error:
        return Colors.red;
    }
  }

  IconData _getLogLevelIcon(DevPanelLogLevel level) {
    switch (level) {
      case DevPanelLogLevel.debug:
        return Icons.bug_report;
      case DevPanelLogLevel.info:
        return Icons.info_outline;
      case DevPanelLogLevel.warning:
        return Icons.warning_amber;
      case DevPanelLogLevel.error:
        return Icons.error_outline;
    }
  }
}
