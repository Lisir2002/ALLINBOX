import 'package:flutter/material.dart';
import '../../models/app_model.dart';
import '../../services/app_service.dart';
import 'app_builder_screen.dart';

/// APP 管理页面
class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});

  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
  final AppService _appService = AppService();
  List<CustomApp> _apps = [];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  void _loadApps() {
    setState(() {
      _apps = _appService.allApps;
    });
  }

  Future<void> _deleteApp(CustomApp app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除应用'),
        content: Text('确定要删除 "${app.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('删除')),
        ],
      ),
    );
    if (confirmed == true) {
      await _appService.deleteApp(app.id);
      _loadApps();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${app.name} 已删除')));
      }
    }
  }

  Future<void> _navigateToBuilder({CustomApp? app}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppBuilderScreen(existingApp: app)),
    );
    if (result == true) {
      _loadApps();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('APP 生成器'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToBuilder(),
        icon: const Icon(Icons.add),
        label: const Text('创建 APP'),
      ),
      body: _apps.isEmpty
          ? _buildEmptyView()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _apps.length,
              itemBuilder: (context, index) => _buildAppCard(_apps[index]),
            ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apps_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text('还没有创建任何应用', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('点击下方按钮创建你的第一个 APP', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _navigateToBuilder(),
            icon: const Icon(Icons.add),
            label: const Text('创建 APP'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppCard(CustomApp app) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = Color(int.parse(app.iconColor.replaceAll('#', '0xFF')));
    final iconData = _getIconFromName(app.iconName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: primaryColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(app.url, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(_formatDate(app.createdAt), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      if (app.isBuilt) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(4)),
                          child: Text('已编译', style: TextStyle(fontSize: 10, color: Colors.green.shade900)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _navigateToBuilder(app: app);
                    break;
                  case 'build':
                    // TODO: 触发编译
                    break;
                  case 'delete':
                    _deleteApp(app);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('编辑')])),
                const PopupMenuItem(value: 'build', child: Row(children: [Icon(Icons.build, size: 20), SizedBox(width: 8), Text('编译 APK')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('删除', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  IconData _getIconFromName(String name) {
    switch (name) {
      case 'language': return Icons.language;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'article': return Icons.article;
      case 'chat': return Icons.chat;
      case 'video_library': return Icons.video_library;
      case 'music_note': return Icons.music_note;
      case 'camera_alt': return Icons.camera_alt;
      case 'map': return Icons.map;
      case 'sports_esports': return Icons.sports_esports;
      case 'school': return Icons.school;
      case 'favorite': return Icons.favorite;
      case 'work': return Icons.work;
      case 'flight': return Icons.flight;
      case 'restaurant': return Icons.restaurant;
      case 'local_shipping': return Icons.local_shipping;
      case 'code': return Icons.code;
      case 'cloud': return Icons.cloud;
      case 'dashboard': return Icons.dashboard;
      case 'settings': return Icons.settings;
      case 'home': return Icons.home;
      case 'star': return Icons.star;
      case 'whatshot': return Icons.whatshot;
      case 'new_releases': return Icons.new_releases;
      case 'trending_up': return Icons.trending_up;
      default: return Icons.language;
    }
  }
}
