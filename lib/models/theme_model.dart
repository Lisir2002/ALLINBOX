import 'dart:convert';

/// 主题包模型
class ThemePackage {
  final String id;
  final String name;
  final String description;
  final String author;
  final String version;
  final String downloadUrl;
  final String previewUrl;
  final ThemeColors colors;
  final bool isInstalled;
  final bool isBuiltIn;

  ThemePackage({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.version,
    required this.downloadUrl,
    required this.previewUrl,
    required this.colors,
    this.isInstalled = false,
    this.isBuiltIn = false,
  });

  factory ThemePackage.fromJson(Map<String, dynamic> json) {
    return ThemePackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      version: json['version'] ?? '1.0.0',
      downloadUrl: json['downloadUrl'] ?? '',
      previewUrl: json['previewUrl'] ?? '',
      colors: ThemeColors.fromJson(json['colors'] ?? {}),
      isInstalled: json['isInstalled'] ?? false,
      isBuiltIn: json['isBuiltIn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'version': version,
      'downloadUrl': downloadUrl,
      'previewUrl': previewUrl,
      'colors': colors.toJson(),
      'isInstalled': isInstalled,
      'isBuiltIn': isBuiltIn,
    };
  }

  ThemePackage copyWith({bool? isInstalled}) {
    return ThemePackage(
      id: id,
      name: name,
      description: description,
      author: author,
      version: version,
      downloadUrl: downloadUrl,
      previewUrl: previewUrl,
      colors: colors,
      isInstalled: isInstalled ?? this.isInstalled,
      isBuiltIn: isBuiltIn,
    );
  }
}

/// 主题颜色配置
class ThemeColors {
  final String primary;
  final String secondary;
  final String background;
  final String surface;
  final String error;
  final String onPrimary;
  final String onSecondary;
  final String onBackground;
  final String onSurface;
  final String onError;

  ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
  });

  factory ThemeColors.fromJson(Map<String, dynamic> json) {
    return ThemeColors(
      primary: json['primary'] ?? '#6C5CE7',
      secondary: json['secondary'] ?? '#00B894',
      background: json['background'] ?? '#FFFFFF',
      surface: json['surface'] ?? '#F5F5F5',
      error: json['error'] ?? '#D63031',
      onPrimary: json['onPrimary'] ?? '#FFFFFF',
      onSecondary: json['onSecondary'] ?? '#FFFFFF',
      onBackground: json['onBackground'] ?? '#000000',
      onSurface: json['onSurface'] ?? '#000000',
      onError: json['onError'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'background': background,
      'surface': surface,
      'error': error,
      'onPrimary': onPrimary,
      'onSecondary': onSecondary,
      'onBackground': onBackground,
      'onSurface': onSurface,
      'onError': onError,
    };
  }

  /// 将十六进制颜色字符串转换为 Color 对象
  static int _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return int.parse(hex, radix: 16);
  }

  /// 获取主色调的 Color 对象
  int get primaryColor => _hexToColor(primary);
  int get secondaryColor => _hexToColor(secondary);
  int get backgroundColor => _hexToColor(background);
  int get surfaceColor => _hexToColor(surface);
  int get errorColor => _hexToColor(error);
}
