import 'package:flutter/material.dart';
import '../../data/dev_panel_store.dart';

/// Tab providing UI debugging tools.
///
/// Allows developers to toggle visual overlays and accessibility
/// settings to test their UI during development.
class UITab extends StatefulWidget {
  const UITab({super.key});

  @override
  State<UITab> createState() => _UITabState();
}

class _UITabState extends State<UITab> {
  @override
  void initState() {
    super.initState();
    DevPanelStore.instance.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    DevPanelStore.instance.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = DevPanelStore.instance;

    return Container(
      color: _hexColor("#1e1e1e"),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Overlays',
            Icons.grid_on,
            [
              _buildToggleRow(
                'Grid Paper',
                'Show alignment grid overlay',
                store.showGridPaper,
                (value) => store.toggleGridPaper(value),
                trailing: _buildGridSpacingDropdown(store),
              ),
              _buildToggleRow(
                'Layout Bounds',
                'Show widget boundaries',
                store.showLayoutBounds,
                (value) => store.toggleLayoutBounds(value),
              ),
              _buildToggleRow(
                'Safe Areas',
                'Visualize device safe zones',
                store.showSafeAreas,
                (value) => store.toggleSafeAreas(value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Accessibility',
            Icons.accessibility,
            [
              _buildSliderRow(
                'Text Scale',
                store.textScaleFactor,
                0.5,
                3.0,
                (value) => store.setTextScaleFactor(value),
              ),
              _buildColorBlindnessRow(store),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            'Performance',
            Icons.speed,
            [
              _buildToggleRow(
                'Slow Animations',
                'Reduce animation speed (5x slower)',
                store.slowAnimations,
                (value) => store.toggleSlowAnimations(value),
              ),
              _buildToggleRow(
                'Performance Overlay',
                'Show FPS and rendering stats',
                store.showPerformanceOverlay,
                (value) => store.togglePerformanceOverlay(value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildResetButton(store),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _hexColor("#d8b576"), size: 18),
            const SizedBox(width: 8),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: _hexColor("#d8b576"),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing,
            const SizedBox(width: 12),
          ],
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: _hexColor("#d8b576"),
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildGridSpacingDropdown(DevPanelStore store) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<double>(
        value: store.gridSpacing,
        isDense: true,
        dropdownColor: Colors.grey[800],
        underline: const SizedBox(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        items: const [
          DropdownMenuItem(value: 8.0, child: Text('8px')),
          DropdownMenuItem(value: 16.0, child: Text('16px')),
          DropdownMenuItem(value: 32.0, child: Text('32px')),
        ],
        onChanged: (value) {
          if (value != null) store.setGridSpacing(value);
        },
      ),
    );
  }

  Widget _buildSliderRow(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _hexColor("#d8b576").withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}x',
                  style: TextStyle(
                    color: _hexColor("#d8b576"),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _hexColor("#d8b576"),
              inactiveTrackColor: Colors.grey[700],
              thumbColor: _hexColor("#d8b576"),
              overlayColor: _hexColor("#d8b576").withValues(alpha: 0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 10).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBlindnessRow(DevPanelStore store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color Blindness',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Simulate vision deficiencies',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ColorBlindnessMode.values.map((mode) {
                final isSelected = store.colorBlindnessMode == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => store.setColorBlindnessMode(mode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _hexColor("#d8b576").withValues(alpha: 0.2)
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _hexColor("#d8b576")
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getColorBlindnessLabel(mode),
                        style: TextStyle(
                          color:
                              isSelected ? _hexColor("#d8b576") : Colors.white,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(DevPanelStore store) {
    return Center(
      child: TextButton.icon(
        onPressed: store.resetUIDebugSettings,
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Reset All'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[400],
        ),
      ),
    );
  }

  String _getColorBlindnessLabel(ColorBlindnessMode mode) {
    switch (mode) {
      case ColorBlindnessMode.none:
        return 'None';
      case ColorBlindnessMode.protanopia:
        return 'Protanopia';
      case ColorBlindnessMode.deuteranopia:
        return 'Deuteranopia';
      case ColorBlindnessMode.tritanopia:
        return 'Tritanopia';
    }
  }

  Color _hexColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse(hexColor, radix: 16));
  }
}
