import 'package:flutter/material.dart';
import '../../models/theme_model.dart';
import '../../services/theme_service.dart';
import '../../services/permission_service.dart';

class ThemeStoreScreen extends StatefulWidget {
  final Function(ThemePackage) onThemeSelected;
  final String currentThemeId;

  const ThemeStoreScreen({
    super.key,
    required this.onThemeSelected,
    required this.currentThemeId,
  });

  @override
  State<ThemeStoreScreen> createState() => _ThemeStoreScreenState();
}

class _ThemeStoreScreenState extends State<ThemeStoreScreen> {
  final ThemeService _themeService = ThemeService();
  final PermissionService _permissionService = PermissionService();
  List<ThemePackage> _allThemes = []; // 所有主题（内置+已安装+在线）
  List<ThemePackage> _onlineThemes = []; // 在线主题列表
  bool _isLoading = true;
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _loadThemesWithPermissionCheck();
  }

  Future<void> _loadThemesWithPermissionCheck() async {
    final hasPermission = await _permissionService.requestNetworkPermission(context);
    if (hasPermission) {
      await _loadThemes();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoading = true);
    
    // 获取所有主题（内置+已安装的外部主题）
    final installedThemes = _themeService.getAllThemes();
    final installedIds = installedThemes.map((t) => t.id).toSet();
    
    // 获取在线主题
    try {
      _onlineThemes = await _themeService.fetchAvailableThemes();
    } catch (e) {
      debugPrint('获取在线主题失败: $e');
    }
    
    // 构建完整主题列表
    _allThemes = [];
    
    // 添加内置和已安装的主题
    for (var theme in installedThemes) {
      _allThemes.add(theme);
    }
    
    // 添加在线主题（标记是否已安装）
    for (var onlineTheme in _onlineThemes) {
      if (installedIds.contains(onlineTheme.id)) {
        // 已安装的主题，更新状态
        final index = _allThemes.indexWhere((t) => t.id == onlineTheme.id);
        if (index != -1) {
          _allThemes[index] = _allThemes[index].copyWith(isInstalled: true);
        }
      } else {
        // 未安装的在线主题
        _allThemes.add(onlineTheme);
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题商店'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadThemes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategoryTabs(),
                Expanded(child: _buildThemeList()),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['全部', '内置', '商店', '已下载'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        },
      ),
    );
  }

  List<ThemePackage> _getFilteredThemes() {
    switch (_selectedCategory) {
      case '内置':
        return _allThemes.where((t) => t.isBuiltIn).toList();
      case '商店':
        return _allThemes.where((t) => !t.isBuiltIn).toList(); // 显示所有商店主题
      case '已下载':
        return _allThemes.where((t) => t.isInstalled && !t.isBuiltIn).toList();
      default: // 全部 - 只显示可用主题（内置+已安装）
        return _allThemes.where((t) => t.isBuiltIn || t.isInstalled).toList();
    }
  }

  Widget _buildThemeList() {
    final filteredThemes = _getFilteredThemes();
    
    if (filteredThemes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('暂无主题', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredThemes.length,
      itemBuilder: (context, index) => _buildThemeCard(filteredThemes[index]),
    );
  }

  Widget _buildThemeCard(ThemePackage theme) {
    final isSelected = widget.currentThemeId == theme.id;
    final colorScheme = Theme.of(context).colorScheme;
    final isInstalled = theme.isInstalled || theme.isBuiltIn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected ? BorderSide(color: colorScheme.primary, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: isInstalled ? () => _selectTheme(theme) : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemePreview(theme),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(theme.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            // 标签
                            if (theme.isBuiltIn)
                              _buildTag('内置', colorScheme.primaryContainer, colorScheme.onPrimaryContainer)
                            else if (theme.isInstalled)
                              _buildTag('已下载', Colors.green.shade100, Colors.green.shade900)
                            else
                              _buildTag('商店', Colors.blue.shade100, Colors.blue.shade900),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(theme.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  // 操作按钮
                  if (isSelected)
                    Icon(Icons.check_circle, color: colorScheme.primary, size: 28)
                  else if (!isInstalled)
                    FilledButton(onPressed: () => _downloadTheme(theme), child: const Text('下载'))
                  else if (theme.isInstalled && !theme.isBuiltIn)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _uninstallTheme(theme),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: textColor)),
    );
  }

  Widget _buildThemePreview(ThemePackage theme) {
    final colors = theme.colors;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Color(int.parse(colors.primary.replaceAll('#', '0xFF'))),
            Color(int.parse(colors.secondary.replaceAll('#', '0xFF'))),
          ],
        ),
      ),
    );
  }

  void _selectTheme(ThemePackage theme) {
    widget.onThemeSelected(theme);
    Navigator.pop(context);
  }

  Future<void> _downloadTheme(ThemePackage theme) async {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('正在下载主题...')]),
        ),
      );
    }

    final success = await _themeService.installTheme(theme);
    
    if (mounted) {
      Navigator.pop(context);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${theme.name} 安装成功')));
        _loadThemes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${theme.name} 安装失败')));
      }
    }
  }

  Future<void> _uninstallTheme(ThemePackage theme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('卸载主题'),
        content: Text('确定要卸载 ${theme.name} 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('卸载'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _themeService.uninstallTheme(theme.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${theme.name} 已卸载')));
          _loadThemes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('卸载失败')));
        }
      }
    }
  }
}
