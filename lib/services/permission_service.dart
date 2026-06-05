import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// 权限类型
enum PermissionTypeDef {
  network,
  storage,
  camera,
  location,
  microphone,
  notification,
}

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

  bool get hasNetworkPermission => _hasNetworkPermission;
  bool get hasStoragePermission => _hasStoragePermission;

  /// 通用权限检查
  Future<bool> checkPermissionGeneric(PermissionTypeDef type) async {
    final perm = _mapToPermission(type);
    if (perm == null) return true;
    return await perm.status.isGranted;
  }

  Permission? _mapToPermission(PermissionTypeDef type) {
    switch (type) {
      case PermissionTypeDef.camera:
        return Permission.camera;
      case PermissionTypeDef.location:
        return Permission.location;
      case PermissionTypeDef.microphone:
        return Permission.microphone;
      case PermissionTypeDef.notification:
        return Permission.notification;
      default:
        return null;
    }
  }

  /// 通用权限请求
  Future<bool> requestGenericPermission(BuildContext context, PermissionTypeDef type) async {
    final perm = _mapToPermission(type);
    if (perm == null) return true;

    if (await perm.status.isGranted) return true;

    // 显示说明对话框
    final iconData = _getPermissionIcon(type);
    final title = _getPermissionName(type);
    if (context.mounted) {
      final shouldRequest = await _showPermissionRationale(
        context,
        title: '需要$title权限',
        message: _getPermissionDescription(type),
        icon: iconData,
        iconColor: _getPermissionColor(type),
      );
      if (!shouldRequest) return false;
    }

    final result = await perm.request();
    return result.isGranted;
  }

  IconData _getPermissionIcon(PermissionTypeDef type) {
    switch (type) {
      case PermissionTypeDef.camera:
        return Icons.camera_alt;
      case PermissionTypeDef.location:
        return Icons.location_on;
      case PermissionTypeDef.microphone:
        return Icons.mic;
      case PermissionTypeDef.notification:
        return Icons.notifications;
      case PermissionTypeDef.network:
        return Icons.wifi;
      case PermissionTypeDef.storage:
        return Icons.storage;
    }
  }

  Color _getPermissionColor(PermissionTypeDef type) {
    switch (type) {
      case PermissionTypeDef.camera:
        return Colors.pink;
      case PermissionTypeDef.location:
        return Colors.teal;
      case PermissionTypeDef.microphone:
        return Colors.red;
      case PermissionTypeDef.notification:
        return Colors.amber;
      case PermissionTypeDef.network:
        return Colors.blue;
      case PermissionTypeDef.storage:
        return Colors.orange;
    }
  }

  String _getPermissionName(PermissionTypeDef type) {
    switch (type) {
      case PermissionTypeDef.camera:
        return '相机';
      case PermissionTypeDef.location:
        return '位置';
      case PermissionTypeDef.microphone:
        return '麦克风';
      case PermissionTypeDef.notification:
        return '通知';
      case PermissionTypeDef.network:
        return '网络';
      case PermissionTypeDef.storage:
        return '存储';
    }
  }

  String _getPermissionDescription(PermissionTypeDef type) {
    switch (type) {
      case PermissionTypeDef.camera:
        return '用于拍照、扫码等功能';
      case PermissionTypeDef.location:
        return '用于获取设备位置信息';
      case PermissionTypeDef.microphone:
        return '用于录音、语音输入等功能';
      case PermissionTypeDef.notification:
        return '用于发送系统通知提醒';
      default:
        return '';
    }
  }

  /// 检查网络权限
  Future<bool> checkNetworkPermission() async => true;

  /// 检查存储权限
  Future<bool> checkStoragePermission() async {
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
    if (_hasCheckedStoragePermission && _hasStoragePermission) return true;
    if (await checkStoragePermission()) {
      _hasCheckedStoragePermission = true;
      return true;
    }

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

    var statuses = await [Permission.manageExternalStorage].request();
    if (statuses[Permission.manageExternalStorage]!.isGranted) {
      _hasStoragePermission = true;
      _hasCheckedStoragePermission = true;
      return true;
    }

    statuses = await [Permission.storage].request();
    if (statuses[Permission.storage]!.isGranted) {
      _hasStoragePermission = true;
      _hasCheckedStoragePermission = true;
      return true;
    }

    _hasCheckedStoragePermission = true;
    if (context.mounted) _showPermissionDeniedDialog(context);
    return false;
  }

  /// 请求网络权限
  Future<bool> requestNetworkPermission(BuildContext context) async {
    if (_hasCheckedNetworkPermission && _hasNetworkPermission) return true;
    _hasNetworkPermission = true;
    _hasCheckedNetworkPermission = true;
    return true;
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('确定')),
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
        content: const Text('权限被拒绝，无法使用此功能。\n\n您可以在设置中手动开启权限。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () { Navigator.pop(context); openAppSettingsPage(); },
            child: const Text('打开设置'),
          ),
        ],
      ),
    );
  }

  /// 打开应用设置页面
  Future<void> openAppSettingsPage() async => await openAppSettings();

  /// 显示权限被拒绝的提示
  void showPermissionDeniedSnackBar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name 权限被拒绝'),
        action: SnackBarAction(label: '设置', onPressed: () => openAppSettingsPage()),
      ),
    );
  }
}
