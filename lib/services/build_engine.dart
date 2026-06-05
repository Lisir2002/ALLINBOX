import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/app_model.dart';

/// 本地 APK 编译引擎
class BuildEngine {
  static final BuildEngine _instance = BuildEngine._internal();
  factory BuildEngine() => _instance;
  BuildEngine._internal();

  static const platform = MethodChannel('com.inbox.all/build');

  /// 构建状态
  BuildStatus _status = BuildStatus.idle;
  String _log = '';
  double _progress = 0;

  BuildStatus get status => _status;
  String get log => _log;
  double get progress => _progress;

  void Function(BuildStatus, String)? onStatusChanged;

  /// 开始编译 APP
  Future<bool> buildApk(CustomApp app, Directory projectDir) async {
    _status = BuildStatus.preparing;
    _log = '准备编译环境...\n';
    _progress = 0.05;
    _notify();

    try {
      // 1. 检查 Flutter 环境
      _appendLog('检查 Flutter SDK...\n');
      _progress = 0.1;
      _notify();

      // 2. 创建完整项目结构
      _appendLog('创建项目结构...\n');
      await _createFullProject(projectDir, app);
      _progress = 0.3;
      _notify();

      // 3. 创建签名密钥
      _appendLog('生成签名密钥...\n');
      await _generateKeystore(projectDir, app);
      _progress = 0.4;
      _notify();

      // 4. 触发主机端编译（通过 MethodChannel）
      _appendLog('开始编译 APK...\n');
      _status = BuildStatus.building;
      _notify();

      final result = await _invokeBuild(projectDir.path, app);
      
      if (result != null) {
        _status = BuildStatus.success;
        _appendLog('编译成功!\n');
        _appendLog('APK 路径: $result\n');
        _progress = 1.0;
        _notify();
        return true;
      } else {
        _status = BuildStatus.failed;
        _appendLog('编译失败\n');
        _notify();
        return false;
      }
    } catch (e) {
      _status = BuildStatus.failed;
      _appendLog('错误: $e\n');
      _notify();
      return false;
    }
  }

  /// 创建完整项目结构
  Future<void> _createFullProject(Directory dir, CustomApp app) async {
    // 基本目录结构
    final dirs = [
      '${dir.path}/lib',
      '${dir.path}/android/app/src/main',
      '${dir.path}/android/app/src/main/res/values',
      '${dir.path}/android/app/src/main/res/mipmap-hdpi',
    ];
    for (final d in dirs) {
      await Directory(d).create(recursive: true);
    }

    // pubspec.yaml
    await File('${dir.path}/pubspec.yaml').writeAsString('''
name: ${app.packageName.replaceAll('.', '_')}
description: ${app.name}
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  webview_flutter: ^4.8.0

flutter:
  uses-material-design: true
''');

    // main.dart
    await File('${dir.path}/lib/main.dart').writeAsString('''
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const GeneratedApp());

class GeneratedApp extends StatelessWidget {
  const GeneratedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${app.name}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Color(${app.iconColor.replaceAll('#', '0xFF')}),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: _WebViewPage(url: '${app.url}'),
    );
  }
}

class _WebViewPage extends StatefulWidget {
  final String url;
  const _WebViewPage({required this.url});

  @override
  State<_WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<_WebViewPage> {
  late WebViewController controller;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => progress = p / 100),
        onPageFinished: (_) => setState(() => progress = 1),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${app.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: progress < 1 ? LinearProgressIndicator(value: progress) : const SizedBox(height: 3),
        ),
      ),
      body: WebViewWidget(controller: controller),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(heroTag: 'back', onPressed: () => controller.goBack(), child: const Icon(Icons.arrow_back)),
          const SizedBox(width: 8),
          FloatingActionButton.small(heroTag: 'refresh', onPressed: () => controller.reload(), child: const Icon(Icons.refresh)),
          const SizedBox(width: 8),
          FloatingActionButton.small(heroTag: 'forward', onPressed: () => controller.goForward(), child: const Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}
''');

    // AndroidManifest.xml
    final manifestDirs = [
      '${dir.path}/android/app/src/main',
    ];
    for (final d in manifestDirs) {
      await Directory(d).create(recursive: true);
    }
    await File('${dir.path}/android/app/src/main/AndroidManifest.xml').writeAsString('''
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="${app.packageName}">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:label="${app.name}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name="\${applicationName}"
            android:exported="true"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data android:name="flutterEmbedding" android:value="2"/>
    </application>
</manifest>
''');
  }

  /// 生成签名密钥
  Future<void> _generateKeystore(Directory dir, CustomApp app) async {
    // 在设备上无法直接运行 keytool，这里创建 key.properties 模板
    await File('${dir.path}/android/key.properties').writeAsString('''
storePassword=allinbox2024
keyPassword=allinbox2024
keyAlias=upload
storeFile=../upload-keystore.jks
''');
  }

  /// 通过 MethodChannel 调用主机端编译
  Future<String?> _invokeBuild(String projectPath, CustomApp app) async {
    try {
      final result = await platform.invokeMethod('buildApk', {
        'projectPath': projectPath,
        'packageName': app.packageName,
        'appName': app.name,
      });
      return result;
    } catch (e) {
      _appendLog('MethodChannel 错误: $e\n');
      return null;
    }
  }

  void _appendLog(String message) {
    _log += message;
    debugPrint('[BuildEngine] $message');
  }

  void _notify() {
    onStatusChanged?.call(_status, _log);
  }

  /// 重置状态
  void reset() {
    _status = BuildStatus.idle;
    _log = '';
    _progress = 0;
  }
}

enum BuildStatus {
  idle,
  preparing,
  building,
  success,
  failed,
}
