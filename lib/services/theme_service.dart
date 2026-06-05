import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/theme_model.dart';

/// 主题管理服务
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // 内置主题列表
  static final List<ThemePackage> _builtInThemes = [
    ThemePackage(
      id: 'default',
      name: '默认主题',
      description: 'ALL IN BOX 默认主题',
      author: '系统',
      version: '1.0.0',
      downloadUrl: '',
      previewUrl: '',
      colors: ThemeColors(
        primary: '#6C5CE7',
        secondary: '#00B894',
        background: '#FFFFFF',
        surface: '#F5F5F5',
        error: '#D63031',
        onPrimary: '#FFFFFF',
        onSecondary: '#FFFFFF',
        onBackground: '#000000',
        onSurface: '#000000',
        onError: '#FFFFFF',
      ),
      isInstalled: true,
      isBuiltIn: true,
    ),
    ThemePackage(
      id: 'ocean',
      name: '海洋主题',
      description: '清新蓝色海洋风格主题',
      author: '系统',
      version: '1.0.0',
      downloadUrl: '',
      previewUrl: '',
      colors: ThemeColors(
        primary: '#0984E3',
        secondary: '#00CEC9',
        background: '#FFFFFF',
        surface: '#F0F8FF',
        error: '#E17055',
        onPrimary: '#FFFFFF',
        onSecondary: '#FFFFFF',
        onBackground: '#2D3436',
        onSurface: '#2D3436',
        onError: '#FFFFFF',
      ),
      isInstalled: true,
      isBuiltIn: true,
    ),
    ThemePackage(
      id: 'forest',
      name: '森林主题',
      description: '自然绿色森林风格主题',
      author: '系统',
      version: '1.0.0',
      downloadUrl: '',
      previewUrl: '',
      colors: ThemeColors(
        primary: '#00B894',
        secondary: '#55EFC4',
        background: '#FFFFFF',
        surface: '#F0FFF0',
        error: '#D63031',
        onPrimary: '#FFFFFF',
        onSecondary: '#2D3436',
        onBackground: '#2D3436',
        onSurface: '#2D3436',
        onError: '#FFFFFF',
      ),
      isInstalled: true,
      isBuiltIn: true,
    ),
  ];

  // 在线主题仓库地址（使用 refs/heads/main 格式）
  static const String _baseUrl = 'https://raw.githubusercontent.com/Lisir2002/ALLINBOX/refs/heads/main/themes';
  
  // 多个 CDN 代理选项（按优先级排序）
  static const List<String> _proxyUrls = [
    'https://ghproxy.com/',
    'https://ghproxy.net/',
    'https://mirror.ghproxy.com/',
    'https://gh-proxy.com/',
    '',  // 直连（无代理）
  ];

  List<ThemePackage> _installedThemes = [];
  String _currentThemeId = 'default';

  /// 获取所有可用主题
  List<ThemePackage> getAllThemes() {
    return [..._builtInThemes, ..._installedThemes];
  }

  /// 获取内置主题
  List<ThemePackage> getBuiltInThemes() {
    return _builtInThemes;
  }

  /// 获取已安装的外部主题
  List<ThemePackage> getInstalledThemes() {
    return _installedThemes;
  }

  /// 获取当前主题 ID
  String get currentThemeId => _currentThemeId;

  /// 设置当前主题
  void setCurrentTheme(String themeId) {
    _currentThemeId = themeId;
    _saveThemePreference(themeId);
  }

  /// 获取当前主题配置
  ThemePackage? getCurrentTheme() {
    final themes = getAllThemes();
    try {
      return themes.firstWhere((t) => t.id == _currentThemeId);
    } catch (e) {
      return _builtInThemes.first;
    }
  }

  /// 根据主题包生成 ThemeData
  ThemeData getThemeData(ThemePackage themePackage, {bool isDark = false}) {
    final colors = themePackage.colors;
    
    if (isDark) {
      return ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Color(colors.primaryColor),
          secondary: Color(colors.secondaryColor),
          surface: const Color(0xFF1E1E1E),
          error: Color(colors.errorColor),
          onPrimary: Color(int.parse(colors.onPrimary.replaceAll('#', '0xFF'))),
          onSecondary: Color(int.parse(colors.onSecondary.replaceAll('#', '0xFF'))),
          onSurface: Colors.white,
          onError: Color(int.parse(colors.onError.replaceAll('#', '0xFF'))),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(colors.primaryColor),
        secondary: Color(colors.secondaryColor),
        surface: Color(colors.surfaceColor),
        error: Color(colors.errorColor),
        onPrimary: Color(int.parse(colors.onPrimary.replaceAll('#', '0xFF'))),
        onSecondary: Color(int.parse(colors.onSecondary.replaceAll('#', '0xFF'))),
        onBackground: Color(int.parse(colors.onBackground.replaceAll('#', '0xFF'))),
        onSurface: Color(int.parse(colors.onSurface.replaceAll('#', '0xFF'))),
        onError: Color(int.parse(colors.onError.replaceAll('#', '0xFF'))),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  /// 尝试使用多个代理获取资源
  Future<http.Response?> _fetchWithProxies(String url) async {
    for (final proxy in _proxyUrls) {
      try {
        final proxiedUrl = proxy.isEmpty ? url : '$proxy$url';
        debugPrint('尝试获取: $proxiedUrl');
        final response = await http.get(Uri.parse(proxiedUrl)).timeout(
          const Duration(seconds: 8),
        );
        if (response.statusCode == 200) {
          debugPrint('成功: $proxiedUrl');
          return response;
        }
      } catch (e) {
        debugPrint('失败: $e');
        continue;
      }
    }
    return null;
  }

  /// 获取可用的代理 URL 前缀
  String _getWorkingProxyPrefix() {
    // 默认返回第一个代理
    return _proxyUrls.first;
  }

  /// 从在线仓库获取可用主题列表
  Future<List<ThemePackage>> fetchAvailableThemes() async {
    try {
      final response = await _fetchWithProxies('$_baseUrl/themes.json');
      if (response != null) {
        final List<dynamic> data = json.decode(response.body);
        final proxyPrefix = _getWorkingProxyPrefix();
        // 更新下载链接为代理链接
        return data.map((json) {
          final theme = ThemePackage.fromJson(json);
          if (proxyPrefix.isNotEmpty && theme.downloadUrl.isNotEmpty) {
            return theme.copyWith(
              downloadUrl: '$proxyPrefix${theme.downloadUrl}',
            );
          }
          return theme;
        }).toList();
      }
    } catch (e) {
      debugPrint('获取在线主题失败: $e');
    }
    return [];
  }

  /// 下载并安装主题
  Future<bool> installTheme(ThemePackage theme) async {
    try {
      debugPrint('下载主题: ${theme.name} (${theme.downloadUrl})');
      
      // 使用多代理下载
      final response = await _fetchWithProxies(theme.downloadUrl);
      
      if (response != null) {
        final themeData = json.decode(response.body);
        final installedTheme = ThemePackage.fromJson(themeData);
        
        // 保存到本地
        await _saveThemeToLocal(installedTheme);
        
        // 添加到已安装列表
        _installedThemes.add(installedTheme.copyWith(isInstalled: true));
        
        debugPrint('主题安装成功: ${theme.name}');
        return true;
      } else {
        debugPrint('所有下载方式都失败');
      }
    } catch (e) {
      debugPrint('安装主题失败: $e');
    }
    return false;
  }

  /// 卸载主题
  Future<bool> uninstallTheme(String themeId) async {
    try {
      final dir = await _getThemeDirectory();
      final file = File('${dir.path}/$themeId.json');
      if (await file.exists()) {
        await file.delete();
      }
      _installedThemes.removeWhere((t) => t.id == themeId);
      
      // 如果卸载的是当前主题，切换到默认主题
      if (_currentThemeId == themeId) {
        setCurrentTheme('default');
      }
      
      return true;
    } catch (e) {
      debugPrint('卸载主题失败: $e');
    }
    return false;
  }

  /// 初始化服务，加载已安装的主题
  Future<void> init() async {
    await _loadInstalledThemes();
    await _loadThemePreference();
  }

  /// 加载已安装的主题
  Future<void> _loadInstalledThemes() async {
    try {
      final dir = await _getThemeDirectory();
      if (await dir.exists()) {
        final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));
        _installedThemes = [];
        for (final file in files) {
          try {
            final content = await file.readAsString();
            final theme = ThemePackage.fromJson(json.decode(content));
            _installedThemes.add(theme.copyWith(isInstalled: true));
          } catch (e) {
            debugPrint('加载主题文件失败: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('加载已安装主题失败: $e');
    }
  }

  /// 保存主题到本地
  Future<void> _saveThemeToLocal(ThemePackage theme) async {
    try {
      final dir = await _getThemeDirectory();
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}/${theme.id}.json');
      await file.writeAsString(json.encode(theme.toJson()));
    } catch (e) {
      debugPrint('保存主题失败: $e');
    }
  }

  /// 获取主题存储目录
  Future<Directory> _getThemeDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory('${appDir.path}/themes');
  }

  /// 保存主题偏好
  Future<void> _saveThemePreference(String themeId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/theme_preference.txt');
      await file.writeAsString(themeId);
    } catch (e) {
      debugPrint('保存主题偏好失败: $e');
    }
  }

  /// 加载主题偏好
  Future<void> _loadThemePreference() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/theme_preference.txt');
      if (await file.exists()) {
        _currentThemeId = await file.readAsString();
      }
    } catch (e) {
      debugPrint('加载主题偏好失败: $e');
    }
  }

  /// 创建自定义主题
  ThemePackage createCustomTheme({
    required String name,
    required String primaryColor,
    required String secondaryColor,
  }) {
    return ThemePackage(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: '自定义主题',
      author: '用户',
      version: '1.0.0',
      downloadUrl: '',
      previewUrl: '',
      colors: ThemeColors(
        primary: primaryColor,
        secondary: secondaryColor,
        background: '#FFFFFF',
        surface: '#F5F5F5',
        error: '#D63031',
        onPrimary: '#FFFFFF',
        onSecondary: '#FFFFFF',
        onBackground: '#000000',
        onSurface: '#000000',
        onError: '#FFFFFF',
      ),
      isInstalled: true,
      isBuiltIn: false,
    );
  }
}
