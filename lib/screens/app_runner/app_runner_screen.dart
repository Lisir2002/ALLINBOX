import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView 预览/运行页面
class AppRunnerScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? injectCSS;
  final String? injectJS;

  const AppRunnerScreen({
    super.key,
    required this.title,
    required this.url,
    this.injectCSS,
    this.injectJS,
  });

  @override
  State<AppRunnerScreen> createState() => _AppRunnerScreenState();
}

class _AppRunnerScreenState extends State<AppRunnerScreen> {
  late final WebViewController _controller;
  double _progress = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            _progress = progress / 100;
            _isLoading = progress < 100;
          });
        },
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));

    // 注入 CSS/JS
    if (widget.injectCSS != null && widget.injectCSS!.isNotEmpty) {
      _injectScripts();
    }
  }

  Future<void> _injectScripts() async {
    await _controller.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (_) async {
        if (widget.injectCSS != null && widget.injectCSS!.isNotEmpty) {
          final escapedCSS = widget.injectCSS!.replaceAll("'", "\\'").replaceAll('\n', ' ');
          await _controller.runJavaScript("""
            var style = document.createElement('style');
            style.textContent = '$escapedCSS';
            document.head.appendChild(style);
          """);
        }
        if (widget.injectJS != null && widget.injectJS!.isNotEmpty) {
          await _controller.runJavaScript(widget.injectJS!);
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: WebViewWidget(controller: _controller),
      floatingActionButton: _isLoading
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'back',
                  onPressed: () => _controller.goBack(),
                  child: const Icon(Icons.arrow_back),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'refresh',
                  onPressed: () => _controller.reload(),
                  child: const Icon(Icons.refresh),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'forward',
                  onPressed: () => _controller.goForward(),
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
    );
  }
}
