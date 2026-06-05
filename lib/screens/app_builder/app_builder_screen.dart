import 'package:flutter/material.dart';
import '../../models/app_model.dart';
import '../../services/app_service.dart';
import '../app_runner/app_runner_screen.dart';

/// APP 创建/编辑页面
class AppBuilderScreen extends StatefulWidget {
  final CustomApp? existingApp;

  const AppBuilderScreen({super.key, this.existingApp});

  @override
  State<AppBuilderScreen> createState() => _AppBuilderScreenState();
}

class _AppBuilderScreenState extends State<AppBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppService _appService = AppService();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _cssCtrl;
  late TextEditingController _jsCtrl;
  
  String _selectedIcon = 'language';
  String _selectedColor = '#6C5CE7';

  bool get isEditing => widget.existingApp != null;

  // 可选图标列表
  static final List<_IconOption> _icons = [
    _IconOption('language', Icons.language, '网页'),
    _IconOption('shopping_cart', Icons.shopping_cart, '商城'),
    _IconOption('article', Icons.article, '文章'),
    _IconOption('chat', Icons.chat, '聊天'),
    _IconOption('video_library', Icons.video_library, '视频'),
    _IconOption('music_note', Icons.music_note, '音乐'),
    _IconOption('camera_alt', Icons.camera_alt, '相机'),
    _IconOption('map', Icons.map, '地图'),
    _IconOption('sports_esports', Icons.sports_esports, '游戏'),
    _IconOption('school', Icons.school, '教育'),
    _IconOption('favorite', Icons.favorite, '健康'),
    _IconOption('work', Icons.work, '工作'),
    _IconOption('flight', Icons.flight, '旅行'),
    _IconOption('restaurant', Icons.restaurant, '美食'),
    _IconOption('local_shipping', Icons.local_shipping, '物流'),
    _IconOption('code', Icons.code, '开发'),
    _IconOption('cloud', Icons.cloud, '云服务'),
    _IconOption('dashboard', Icons.dashboard, '仪表盘'),
    _IconOption('settings', Icons.settings, '工具'),
    _IconOption('home', Icons.home, '主页'),
    _IconOption('star', Icons.star, '收藏'),
    _IconOption('whatshot', Icons.whatshot, '热门'),
    _IconOption('new_releases', Icons.new_releases, '新品'),
    _IconOption('trending_up', Icons.trending_up, '趋势'),
  ];

  // 可选颜色列表
  static final List<_ColorOption> _colors = [
    _ColorOption('#6C5CE7', Colors.purple, '紫色'),
    _ColorOption('#0984E3', Colors.blue, '蓝色'),
    _ColorOption('#00B894', Colors.teal, '青绿'),
    _ColorOption('#00CEC9', Colors.cyan, '青色'),
    _ColorOption('#E17055', Colors.deepOrange, '橙色'),
    _ColorOption('#D63031', Colors.red, '红色'),
    _ColorOption('#FD79A8', Colors.pink, '粉色'),
    _ColorOption('#FDCB6E', Colors.amber, '金色'),
    _ColorOption('#2D3436', Colors.blueGrey, '深灰'),
    _ColorOption('#636E72', Colors.grey, '灰色'),
  ];

  @override
  void initState() {
    super.initState();
    final app = widget.existingApp;
    _nameCtrl = TextEditingController(text: app?.name ?? '');
    _urlCtrl = TextEditingController(text: app?.url ?? 'https://');
    _descCtrl = TextEditingController(text: app?.description ?? '');
    _cssCtrl = TextEditingController(text: app?.injectCSS ?? '');
    _jsCtrl = TextEditingController(text: app?.injectJS ?? '');
    if (app != null) {
      _selectedIcon = app.iconName;
      _selectedColor = app.iconColor;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _descCtrl.dispose();
    _cssCtrl.dispose();
    _jsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (isEditing) {
      final updated = widget.existingApp!.copyWith(
        name: _nameCtrl.text.trim(),
        url: _urlCtrl.text.trim(),
        iconName: _selectedIcon,
        iconColor: _selectedColor,
        description: _descCtrl.text.trim(),
        injectCSS: _cssCtrl.text.trim().isEmpty ? null : _cssCtrl.text.trim(),
        injectJS: _jsCtrl.text.trim().isEmpty ? null : _jsCtrl.text.trim(),
      );
      await _appService.updateApp(updated);
    } else {
      await _appService.addApp(
        name: _nameCtrl.text.trim(),
        url: _urlCtrl.text.trim(),
        iconName: _selectedIcon,
        iconColor: _selectedColor,
        description: _descCtrl.text.trim(),
        injectCSS: _cssCtrl.text.trim().isEmpty ? null : _cssCtrl.text.trim(),
        injectJS: _jsCtrl.text.trim().isEmpty ? null : _jsCtrl.text.trim(),
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? '已更新' : '已创建')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑应用' : '创建应用'),
        centerTitle: true,
        actions: [
          // 预览按钮
          TextButton.icon(
            onPressed: () {
              if (_urlCtrl.text.trim().startsWith('http')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppRunnerScreen(
                      title: _nameCtrl.text.isEmpty ? '预览' : _nameCtrl.text,
                      url: _urlCtrl.text.trim(),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入有效的 URL')),
                );
              }
            },
            icon: const Icon(Icons.visibility, size: 18),
            label: const Text('预览'),
          ),
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 预览卡片
            _buildPreviewCard(context),
            const SizedBox(height: 24),

            // 基本信息
            Text('基本信息', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '应用名称',
                hintText: '例如: 我的博客',
                prefixIcon: Icon(Icons.apps),
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? '请输入名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: '网址 URL',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '请输入URL';
                if (!v.trim().startsWith('http')) return 'URL 必须以 http 开头';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                hintText: '简短描述这个应用',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // 图标选择
            Text('选择图标', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((icon) {
                final isSelected = _selectedIcon == icon.name;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon.name),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))).withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? Border.all(color: Color(int.parse(_selectedColor.replaceAll('#', '0xFF')))) : Border.all(color: Colors.transparent),
                    ),
                    child: Tooltip(
                      message: icon.label,
                      child: Icon(icon.icon, size: 28, color: isSelected ? Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))) : colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 颜色选择
            Text('主题颜色', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((c) {
                final isSelected = _selectedColor == c.hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c.hex),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: colorScheme.primary, width: 3) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 高级选项
            Text('高级选项', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cssCtrl,
              decoration: const InputDecoration(
                labelText: '注入 CSS（可选）',
                hintText: '.ads { display: none !important; }',
                prefixIcon: Icon(Icons.style),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jsCtrl,
              decoration: const InputDecoration(
                labelText: '注入 JS（可选）',
                hintText: 'console.log("Hello");',
                prefixIcon: Icon(Icons.javascript),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = _icons.firstWhere((i) => i.name == _selectedIcon, orElse: () => _icons.first).icon;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))),
            Color(int.parse(_selectedColor.replaceAll('#', '0xFF'))).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(iconData, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            _nameCtrl.text.isEmpty ? '应用预览' : _nameCtrl.text,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _urlCtrl.text.isEmpty ? 'https://...' : _urlCtrl.text,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _IconOption {
  final String name;
  final IconData icon;
  final String label;
  const _IconOption(this.name, this.icon, this.label);
}

class _ColorOption {
  final String hex;
  final Color color;
  final String label;
  const _ColorOption(this.hex, this.color, this.label);
}
