import 'package:flutter/material.dart';
import '../../models/theme_model.dart';
import '../../services/theme_service.dart';

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
  List<ThemePackage> _themes = [];
  bool _isLoading = true;
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    setState(() => _isLoading = true);
    
    // 获取所有主题
    _themes = _themeService.getAllThemes();
    
    // 尝试获取在线主题
    try {
      final onlineThemes = await _themeService.fetchAvailableThemes();
      _themes.addAll(onlineThemes);
    } catch (e) {
      debugPrint('获取在线主题失败: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                // 分类标签
                _buildCategoryTabs(),
                
                // 主题列表
                Expanded(
                  child: _buildThemeList(),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = ['全部', '内置', '已安装', '在线'];
    
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

  Widget _buildThemeList() {
    final filteredThemes = _getFilteredThemes();
    
    if (filteredThemes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无主题',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredThemes.length,
      itemBuilder: (context, index) {
        final theme = filteredThemes[index];
        return _buildThemeCard(theme);
      },
    );
  }

  List<ThemePackage> _getFilteredThemes() {
    switch (_selectedCategory) {
      case '内置':
        return _themes.where((t) => t.isBuiltIn).toList();
      case '已安装':
        return _themes.where((t) => t.isInstalled && !t.isBuiltIn).toList();
      case '在线':
        return _themes.where((t) => !t.isInstalled && !t.isBuiltIn).toList();
      default:
        return _themes;
    }
  }

  Widget _buildThemeCard(ThemePackage theme) {
    final isSelected = widget.currentThemeId == theme.id;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectTheme(theme),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题预览
              _buildThemePreview(theme),
              
              const SizedBox(height: 12),
              
              // 主题信息
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              theme.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (theme.isBuiltIn) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '内置',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          theme.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 28,
                    )
                  else if (!theme.isInstalled && !theme.isBuiltIn)
                    FilledButton(
                      onPressed: () => _downloadTheme(theme),
                      child: const Text('下载'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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
      child: Stack(
        children: [
          // 模拟 AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Color(int.parse(colors.primary.replaceAll('#', '0xFF'))),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 模拟内容卡片
          Positioned(
            bottom: 8,
            left: 12,
            right: 12,
            child: Container(
              height: 32,
              decoration: BoxDecoration(
                color: Color(int.parse(colors.surface.replaceAll('#', '0xFF'))),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectTheme(ThemePackage theme) {
    widget.onThemeSelected(theme);
    Navigator.pop(context);
  }

  Future<void> _downloadTheme(ThemePackage theme) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在下载主题...'),
          ],
        ),
      ),
    );

    final success = await _themeService.installTheme(theme);
    
    if (mounted) {
      Navigator.pop(context); // 关闭加载对话框
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${theme.name} 安装成功')),
        );
        _loadThemes(); // 刷新列表
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${theme.name} 安装失败')),
        );
      }
    }
  }
}
