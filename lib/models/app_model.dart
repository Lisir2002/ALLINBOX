/// 自定义 APP 数据模型
class CustomApp {
  final String id;
  final String name;
  final String url;
  final String iconName;
  final String iconColor;
  final String description;
  final String packageName;
  final String? injectCSS;
  final String? injectJS;
  final bool isBuilt;
  final String? apkPath;
  final DateTime createdAt;

  CustomApp({
    required this.id,
    required this.name,
    required this.url,
    required this.iconName,
    required this.iconColor,
    this.description = '',
    required this.packageName,
    this.injectCSS,
    this.injectJS,
    this.isBuilt = false,
    this.apkPath,
    required this.createdAt,
  });

  factory CustomApp.fromJson(Map<String, dynamic> json) {
    return CustomApp(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      iconName: json['iconName'] ?? 'language',
      iconColor: json['iconColor'] ?? '#6C5CE7',
      description: json['description'] ?? '',
      packageName: json['packageName'] ?? 'com.allinbox.app',
      injectCSS: json['injectCSS'],
      injectJS: json['injectJS'],
      isBuilt: json['isBuilt'] ?? false,
      apkPath: json['apkPath'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'iconName': iconName,
      'iconColor': iconColor,
      'description': description,
      'packageName': packageName,
      'injectCSS': injectCSS,
      'injectJS': injectJS,
      'isBuilt': isBuilt,
      'apkPath': apkPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CustomApp copyWith({
    String? name,
    String? url,
    String? iconName,
    String? iconColor,
    String? description,
    bool? isBuilt,
    String? apkPath,
    String? injectCSS,
    String? injectJS,
  }) {
    return CustomApp(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      iconName: iconName ?? this.iconName,
      iconColor: iconColor ?? this.iconColor,
      description: description ?? this.description,
      packageName: packageName,
      injectCSS: injectCSS ?? this.injectCSS,
      injectJS: injectJS ?? this.injectJS,
      isBuilt: isBuilt ?? this.isBuilt,
      apkPath: apkPath ?? this.apkPath,
      createdAt: createdAt,
    );
  }
}
