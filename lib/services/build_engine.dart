import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_model.dart';

/// 手机端 APK 构建引擎（模板注入法）
class BuildEngine {
  static final BuildEngine _instance = BuildEngine._internal();
  factory BuildEngine() => _instance;
  BuildEngine._internal();

  static const platform = MethodChannel('com.inbox.all/apkbuilder');

  String _log = '';
  double _progress = 0;
  BuildStatus _status = BuildStatus.idle;
  
  BuildStatus get status => _status;
  String get log => _log;
  double get progress => _progress;
  void Function(BuildStatus, String)? onStatusChanged;

  /// 构建 APK
  Future<bool> buildApk(CustomApp app) async {
    _status = BuildStatus.preparing;
    _log = '';
    _progress = 0;
    _notify();

    try {
      // 1. 读取模板 APK
      _appendLog('[1/5] 加载模板...\n');
      _progress = 0.1; _notify();
      final templateBytes = await _loadTemplate();
      
      // 2. 解压模板 APK
      _appendLog('[2/5] 解压模板...\n');
      _progress = 0.3; _notify();
      final archive = ZipDecoder().decodeBytes(templateBytes);
      
      // 3. 注入配置
      _appendLog('[3/5] 注入配置...\n');
      _progress = 0.5; _notify();
      
      // 构建配置 JSON
      final config = {
        'name': app.name,
        'url': app.url,
        'color': app.iconColor,
      };
      final configBytes = utf8.encode(json.encode(config));
      
      // 替换 assets/flutter_assets/assets/config.json
      final configList = configBytes.toList();
      for (int i = 0; i < archive.files.length; i++) {
        final file = archive.files[i];
        if (file.name == 'assets/flutter_assets/assets/config.json') {
          // 替换为新的 ArchiveFile
          archive.files[i] = ArchiveFile.bytes(file.name, configList)
            ..compression = CompressionType.none;
          _appendLog('已替换 config.json\n');
          break;
        }
      }
      
      // 4. 重新打包
      _appendLog('[4/5] 重新打包...\n');
      _progress = 0.7; _notify();
      
      final outputDir = Directory('${(await getApplicationDocumentsDirectory()).path}/build_output/${app.id}');
      if (!await outputDir.exists()) await outputDir.create(recursive: true);
      
      final unsignedPath = '${outputDir.path}/unsigned.apk';
      final output = ZipEncoder().encode(archive);
      if (output == null) throw Exception('Zip编码失败');
      await File(unsignedPath).writeAsBytes(output);
      _appendLog('APK 大小: ${output.length} bytes\n');
      
      // 5. 签名并安装
      _appendLog('[5/5] 签名安装...\n');
      _progress = 0.85; _notify();
      
      final signedPath = '${outputDir.path}/${app.id}.apk';
      
      // 通过 MethodChannel 调用原生签名 + 安装
      final result = await platform.invokeMethod('signAndInstall', {
        'unsignedPath': unsignedPath,
        'outputPath': signedPath,
        'appName': app.name,
      });
      
      if (result == true) {
        _status = BuildStatus.success;
        _appendLog('安装成功!\n');
        _progress = 1.0;
      } else {
        // 签名可能失败，尝试直接安装原始 APK
        _appendLog('尝试直接安装...\n');
        final installResult = await platform.invokeMethod('installApk', {
          'apkPath': unsignedPath,
          'appName': app.name,
        });
        if (installResult == true) {
          _status = BuildStatus.success;
          _progress = 1.0;
        } else {
          throw Exception('安装失败: $installResult');
        }
      }
      _notify();
      return true;
      
    } catch (e) {
      _status = BuildStatus.failed;
      _appendLog('错误: $e\n');
      _notify();
      return false;
    }
  }

  Future<Uint8List> _loadTemplate() async {
    final data = await rootBundle.load('assets/template.apk');
    return data.buffer.asUint8List();
  }

  void _appendLog(String msg) {
    _log += msg;
    debugPrint('[APKBuilder] $msg');
  }

  void _notify() => onStatusChanged?.call(_status, _log);
  void reset() { _status = BuildStatus.idle; _log = ''; _progress = 0; }
}

enum BuildStatus { idle, preparing, building, success, failed }
