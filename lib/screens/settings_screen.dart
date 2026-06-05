import 'package:flutter/material.dart';
import 'storage_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
    _locale = widget.currentLocale;
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
    final colorScheme = Theme.of(context).colorScheme;

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
          _buildLanguageTile(context),

          const SizedBox(height: 8),
          const Divider(indent: 16, endIndent: 16),
          const SizedBox(height: 8),

          // 存储管理
          _buildSectionHeader(context, '存储管理'),
          _buildStorageTile(context),

          const SizedBox(height: 8),
          const Divider(indent: 16, endIndent: 16),
          const SizedBox(height: 8),

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
        child: Icon(
          _getThemeModeIcon(_themeMode),
          color: Colors.purple,
        ),
      ),
      title: const Text('主题模式'),
      subtitle: Text(_getThemeModeName(_themeMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(),
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
      onTap: () => _showLanguageDialog(),
    );
  }

  Widget _buildStorageTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.storage_outlined, color: Colors.orange),
      ),
      title: const Text('存储管理'),
      subtitle: const Text('查看和清理应用缓存'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StorageScreen(),
          ),
        );
      },
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
      onTap: () => _showAboutDialog(),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(ThemeMode.system, '跟随系统', Icons.brightness_auto),
              _buildThemeOption(ThemeMode.light, '日间模式', Icons.light_mode),
              _buildThemeOption(ThemeMode.dark, '夜间模式', Icons.dark_mode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String title, IconData icon) {
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择语言'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(const Locale('zh', 'CN'), '简体中文'),
              _buildLanguageOption(const Locale('zh', 'TW'), '繁體中文'),
              _buildLanguageOption(const Locale('en'), 'English'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(Locale locale, String title) {
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('关于 ALL IN BOX'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
              const SizedBox(height: 16),
              const Text(
                'ALL IN BOX',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text('v1.0.0'),
              const SizedBox(height: 16),
              const Text(
                '综合工具箱应用',
                textAlign: TextAlign.center,
              ),
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
