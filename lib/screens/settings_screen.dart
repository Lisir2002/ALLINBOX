import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import 'theme_store/theme_store_screen.dart';
import 'storage_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemePackage currentTheme;
  final Function(ThemePackage) onThemeSelected;

  const SettingsScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

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
          _buildThemeStoreTile(context),

          const Divider(indent: 16, endIndent: 16),

          // 存储管理
          _buildSectionHeader(context, '存储管理'),
          ListTile(
            leading: _buildIconContainer(Icons.storage_outlined, Colors.orange),
            title: const Text('存储管理'),
            subtitle: const Text('查看和清理应用缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StorageScreen()),
              );
            },
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

  Widget _buildThemeStoreTile(BuildContext context) {
    return ListTile(
      leading: _buildIconContainer(Icons.palette_outlined, Colors.purple),
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
}
