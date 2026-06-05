import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PermissionService _permissionService = PermissionService();
  List<PermissionItem> _permissions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    setState(() => _isLoading = true);
    
    _permissions = [
      PermissionItem(
        name: '网络',
        description: '访问互联网，下载在线主题',
        icon: Icons.wifi,
        color: Colors.blue,
        permission: PermissionTypeDef.network,
        isRequired: true,
        isGranted: true, // Android 默认授予
      ),
      PermissionItem(
        name: '存储',
        description: '读写设备存储，管理缓存和主题文件',
        icon: Icons.storage,
        color: Colors.orange,
        permission: PermissionTypeDef.storage,
        isRequired: true,
      ),
      PermissionItem(
        name: '相机',
        description: '拍照、扫码等功能',
        icon: Icons.camera_alt,
        color: Colors.pink,
        permission: PermissionTypeDef.camera,
        isRequired: false,
      ),
      PermissionItem(
        name: '位置',
        description: '获取设备位置信息',
        icon: Icons.location_on,
        color: Colors.teal,
        permission: PermissionTypeDef.location,
        isRequired: false,
      ),
      PermissionItem(
        name: '麦克风',
        description: '录音、语音输入等功能',
        icon: Icons.mic,
        color: Colors.red,
        permission: PermissionTypeDef.microphone,
        isRequired: false,
      ),
      PermissionItem(
        name: '通知',
        description: '发送系统通知提醒',
        icon: Icons.notifications,
        color: Colors.amber,
        permission: PermissionTypeDef.notification,
        isRequired: false,
      ),
    ];

    // 检查各权限状态
    for (int i = 0; i < _permissions.length; i++) {
      final perm = _permissions[i];
      _permissions[i] = perm.copyWith(
        isGranted: await _checkPermission(perm.permission),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<bool> _checkPermission(PermissionTypeDef type) async {
    switch (type) {
      case PermissionTypeDef.network:
        return _permissionService.hasNetworkPermission;
      case PermissionTypeDef.storage:
        return await _permissionService.checkStoragePermission();
      case PermissionTypeDef.camera:
        return await _permissionService.checkPermissionGeneric(PermissionTypeDef.camera);
      case PermissionTypeDef.location:
        return await _permissionService.checkPermissionGeneric(PermissionTypeDef.location);
      case PermissionTypeDef.microphone:
        return await _permissionService.checkPermissionGeneric(PermissionTypeDef.microphone);
      case PermissionTypeDef.notification:
        return await _permissionService.checkPermissionGeneric(PermissionTypeDef.notification);
    }
  }

  Future<bool> _requestPermission(PermissionItem item) async {
    switch (item.permission) {
      case PermissionTypeDef.network:
        return await _permissionService.requestNetworkPermission(context);
      case PermissionTypeDef.storage:
        return await _permissionService.requestStoragePermission(context);
      case PermissionTypeDef.camera:
        return await _permissionService.requestGenericPermission(context, PermissionTypeDef.camera);
      case PermissionTypeDef.location:
        return await _permissionService.requestGenericPermission(context, PermissionTypeDef.location);
      case PermissionTypeDef.microphone:
        return await _permissionService.requestGenericPermission(context, PermissionTypeDef.microphone);
      case PermissionTypeDef.notification:
        return await _permissionService.requestGenericPermission(context, PermissionTypeDef.notification);
    }
  }

  Future<void> _handlePermissionTap(PermissionItem item) async {
    if (item.isGranted) {
      // 已授权，显示信息
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(item.name),
          content: Text('${item.description}\n\n状态: 已授权'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _permissionService.openAppSettingsPage();
              },
              child: const Text('系统设置'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    } else {
      // 申请权限
      final granted = await _requestPermission(item);
      if (granted) {
        await _loadPermissions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item.name}权限已获取')),
          );
        }
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(Icons.warning, color: Colors.orange, size: 48),
              title: const Text('权限被拒绝'),
              content: Text('${item.name}权限被拒绝，您可以在系统设置中手动开启。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _permissionService.openAppSettingsPage();
                  },
                  child: const Text('打开设置'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('权限管理'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPermissions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 头部说明
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: colorScheme.primary, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('权限管理', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '管理应用所需的各项系统权限',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 统计信息
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard(context, '已授权', '${_permissions.where((p) => p.isGranted).length}', Colors.green),
                      const SizedBox(width: 12),
                      _buildStatCard(context, '未授权', '${_permissions.where((p) => !p.isGranted).length}', Colors.orange),
                      const SizedBox(width: 12),
                      _buildStatCard(context, '总计', '${_permissions.length}', Colors.blue),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 必需权限
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('必需权限', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ..._permissions
                    .where((p) => p.isRequired)
                    .map((p) => _buildPermissionTile(context, p)),

                const SizedBox(height: 16),

                // 可选权限
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('可选权限', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                ..._permissions
                    .where((p) => !p.isRequired)
                    .map((p) => _buildPermissionTile(context, p)),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile(BuildContext context, PermissionItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item.icon, color: item.color),
        ),
        title: Row(
          children: [
            Text(item.name),
            if (item.isRequired) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('必需', style: TextStyle(fontSize: 10, color: Colors.red.shade900)),
              ),
            ],
          ],
        ),
        subtitle: Text(item.description, style: Theme.of(context).textTheme.bodySmall),
        trailing: item.isGranted
            ? Icon(Icons.check_circle, color: Colors.green, size: 28)
            : FilledButton.tonal(
                onPressed: () => _handlePermissionTap(item),
                child: const Text('授权'),
              ),
        onTap: () => _handlePermissionTap(item),
      ),
    );
  }
}

class PermissionItem {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final PermissionTypeDef permission;
  final bool isRequired;
  final bool isGranted;

  PermissionItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.permission,
    required this.isRequired,
    this.isGranted = false,
  });

  PermissionItem copyWith({bool? isGranted}) {
    return PermissionItem(
      name: name,
      description: description,
      icon: icon,
      color: color,
      permission: permission,
      isRequired: isRequired,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}
