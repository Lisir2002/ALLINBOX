import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/permission_service.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final PermissionService _permissionService = PermissionService();
  bool _isLoading = true;
  bool _hasPermission = false;
  String _totalSize = '0 B';
  List<CacheItem> _cacheItems = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoad();
  }

  Future<void> _checkPermissionAndLoad() async {
    // 检查存储权限
    _hasPermission = await _permissionService.requestStoragePermission(context);
    
    if (_hasPermission) {
      await _calculateCacheSize();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calculateCacheSize() async {
    setState(() => _isLoading = true);

    try {
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationDocumentsDirectory();

      int tempSize = await _getDirectorySize(tempDir);
      int appSize = await _getDirectorySize(appDir);

      setState(() {
        _cacheItems = [
          CacheItem(
            name: '临时文件',
            description: '应用运行时产生的临时数据',
            path: tempDir.path,
            size: tempSize,
            icon: Icons.folder_outlined,
            color: Colors.orange,
          ),
          CacheItem(
            name: '应用数据',
            description: '应用保存的用户数据和配置',
            path: appDir.path,
            size: appSize,
            icon: Icons.storage_outlined,
            color: Colors.blue,
          ),
        ];
        _totalSize = _formatSize(tempSize + appSize);
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

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _clearCache(CacheItem item) async {
    try {
      final dir = Directory(item.path);
      if (await dir.exists()) {
        await for (FileSystemEntity entity in dir.list()) {
          try {
            await entity.delete(recursive: true);
          } catch (_) {}
        }
      }
      await _calculateCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name}已清理')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清理失败: $e')),
        );
      }
    }
  }

  Future<void> _clearAllCache() async {
    for (var item in _cacheItems) {
      await _clearCache(item);
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
            onPressed: _hasPermission ? _calculateCacheSize : _checkPermissionAndLoad,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _buildNoPermissionView()
              : ListView(
                  children: [
                    // 总览卡片
                    _buildOverviewCard(context),

                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '存储详情',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 缓存项列表
                    ..._cacheItems.map((item) => _buildCacheItemCard(context, item)),

                    const SizedBox(height: 24),

                    // 清理按钮
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FilledButton.icon(
                        onPressed: () => _showClearAllDialog(),
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
            Icon(
              Icons.folder_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '需要存储权限',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '存储管理功能需要访问设备存储来查看和清理缓存数据。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
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
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.storage_rounded,
            size: 48,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 16),
          Text(
            '总占用空间',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _totalSize,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_cacheItems.length} 个存储位置',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheItemCard(BuildContext context, CacheItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: item.color),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              _formatSize(item.size),
              style: TextStyle(
                color: item.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') {
              _showClearDialog(item);
            } else if (value == 'path') {
              _showPathDialog(item);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  SizedBox(width: 8),
                  Text('清理'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'path',
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('查看路径'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDialog(CacheItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('清理${item.name}'),
        content: Text('确定要清理${item.name}吗？\n当前大小: ${_formatSize(item.size)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache(item);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllCache();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清理'),
          ),
        ],
      ),
    );
  }

  void _showPathDialog(CacheItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('存储路径:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.path,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class CacheItem {
  final String name;
  final String description;
  final String path;
  final int size;
  final IconData icon;
  final Color color;

  CacheItem({
    required this.name,
    required this.description,
    required this.path,
    required this.size,
    required this.icon,
    required this.color,
  });
}
