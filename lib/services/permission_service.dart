import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限管理服务
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  // 权限检查状态缓存
  bool _hasCheckedNetworkPermission = false;
  bool _hasNetworkPermission = false;
  bool _hasCheckedStoragePermission = false;
  bool _hasStoragePermission = false;

  /// 检查网络权限（Android 默认授予）
  bool get hasNetworkPermission => _hasNetworkPermission;

  /// 检查存储权限
  bool get hasStoragePermission => _hasStoragePermission;

  /// 检查网络权限
  Future<bool> checkNetworkPermission() async {
    // Android 上网络权限默认授予，只需要在 AndroidManifest.xml 中声明
    return true;
  }

  /// 检查存储权限
  Future<bool> checkStoragePermission() async {
    // Android 13+ 使用新的权限模型
    if (await Permission.manageExternalStorage.status.isGranted) {
      _hasStoragePermission = true;
      return true;
    }
    if (await Permission.storage.status.isGranted) {
      _hasStoragePermission = true;
      return true;
    }
    _hasStoragePermission = false;
    return false;
  }

  /// 请求存储权限
  Future<bool> requestStoragePermission(BuildContext context) async {
    // 如果已经检查过且有权限，直接返回
    if (_hasCheckedStoragePermission && _hasStoragePermission) {
      return true;
    }

    // 先检查是否已有权限
    if (await checkStoragePermission()) {
      _hasCheckedStoragePermission = true;
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
        _hasCheckedStoragePermission = true;
        return false;
      }
    }

    // 请求权限
    Map<Permission, PermissionStatus> statuses;

    // Android 11+ 需要 MANAGE_EXTERNAL_STORAGE
    statuses = await [Permission.manageExternalStorage].request();
    if (statuses[Permission.manageExternalStorage]!.isGranted) {
      _hasStoragePermission = true;
      _hasCheckedStoragePermission = true;
      return true;
    }

    // 尝试普通存储权限
    statuses = await [Permission.storage].request();
    if (statuses[Permission.storage]!.isGranted) {
      _hasStoragePermission = true;
      _hasCheckedStoragePermission = true;
      return true;
    }

    // 权限被拒绝
    _hasCheckedStoragePermission = true;
    if (context.mounted) {
      _showPermissionDeniedDialog(context);
    }
    return false;
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

  /// 请求网络权限
  Future<bool> requestNetworkPermission(BuildContext context) async {
    // 如果已经检查过且有权限，直接返回
    if (_hasCheckedNetworkPermission && _hasNetworkPermission) {
      return true;
    }

    // Android 上网络权限默认授予
    // 只需要在 AndroidManifest.xml 中声明
    _hasNetworkPermission = true;
    _hasCheckedNetworkPermission = true;
    return true;
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

  /// 重置权限检查状态（用于测试）
  void resetPermissionState() {
    _hasCheckedNetworkPermission = false;
    _hasNetworkPermission = false;
    _hasCheckedStoragePermission = false;
    _hasStoragePermission = false;
  }
}
