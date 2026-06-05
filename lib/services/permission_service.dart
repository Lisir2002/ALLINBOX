import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 权限类型枚举
enum PermissionType {
  network,
  storage,
  camera,
  location,
  microphone,
}

/// 权限状态
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
}

/// 权限管理服务
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // 权限状态缓存
  final Map<PermissionType, PermissionStatus> _permissionCache = {};

  /// 检查网络权限（Android 默认授予，但需要检查网络连接）
  Future<bool> checkNetworkPermission() async {
    try {
      // 尝试进行网络请求来验证网络权限
      final result = await _checkNetworkConnectivity();
      return result;
    } catch (e) {
      debugPrint('检查网络权限失败: $e');
      return false;
    }
  }

  /// 检查网络连接
  Future<bool> _checkNetworkConnectivity() async {
    try {
      // 使用 MethodChannel 检查网络状态
      const platform = MethodChannel('com.inbox.all/network');
      final bool isConnected = await platform.invokeMethod('checkNetwork');
      return isConnected;
    } catch (e) {
      // 如果 MethodChannel 不可用，默认返回 true（假设已连接）
      debugPrint('网络检查 MethodChannel 不可用: $e');
      return true;
    }
  }

  /// 显示网络权限说明对话框
  Future<bool> showNetworkPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.wifi, color: Colors.blue, size: 48),
        title: const Text('需要网络权限'),
        content: const Text(
          '此功能需要访问网络来下载在线主题。\n\n'
          '请确保您的设备已连接到互联网。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示存储权限说明对话框
  Future<bool> showStoragePermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.storage, color: Colors.orange, size: 48),
        title: const Text('需要存储权限'),
        content: const Text(
          '此功能需要访问设备存储来管理缓存数据。\n\n'
          '应用将读取和清理临时文件、缓存等数据。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 显示权限被拒绝的提示
  void showPermissionDeniedSnackBar(BuildContext context, String permissionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permissionName 权限被拒绝'),
        action: SnackBarAction(
          label: '设置',
          onPressed: () {
            _openAppSettings();
          },
        ),
      ),
    );
  }

  /// 打开应用设置页面
  Future<void> _openAppSettings() async {
    try {
      const platform = MethodChannel('com.inbox.all/settings');
      await platform.invokeMethod('openAppSettings');
    } catch (e) {
      debugPrint('打开设置失败: $e');
    }
  }

  /// 显示权限请求对话框（通用）
  Future<bool> showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    String confirmText = '确定',
    String cancelText = '取消',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: iconColor, size: 48),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 检查并请求网络权限
  Future<bool> requestNetworkPermission(BuildContext context) async {
    // 先检查网络连接
    final hasNetwork = await checkNetworkPermission();
    if (hasNetwork) {
      return true;
    }

    // 显示权限说明
    if (context.mounted) {
      final granted = await showNetworkPermissionDialog(context);
      if (granted) {
        // 再次检查
        return await checkNetworkPermission();
      }
    }
    return false;
  }

  /// 检查并请求存储权限
  Future<bool> requestStoragePermission(BuildContext context) async {
    // Android 10+ 不需要存储权限来访问应用私有目录
    // 但需要权限来访问公共存储
    if (context.mounted) {
      final granted = await showStoragePermissionDialog(context);
      return granted;
    }
    return false;
  }

  /// 获取权限状态
  PermissionStatus getPermissionStatus(PermissionType type) {
    return _permissionCache[type] ?? PermissionStatus.denied;
  }

  /// 更新权限状态
  void updatePermissionStatus(PermissionType type, PermissionStatus status) {
    _permissionCache[type] = status;
  }

  /// 清除权限缓存
  void clearCache() {
    _permissionCache.clear();
  }
}
