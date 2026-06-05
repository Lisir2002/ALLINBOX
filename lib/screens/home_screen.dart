import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 功能模块定义
  static const List<_MenuItem> _menuItems = [
    _MenuItem(
      icon: Icons.apps_outlined,
      title: '待开发 1',
      color: Colors.blue,
    ),
    _MenuItem(
      icon: Icons.extension_outlined,
      title: '待开发 2',
      color: Colors.green,
    ),
    _MenuItem(
      icon: Icons.build_outlined,
      title: '待开发 3',
      color: Colors.orange,
    ),
    _MenuItem(
      icon: Icons.dashboard_outlined,
      title: '待开发 4',
      color: Colors.purple,
    ),
    _MenuItem(
      icon: Icons.auto_awesome_outlined,
      title: '待开发 5',
      color: Colors.pink,
    ),
    _MenuItem(
      icon: Icons.bolt_outlined,
      title: '待开发 6',
      color: Colors.teal,
    ),
    _MenuItem(
      icon: Icons.category_outlined,
      title: '待开发 7',
      color: Colors.indigo,
    ),
    _MenuItem(
      icon: Icons.layers_outlined,
      title: '待开发 8',
      color: Colors.brown,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 应用栏
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: colorScheme.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ALL IN BOX',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.all_inclusive,
                    size: 80,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlaceholderScreen(
                        title: '设置',
                        icon: Icons.settings_outlined,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // 欢迎信息
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '欢迎使用 ALL IN BOX',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '选择下方功能开始使用',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),

          // 功能模块网格
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _menuItems[index];
                  return _buildFeatureCard(
                    context,
                    icon: item.icon,
                    title: item.title,
                    color: item.color,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceholderScreen(
                            title: item.title,
                            icon: item.icon,
                            color: item.color,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: _menuItems.length,
              ),
            ),
          ),

          // 底部间距
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),

      // 底部导航栏
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index != 0) {
            // 首页以外的导航项，跳转到占位页面
            final titles = ['首页', '发现', '收藏', '我的'];
            final icons = [
              Icons.home_outlined,
              Icons.explore_outlined,
              Icons.favorite_outline,
              Icons.person_outline,
            ];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceholderScreen(
                  title: titles[index],
                  icon: icons[index],
                ),
              ),
            );
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '发现',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: '收藏',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  // 功能卡片组件
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                '点击进入',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 菜单项数据模型
class _MenuItem {
  final IconData icon;
  final String title;
  final Color color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.color,
  });
}
