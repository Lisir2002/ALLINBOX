# ALL IN BOX

综合工具箱应用 - Flutter 跨平台项目

## 项目信息

- **包名**: com.inbox.all
- **版本**: 1.0.0
- **框架**: Flutter + Dart

## 快速开始

### 环境要求

- Flutter SDK >= 3.4.0
- Dart SDK >= 3.4.0
- Android Studio / VS Code

### 安装依赖

```bash
flutter pub get
```

### 运行项目

```bash
# Android
flutter run -d android

# iOS (需要 Mac 环境)
flutter run -d ios

# Web
flutter run -d chrome
```

### 构建 APK

```bash
flutter build apk --release
```

## 项目结构

```
all-in-box/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── app.dart               # 应用配置
│   └── screens/
│       ├── home_screen.dart   # 主菜单页面
│       ├── settings_screen.dart # 设置页面
│       └── placeholder_screen.dart # 占位页面
├── android/                   # Android 平台代码
├── ios/                       # iOS 平台代码
├── web/                       # Web 平台代码
└── pubspec.yaml               # 项目配置
```

## 功能特性

- [x] 主菜单页面
- [x] 设置页面
  - [x] 主题切换（日间/夜间/跟随系统）
  - [x] 语言切换（简体中文/繁体中文/英文）
  - [x] 缓存管理
- [ ] 更多功能开发中...

## 技术栈

- Flutter 3.x
- Material Design 3
- Dart

## License

MIT
