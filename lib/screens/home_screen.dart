import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../services/app_service.dart';
import 'placeholder_screen.dart';
import 'settings_screen.dart';
import 'app_builder/app_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemePackage currentTheme;
  final Function(ThemePackage) onThemeSelected;

  const HomeScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  static final List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.apps_outlined, activeIcon: Icons.apps, title: 'APP生成', color: Colors.blue, isMain: true),
    _MenuItem(icon: Icons.extension_outlined, activeIcon: Icons.extension, title: '待开发 2', color: Colors.green),
    _MenuItem(icon: Icons.build_outlined, activeIcon: Icons.build, title: '待开发 3', color: Colors.orange),
    _MenuItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, title: '待开发 4', color: Colors.purple),
    _MenuItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, title: '待开发 5', color: Colors.pink),
    _MenuItem(icon: Icons.bolt_outlined, activeIcon: Icons.bolt, title: '待开发 6', color: Colors.teal),
    _MenuItem(icon: Icons.category_outlined, activeIcon: Icons.category, title: '待开发 7', color: Colors.indigo),
    _MenuItem(icon: Icons.layers_outlined, activeIcon: Icons.layers, title: '待开发 8', color: Colors.brown),
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
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              collapseMode: CollapseMode.pin,
              title: const Text(
                'ALL IN BOX',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 2),
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
                child: Center(
                  child: Icon(
                    Icons.all_inclusive,
                    size: 60,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.2),
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
                      builder: (context) => SettingsScreen(
                        currentTheme: widget.currentTheme,
                        onThemeSelected: widget.onThemeSelected,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.waving_hand, color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('欢迎回来', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('选择功能开始使用', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

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
                  return _buildFeatureCard(context, item: item, index: index);
                },
                childCount: _menuItems.length,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'ALL IN BOX v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required _MenuItem item, required int index}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Transform.scale(scale: value, child: child),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (item.isMain) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppManagerScreen()),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceholderScreen(title: item.title, icon: item.activeIcon, color: item.color),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [item.color.withOpacity(0.05), item.color.withOpacity(0.15)],
              ),
            ),
            child: Padding(
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
                    child: Icon(item.icon, size: 28, color: item.color),
                  ),
                  const Spacer(),
                  Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('点击进入', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final IconData activeIcon;
  final String title;
  final Color color;
  final bool isMain;

  const _MenuItem({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.color,
    this.isMain = false,
  });
}
