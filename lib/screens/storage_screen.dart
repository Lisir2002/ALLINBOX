import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/permission_service.dart';
import '../services/theme_service.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final PermissionService _permissionService = PermissionService();
  final ThemeService _themeService = ThemeService();
  bool _isLoading = true;
  bool _hasPermission = false;
  String _totalSize = '0 B';
  List<StorageItem> _storageItems = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  Future<void> _checkPermissionAndLoad() async {
    _hasPermission = await _permissionService.requestStoragePermission(context);
    if (_hasPermission) {
      await _calculateStorage();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateStorage() async {
    setState(() => _isLoading = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      int tempSize = await _getDirectorySize(tempDir);
      int appSize = await _getDirectorySize(appDir);
      int cacheSize = await _getDirectorySize(cacheDir);
      int themeSize = await _getThemeStorageSize();

      setState(() {
        _storageItems = [
          StorageItem(
            name: '临时文件',
            description: '应用运行时产生的临时数据',
            path: tempDir.path,
            size: tempSize,
            icon: Icons.folder_outlined,
            color: Colors.orange,
            type: StorageType.temporary,
          ),
          StorageItem(
            name: '应用数据',
            description: '应用保存的用户数据和配置',
            path: appDir.path,
            size: appSize,
            icon: Icons.storage_outlined,
            color: Colors.blue,
            type: StorageType.appData,
          ),
          StorageItem(
            name: '应用缓存',
            description: '应用缓存的资源文件',
            path: cacheDir.path,
            size: cacheSize,
            icon: Icons.cached_outlined,
            color: Colors.green,
            type: StorageType.cache,
          ),
          StorageItem(
            name: '主题文件',
            description: '已下载的主题包文件',
            path: '${appDir.path}/themes',
            size: themeSize,
            icon: Icons.palette_outlined,
            color: Colors.purple,
            type: StorageType.themes,
          ),
        ];
        _totalSize = _formatSize(tempSize + appSize + cacheSize + themeSize);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _totalSize = '计算失败';
        _isLoading = false;
      });
    }
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              size += await entity.length();
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    return size;
  }

  Future<int> _getThemeStorageSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final themeDir = Directory('${appDir.path}/themes');
      return await _getDirectorySize(themeDir);
    } catch (_) {
      return 0;
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _clearStorage(StorageItem item) async {
    try {
      if (item.type == StorageType.themes) {
        // 清理主题文件
        await _themeService.clearAllDownloadedThemes();
      } else {
        final dir = Directory(item.path);
        if (await dir.exists()) {
          await for (FileSystemEntity entity in dir.list()) {
            try {
              await entity.delete(recursive: true);
            } catch (_) {}
          }
        }
      }
      await _calculateStorage();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name}已清理')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('清理失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('存储管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _hasPermission ? _calculateStorage : _checkPermissionAndLoad,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildNoPermissionView()
              : ListView(
                  children: [
                    _buildOverviewCard(context),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('存储详情', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    ..._storageItems.map((item) => _buildStorageItemCard(context, item)),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FilledButton.icon(
                        onPressed: _showClearAllDialog,
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('清理所有缓存'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _buildNoPermissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text('需要存储权限', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('存储管理功能需要访问设备存储来查看和清理缓存数据。', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _checkPermissionAndLoad,
              icon: const Icon(Icons.settings),
              label: const Text('授予权限'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colorScheme.primaryContainer, colorScheme.primaryContainer.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.storage_rounded, size: 48, color: colorScheme.onPrimaryContainer),
          const SizedBox(height: 16),
          Text('总占用空间', style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.8), fontSize: 14)),
          const SizedBox(height: 8),
          Text(_totalSize, style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${_storageItems.length} 个存储位置', style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(0.6), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStorageItemCard(BuildContext context, StorageItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(_formatSize(item.size), style: TextStyle(color: item.color, fontWeight: FontWeight.bold)),
          ],
        ),
        isThreeLine: true,
        trailing: item.size > 0
            ? TextButton(
                onPressed: () => _showClearDialog(item),
                child: const Text('清理'),
              )
            : null,
      ),
    );
  }

  void _showClearDialog(StorageItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清理${item.name}'),
        content: Text('确定要清理${item.name}吗？\n当前大小: ${_formatSize(item.size)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearStorage(item);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清理'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理所有缓存'),
        content: Text('确定要清理所有缓存吗？\n当前总大小: $_totalSize'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllStorage();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清理'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllStorage() async {
    for (var item in _storageItems) {
      if (item.type != StorageType.themes) {
        // 不清理主题文件，除非用户明确选择
        await _clearStorage(item);
      }
    }
  }
}

enum StorageType {
  temporary,
  appData,
  cache,
  themes,
}

class StorageItem {
  final String name;
  final String description;
  final String path;
  final int size;
  final IconData icon;
  final Color color;
  final StorageType type;

  StorageItem({
    required this.name,
    required this.description,
    required this.path,
    required this.size,
    required this.icon,
    required this.color,
    required this.type,
  });
}
