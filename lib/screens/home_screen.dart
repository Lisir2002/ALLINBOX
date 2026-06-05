import 'package:flutter/material.dart';
import 'placeholder_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final Function(ThemeMode) onThemeChanged;
  final Locale currentLocale;
  final Function(Locale) onLocaleChanged;

  const HomeScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  // 功能模块定义
  static final List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps,
      title: '待开发 1',
      subtitle: '功能模块',
      color: Colors.blue,
      gradient: [Colors.blue.shade300, Colors.blue.shade700],
    ),
    _MenuItem(
      icon: Icons.extension_outlined,
      activeIcon: Icons.extension,
      title: '待开发 2',
      subtitle: '功能模块',
      color: Colors.green,
      gradient: [Colors.green.shade300, Colors.green.shade700],
    ),
    _MenuItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      title: '待开发 3',
      subtitle: '功能模块',
      color: Colors.orange,
      gradient: [Colors.orange.shade300, Colors.orange.shade700],
    ),
    _MenuItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      title: '待开发 4',
      subtitle: '功能模块',
      color: Colors.purple,
      gradient: [Colors.purple.shade300, Colors.purple.shade700],
    ),
    _MenuItem(
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      title: '待开发 5',
      subtitle: '功能模块',
      color: Colors.pink,
      gradient: [Colors.pink.shade300, Colors.pink.shade700],
    ),
    _MenuItem(
      icon: Icons.bolt_outlined,
      activeIcon: Icons.bolt,
      title: '待开发 6',
      subtitle: '功能模块',
      color: Colors.teal,
      gradient: [Colors.teal.shade300, Colors.teal.shade700],
    ),
    _MenuItem(
      icon: Icons.category_outlined,
      activeIcon: Icons.category,
      title: '待开发 7',
      subtitle: '功能模块',
      color: Colors.indigo,
      gradient: [Colors.indigo.shade300, Colors.indigo.shade700],
    ),
    _MenuItem(
      icon: Icons.layers_outlined,
      activeIcon: Icons.layers,
      title: '待开发 8',
      subtitle: '功能模块',
      color: Colors.brown,
      gradient: [Colors.brown.shade300, Colors.brown.shade700],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 应用栏
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ALL IN BOX',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.primary.withOpacity(0.3),
                      colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.secondary.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.all_inclusive,
                        size: 60,
                        color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _showSearch(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  _navigateToSettings(context);
                },
              ),
            ],
          ),

          // 欢迎信息
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.waving_hand,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '欢迎回来',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '选择功能开始使用',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 功能模块网格
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _menuItems[index];
                  return _buildFeatureCard(
                    context,
                    item: item,
                    index: index,
                  );
                },
                childCount: _menuItems.length,
              ),
            ),
          ),

          // 底部版本信息
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'ALL IN BOX v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 导航到设置页面
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          currentThemeMode: widget.currentThemeMode,
          onThemeChanged: widget.onThemeChanged,
          currentLocale: widget.currentLocale,
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
  }

  // 功能卡片组件
  Widget _buildFeatureCard(
    BuildContext context, {
    required _MenuItem item,
    required int index,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _navigateToFeature(context, item);
          },
          onLongPress: () {
            _showFeatureInfo(context, item);
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(0.05),
                  item.color.withOpacity(0.15),
                ],
              ),
            ),
            child: Stack(
              children: [
                // 装饰圆
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.color.withOpacity(0.1),
                    ),
                  ),
                ),
                // 内容
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          size: 28,
                          color: item.color,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            item.subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 导航到功能页面
  void _navigateToFeature(BuildContext context, _MenuItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PlaceholderScreen(
          title: item.title,
          icon: item.activeIcon,
          color: item.color,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // 显示功能信息
  void _showFeatureInfo(BuildContext context, _MenuItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.activeIcon,
                  size: 40,
                  color: item.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '该功能正在开发中，敬请期待',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('知道了'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 搜索功能
  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _MenuSearchDelegate(_menuItems),
    );
  }
}

// 搜索代理
class _MenuSearchDelegate extends SearchDelegate<String> {
  final List<_MenuItem> items;

  _MenuSearchDelegate(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final results = items
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关功能',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: item.color),
          ),
          title: Text(item.title),
          subtitle: Text(item.subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            close(context, item.title);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceholderScreen(
                  title: item.title,
                  icon: item.activeIcon,
                  color: item.color,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// 菜单项数据模型
class _MenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradient;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradient,
  });
}
