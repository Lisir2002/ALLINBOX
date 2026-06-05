import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
                  // TODO: 打开设置页面
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
              delegate: SliverChildListDelegate([
                _buildFeatureCard(
                  context,
                  icon: Icons.calculate_outlined,
                  title: '计算器',
                  subtitle: '基础计算工具',
                  color: Colors.blue,
                  onTap: () => _showComingSoon(context, '计算器'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.note_alt_outlined,
                  title: '记事本',
                  subtitle: '记录重要内容',
                  color: Colors.green,
                  onTap: () => _showComingSoon(context, '记事本'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.timer_outlined,
                  title: '计时器',
                  subtitle: '倒计时与秒表',
                  color: Colors.orange,
                  onTap: () => _showComingSoon(context, '计时器'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.qr_code_scanner_outlined,
                  title: '二维码',
                  subtitle: '生成与扫描',
                  color: Colors.purple,
                  onTap: () => _showComingSoon(context, '二维码'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.color_lens_outlined,
                  title: '取色器',
                  subtitle: '颜色选择工具',
                  color: Colors.pink,
                  onTap: () => _showComingSoon(context, '取色器'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: '日历',
                  subtitle: '日程管理',
                  color: Colors.teal,
                  onTap: () => _showComingSoon(context, '日历'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.translate_outlined,
                  title: '翻译',
                  subtitle: '多语言翻译',
                  color: Colors.indigo,
                  onTap: () => _showComingSoon(context, '翻译'),
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.file_copy_outlined,
                  title: '文件管理',
                  subtitle: '浏览与管理文件',
                  color: Colors.brown,
                  onTap: () => _showComingSoon(context, '文件管理'),
                ),
              ]),
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
          setState(() => _selectedIndex = index);
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
    required String subtitle,
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
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
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

  // 功能即将推出提示
  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(featureName),
        content: const Text('该功能正在开发中，敬请期待！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
