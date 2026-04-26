import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/storage_entry.dart';

/// Tab displaying local storage data (secure storage + shared preferences).
class LocalStorageTab extends StatefulWidget {
  const LocalStorageTab({super.key});

  @override
  State<LocalStorageTab> createState() => _LocalStorageTabState();
}

class _LocalStorageTabState extends State<LocalStorageTab> {
  List<StorageEntry> _secureStorageEntries = [];
  List<StorageEntry> _sharedPrefsEntries = [];
  bool _isLoading = true;
  bool _secureStorageAvailable = true;
  bool _sharedPrefsAvailable = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  List<StorageEntry> get _filteredSecureStorageEntries {
    if (_searchQuery.isEmpty) return _secureStorageEntries;
    return _secureStorageEntries
        .where((e) =>
            e.key.toLowerCase().contains(_searchQuery) ||
            (e.value?.toString().toLowerCase().contains(_searchQuery) ?? false))
        .toList();
  }

  List<StorageEntry> get _filteredSharedPrefsEntries {
    if (_searchQuery.isEmpty) return _sharedPrefsEntries;
    return _sharedPrefsEntries
        .where((e) =>
            e.key.toLowerCase().contains(_searchQuery) ||
            (e.value?.toString().toLowerCase().contains(_searchQuery) ?? false))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  Future<void> _loadStorageData() async {
    setState(() => _isLoading = true);

    try {
      // Load secure storage
      const secureStorage = FlutterSecureStorage();
      final secureAll = await secureStorage.readAll();
      _secureStorageEntries = secureAll.entries
          .map((e) => StorageEntry(
                key: e.key,
                value: e.value,
                source: StorageSource.secureStorage,
              ))
          .toList();
      _secureStorageAvailable = true;
    } catch (e) {
      _secureStorageEntries = [];
      _secureStorageAvailable = false;
    }

    try {
      // Load shared preferences
      final prefs = await SharedPreferences.getInstance();
      _sharedPrefsEntries = prefs.getKeys().map((key) {
        final value = prefs.get(key);
        return StorageEntry(
          key: key,
          value: value?.toString() ?? '',
          source: StorageSource.sharedPreferences,
        );
      }).toList();
      _sharedPrefsAvailable = true;
    } catch (e) {
      _sharedPrefsEntries = [];
      _sharedPrefsAvailable = false;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteEntry(StorageEntry entry) async {
    try {
      if (entry.source == StorageSource.secureStorage) {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.delete(key: entry.key);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(entry.key);
      }
      await _loadStorageData();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _updateEntry(StorageEntry entry, String newValue) async {
    try {
      if (entry.source == StorageSource.secureStorage) {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: entry.key, value: newValue);
      } else {
        final prefs = await SharedPreferences.getInstance();
        // SharedPreferences stores as String for simplicity in dev panel
        await prefs.setString(entry.key, newValue);
      }
      await _loadStorageData();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _createEntry(
      String key, String value, StorageSource source) async {
    try {
      if (source == StorageSource.secureStorage) {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: key, value: value);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      }
      await _loadStorageData();
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _clearAllStorage() async {
    try {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.deleteAll();
    } catch (e) {
      // Handle error silently
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Handle error silently
    }

    await _loadStorageData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _hexColor("#1e1e1e"),
      child: Column(
        children: [
          // Header with refresh button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.storage, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Local Storage',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  tooltip: 'Add entry',
                ),
                IconButton(
                  onPressed: _showClearAllConfirmation,
                  icon: const Icon(Icons.delete_sweep, color: Colors.white),
                  tooltip: 'Clear all storage',
                ),
                IconButton(
                  onPressed: _loadStorageData,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_secureStorageEntries.isEmpty && _sharedPrefsEntries.isEmpty) {
      return _buildEmptyState();
    }

    final filteredSecure = _filteredSecureStorageEntries;
    final filteredPrefs = _filteredSharedPrefsEntries;

    if (_searchQuery.isNotEmpty &&
        filteredSecure.isEmpty &&
        filteredPrefs.isEmpty) {
      return _buildEmptyState(message: 'No entries match "$_searchQuery"');
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildSection(
          'Secure Storage',
          Icons.lock,
          filteredSecure,
        ),
        const SizedBox(height: 16),
        _buildSection(
          'Shared Preferences',
          Icons.settings,
          filteredPrefs,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState({String message = 'No storage data found'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storage, color: Colors.grey[600], size: 48),
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

  Widget _buildSection(
    String title,
    IconData icon,
    List<StorageEntry> entries,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${entries.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No entries',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
          )
        else
          ...entries.map((entry) => _StorageEntryItem(
                entry: entry,
                onDelete: () => _showDeleteConfirmation(entry),
                onEdit: () => _showEditDialog(entry),
              )),
      ],
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
          hintText: 'Search by key',
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
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    StorageSource selectedSource = _secureStorageAvailable
        ? StorageSource.secureStorage
        : StorageSource.sharedPreferences;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Add Storage Entry',
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
                const SizedBox(height: 20),
                // Storage type selector
                Text(
                  'Storage Type',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _secureStorageAvailable
                            ? () => setModalState(() =>
                                selectedSource = StorageSource.secureStorage)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedSource == StorageSource.secureStorage
                                ? Colors.blue.withValues(alpha: 0.3)
                                : Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  selectedSource == StorageSource.secureStorage
                                      ? Colors.blue
                                      : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 16,
                                color: _secureStorageAvailable
                                    ? (selectedSource ==
                                            StorageSource.secureStorage
                                        ? Colors.blue
                                        : Colors.grey[400])
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Secure',
                                style: TextStyle(
                                  color: _secureStorageAvailable
                                      ? (selectedSource ==
                                              StorageSource.secureStorage
                                          ? Colors.blue
                                          : Colors.grey[400])
                                      : Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: selectedSource ==
                                          StorageSource.secureStorage
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _sharedPrefsAvailable
                            ? () => setModalState(() => selectedSource =
                                StorageSource.sharedPreferences)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedSource ==
                                    StorageSource.sharedPreferences
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedSource ==
                                      StorageSource.sharedPreferences
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.settings,
                                size: 16,
                                color: _sharedPrefsAvailable
                                    ? (selectedSource ==
                                            StorageSource.sharedPreferences
                                        ? Colors.green
                                        : Colors.grey[400])
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Prefs',
                                style: TextStyle(
                                  color: _sharedPrefsAvailable
                                      ? (selectedSource ==
                                              StorageSource.sharedPreferences
                                          ? Colors.green
                                          : Colors.grey[400])
                                      : Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: selectedSource ==
                                          StorageSource.sharedPreferences
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_secureStorageAvailable || !_sharedPrefsAvailable) ...[
                  const SizedBox(height: 8),
                  Text(
                    !_secureStorageAvailable
                        ? 'Secure Storage unavailable on this platform'
                        : 'Shared Preferences unavailable',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 11,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Key',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: keyController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter key name...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Value',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: valueController,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'Enter value...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (keyController.text.trim().isEmpty) return;
                      Navigator.of(ctx).pop();
                      _createEntry(
                        keyController.text.trim(),
                        valueController.text,
                        selectedSource,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedSource == StorageSource.secureStorage
                              ? Colors.blue
                              : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add Entry',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(StorageEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Entry',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${entry.key}"?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteEntry(entry);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Clear All Storage',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete all storage data? This will clear both Secure Storage and Shared Preferences.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _clearAllStorage();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(StorageEntry entry) {
    final controller = TextEditingController(
      text: entry.value?.toString() ?? '',
    );
    bool keyCopied = false;
    bool valueCopied = false;
    bool isOpen = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          void copy(String text, void Function(bool) setFlag) {
            Clipboard.setData(ClipboardData(text: text));
            setFlag(true);
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (isOpen) setFlag(false);
            });
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Edit Value',
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
                  const SizedBox(height: 16),
                  _buildLabelRow(
                    label: 'Key',
                    copied: keyCopied,
                    onCopy: () => copy(
                      entry.key,
                      (v) => setModalState(() => keyCopied = v),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLabelRow(
                    label: 'Value',
                    copied: valueCopied,
                    onCopy: () => copy(
                      controller.text,
                      (v) => setModalState(() => valueCopied = v),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black38,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter value...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _updateEntry(entry, controller.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    ).whenComplete(() => isOpen = false);
  }

  Widget _buildLabelRow({
    required String label,
    required bool copied,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (copied)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Copied!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          GestureDetector(
            onTap: onCopy,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(Icons.copy, size: 14, color: Colors.grey[400]),
            ),
          ),
      ],
    );
  }

  Color _hexColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse(hexColor, radix: 16));
  }
}

class _StorageEntryItem extends StatefulWidget {
  final StorageEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _StorageEntryItem({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_StorageEntryItem> createState() => _StorageEntryItemState();
}

class _StorageEntryItemState extends State<_StorageEntryItem> {
  bool _showCopied = false;

  void _copyToClipboard() {
    final copyText = 'Key: "${widget.entry.key}"\n'
        'Value: "${widget.entry.value?.toString() ?? ''}"';
    Clipboard.setData(ClipboardData(text: copyText));
    setState(() => _showCopied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _showCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onEdit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                Expanded(
                  child: Text(
                    widget.entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_showCopied)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Copied!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    color: Colors.grey[400],
                    onPressed: _copyToClipboard,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copy key & value',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16),
                    color: Colors.grey[400],
                    onPressed: widget.onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit value',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: Colors.red[400],
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete entry',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _truncateValue(widget.entry.value?.toString() ?? ''),
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateValue(String value) {
    if (value.length > 200) {
      return '${value.substring(0, 200)}...';
    }
    return value;
  }
}
