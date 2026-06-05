import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final Locale currentLocale;
  final Function(Locale) onLocaleChanged;

  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  late Locale _locale;
  String _cacheSize = '计算中...';
  List<CacheItem> _cacheItems = [];

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
    _locale = widget.currentLocale;
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final appDir = await getApplicationDocumentsDirectory();

      int tempSize = await _getDirectorySize(tempDir);
      int appSize = await _getDirectorySize(appDir);

      setState(() {
        _cacheItems = [
          CacheItem(
            name: '临时缓存',
            path: tempDir.path,
            size: tempSize,
            icon: Icons.folder_outlined,
            color: Colors.orange,
          ),
          CacheItem(
            name: '应用数据',
            path: appDir.path,
            size: appSize,
            icon: Icons.storage_outlined,
            color: Colors.blue,
          ),
        ];
        _cacheSize = _formatSize(tempSize + appSize);
      });
    } catch (e) {
      setState(() {
        _cacheSize = '计算失败';
      });
    }
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      if (await dir.exists()) {
        await for (FileSystemEntity entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            size += await entity.length();
          }
        }
      }
    } catch (e) {
      // 忽略权限错误
    }
    return size;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _clearCache(CacheItem item) async {
    try {
      final dir = Directory(item.path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
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
    try {
      for (var item in _cacheItems) {
        final dir = Directory(item.path);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          await dir.create(recursive: true);
        }
      }
      await _calculateCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有缓存已清理')),
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

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? '繁體中文' : '简体中文';
      case 'en':
        return 'English';
      default:
        return '简体中文';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 主题设置
          _buildSectionHeader(context, '外观设置'),
          _buildThemeTile(context),
          _buildLanguageTile(context),

          const Divider(height: 32),

          // 缓存设置
          _buildSectionHeader(context, '存储管理'),
          _buildCacheOverview(context),
          ..._cacheItems.map((item) => _buildCacheItemTile(context, item)),
          _buildClearAllButton(context),

          const Divider(height: 32),

          // 关于
          _buildSectionHeader(context, '关于'),
          _buildAboutTile(context),
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

  Widget _buildThemeTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.palette_outlined, color: Colors.purple),
      ),
      title: const Text('主题模式'),
      subtitle: Text(_getThemeModeName(_themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.language_outlined, color: Colors.blue),
      ),
      title: const Text('语言'),
      subtitle: Text(_getLanguageName(_locale)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context),
    );
  }

  Widget _buildCacheOverview(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storage_outlined, color: Colors.orange, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '总缓存大小',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _cacheSize,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheItemTile(BuildContext context, CacheItem item) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(item.icon, color: item.color),
      ),
      title: Text(item.name),
      subtitle: Text(
        _formatSize(item.size),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: TextButton(
        onPressed: () => _showClearCacheDialog(context, item),
        child: const Text('清理'),
      ),
    );
  }

  Widget _buildClearAllButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () => _showClearAllCacheDialog(context),
        icon: const Icon(Icons.delete_sweep_outlined),
        label: const Text('清理所有缓存'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.info_outline, color: Colors.green),
      ),
      title: const Text('关于 ALL IN BOX'),
      subtitle: const Text('版本 1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAboutDialog(context),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(context, ThemeMode.system, '跟随系统', Icons.brightness_auto),
              _buildThemeOption(context, ThemeMode.light, '日间模式', Icons.light_mode),
              _buildThemeOption(context, ThemeMode.dark, '夜间模式', Icons.dark_mode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, String title, IconData icon) {
    return RadioListTile<ThemeMode>(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      value: mode,
      groupValue: _themeMode,
      onChanged: (value) {
        if (value != null) {
          setState(() => _themeMode = value);
          widget.onThemeChanged(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择语言'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, const Locale('zh', 'CN'), '简体中文'),
              _buildLanguageOption(context, const Locale('zh', 'TW'), '繁體中文'),
              _buildLanguageOption(context, const Locale('en'), 'English'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, Locale locale, String title) {
    return RadioListTile<Locale>(
      title: Text(title),
      value: locale,
      groupValue: _locale,
      onChanged: (value) {
        if (value != null) {
          setState(() => _locale = value);
          widget.onLocaleChanged(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showClearCacheDialog(BuildContext context, CacheItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
        );
      },
    );
  }

  void _showClearAllCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清理所有缓存'),
          content: Text('确定要清理所有缓存吗？\n当前总大小: $_cacheSize'),
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
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('关于 ALL IN BOX'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.all_inclusive,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'ALL IN BOX',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Center(child: Text('v1.0.0')),
              const SizedBox(height: 16),
              const Text('综合工具箱应用'),
              const SizedBox(height: 8),
              Text(
                '包名: com.inbox.all',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

class CacheItem {
  final String name;
  final String path;
  final int size;
  final IconData icon;
  final Color color;

  CacheItem({
    required this.name,
    required this.path,
    required this.size,
    required this.icon,
    required this.color,
  });
}
