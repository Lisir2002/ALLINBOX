import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
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
          _buildThemeTile(context),

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

  Widget _buildThemeTile(BuildContext context) {
    return ListTile(
      leading: _buildIconContainer(_getThemeModeIcon(currentThemeMode), Colors.purple),
      title: const Text('主题模式'),
      subtitle: Text(_getThemeModeName(currentThemeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('选择主题'),
          children: [
            _buildThemeOption(dialogContext, ThemeMode.system, '跟随系统', Icons.brightness_auto),
            _buildThemeOption(dialogContext, ThemeMode.light, '日间模式', Icons.light_mode),
            _buildThemeOption(dialogContext, ThemeMode.dark, '夜间模式', Icons.dark_mode),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext dialogContext, ThemeMode mode, String title, IconData icon) {
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
