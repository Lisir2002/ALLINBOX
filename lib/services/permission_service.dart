import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限管理服务
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// 检查网络权限（Android 默认授予）
  Future<bool> checkNetworkPermission() async {
    // Android 上网络权限默认授予，只需要在 AndroidManifest.xml 中声明
    return true;
  }

  /// 检查存储权限
  Future<bool> checkStoragePermission() async {
    // Android 13+ 使用新的权限模型
    if (await Permission.manageExternalStorage.status.isGranted) {
      return true;
    }
    if (await Permission.storage.status.isGranted) {
      return true;
    }
    return false;
  }

  /// 请求存储权限
  Future<bool> requestStoragePermission(BuildContext context) async {
    // 先检查是否已有权限
    if (await checkStoragePermission()) {
      return true;
    }

    // 显示权限说明对话框
    if (context.mounted) {
      final shouldRequest = await _showPermissionRationale(
        context,
        title: '需要存储权限',
        message: '此功能需要访问设备存储来查看和清理缓存数据。',
        icon: Icons.storage,
        iconColor: Colors.orange,
      );

      if (!shouldRequest) {
        return false;
      }
    }

    // 请求权限
    Map<Permission, PermissionStatus> statuses;

    // Android 11+ 需要 MANAGE_EXTERNAL_STORAGE
    if (await _isAndroid11OrAbove()) {
      statuses = await [Permission.manageExternalStorage].request();
      if (statuses[Permission.manageExternalStorage]!.isGranted) {
        return true;
      }
    } else {
      // Android 10 及以下使用普通存储权限
      statuses = await [Permission.storage].request();
      if (statuses[Permission.storage]!.isGranted) {
        return true;
      }
    }

    // 权限被拒绝
    if (context.mounted) {
      _showPermissionDeniedDialog(context);
    }
    return false;
  }

  /// 检查是否是 Android 11+
  Future<bool> _isAndroid11OrAbove() async {
    // permission_handler 没有直接获取 Android 版本的方法
    // 我们尝试请求 manageExternalStorage，如果失败则使用普通权限
    return true; // 默认假设是 Android 11+
  }

  /// 显示权限说明对话框
  Future<bool> _showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
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

  /// 显示权限被拒绝对话框
  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
        title: const Text('权限被拒绝'),
        content: const Text('存储权限被拒绝，无法使用此功能。\n\n您可以在设置中手动开启权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettingsPage();
            },
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
  }

  /// 打开应用设置页面
  Future<void> openAppSettingsPage() async {
    await openAppSettings();
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

  /// 检查并请求网络权限
  Future<bool> requestNetworkPermission(BuildContext context) async {
    // Android 上网络权限默认授予
    // 只需要显示说明对话框
    if (context.mounted) {
      final granted = await showNetworkPermissionDialog(context);
      return granted;
    }
    return false;
  }

  /// 显示权限被拒绝的提示
  void showPermissionDeniedSnackBar(BuildContext context, String permissionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permissionName 权限被拒绝'),
        action: SnackBarAction(
          label: '设置',
          onPressed: () {
            openAppSettingsPage();
          },
        ),
      ),
    );
  }
}
