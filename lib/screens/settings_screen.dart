import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../services/theme_service.dart';
import 'theme_store/theme_store_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final ThemePackage currentTheme;
  final Function(ThemePackage) onThemeSelected;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return '跟随系统';
      case ThemeMode.light:
        return '日间模式';
      case ThemeMode.dark:
        return '夜间模式';
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionHeader(context, '外观设置'),
          _buildThemeModeTile(context),
          _buildThemeStoreTile(context),

          const Divider(indent: 16, endIndent: 16),

          // 存储管理
          _buildSectionHeader(context, '存储管理'),
          ListTile(
            leading: _buildIconContainer(Icons.storage_outlined, Colors.orange),
            title: const Text('存储管理'),
            subtitle: const Text('查看和清理应用缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(indent: 16, endIndent: 16),

          // 关于
          _buildSectionHeader(context, '关于'),
          ListTile(
            leading: _buildIconContainer(Icons.info_outline, Colors.green),
            title: const Text('关于 ALL IN BOX'),
            subtitle: const Text('版本 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildThemeModeTile(BuildContext context) {
    return ListTile(
      leading: _buildIconContainer(_getThemeModeIcon(currentThemeMode), Colors.purple),
      title: const Text('主题模式'),
      subtitle: Text(_getThemeModeName(currentThemeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeModeDialog(context),
    );
  }

  Widget _buildThemeStoreTile(BuildContext context) {
    return ListTile(
      leading: _buildIconContainer(Icons.palette_outlined, Colors.indigo),
      title: const Text('主题商店'),
      subtitle: Text('当前: ${currentTheme.name}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThemeStoreScreen(
              onThemeSelected: onThemeSelected,
              currentThemeId: currentTheme.id,
            ),
          ),
        );
      },
    );
  }

  void _showThemeModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('选择主题模式'),
          children: [
            _buildThemeModeOption(dialogContext, ThemeMode.system, '跟随系统', Icons.brightness_auto),
            _buildThemeModeOption(dialogContext, ThemeMode.light, '日间模式', Icons.light_mode),
            _buildThemeModeOption(dialogContext, ThemeMode.dark, '夜间模式', Icons.dark_mode),
          ],
        );
      },
    );
  }

  Widget _buildThemeModeOption(BuildContext dialogContext, ThemeMode mode, String title, IconData icon) {
    return SimpleDialogOption(
      onPressed: () {
        onThemeChanged(mode);
        Navigator.pop(dialogContext);
      },
      child: Row(
        children: [
          Icon(icon, color: currentThemeMode == mode ? Colors.purple : null),
          const SizedBox(width: 12),
          Text(title),
          if (currentThemeMode == mode) ...[
            const Spacer(),
            const Icon(Icons.check, color: Colors.purple),
          ],
        ],
      ),
    );
  }
}
