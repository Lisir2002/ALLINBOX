import 'package:flutter/material.dart';
import 'models/theme_model.dart';
import 'services/theme_service.dart';
import 'screens/home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeService _themeService = ThemeService();
  ThemeMode _themeMode = ThemeMode.system;
  ThemePackage? _currentTheme;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initThemeService();
  }

  Future<void> _initThemeService() async {
    await _themeService.init();
    setState(() {
      _currentTheme = _themeService.getCurrentTheme();
      _isInitialized = true;
    });
  }

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
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
                Icon(
                  Icons.all_inclusive,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
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

    final lightTheme = _themeService.getThemeData(_currentTheme!, isDark: false);
    final darkTheme = _themeService.getThemeData(_currentTheme!, isDark: true);

    return MaterialApp(
      title: 'ALL IN BOX',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _changeThemeMode,
        currentTheme: _currentTheme!,
        onThemeSelected: _changeTheme,
      ),
    );
  }
}
