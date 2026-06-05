import 'package:flutter/material.dart';
import 'models/theme_model.dart';
import 'services/theme_service.dart';
import 'services/app_service.dart';
import 'screens/home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  ThemePackage? _currentTheme;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initThemeService();
  }

  Future<void> _initThemeService() async {
    await _themeService.init();
    await AppService().init();
    setState(() {
      _currentTheme = _themeService.getCurrentTheme();
      _isInitialized = true;
    });
  }

  void _changeTheme(ThemePackage theme) {
    _themeService.setCurrentTheme(theme.id);
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.all_inclusive, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                const Text('ALL IN BOX'),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      );
    }

    final themeData = _themeService.getThemeData(_currentTheme!);

    return MaterialApp(
      title: 'ALL IN BOX',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      home: HomeScreen(
        currentTheme: _currentTheme!,
        onThemeSelected: _changeTheme,
      ),
    );
  }
}
