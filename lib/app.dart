import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('zh', 'CN');
  Key _appKey = UniqueKey();

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _appKey = UniqueKey();
    });
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
      _appKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: _appKey,
      title: 'ALL IN BOX',
      debugShowCheckedModeBanner: false,
      
      // 主题配置
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C5CE7),
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C5CE7),
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      ),
      themeMode: _themeMode,

      // 语言配置
      locale: _locale,
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('en'),
      ],

      home: HomeScreen(
        currentThemeMode: _themeMode,
        onThemeChanged: _changeThemeMode,
        currentLocale: _locale,
        onLocaleChanged: _changeLocale,
      ),
    );
  }
}
