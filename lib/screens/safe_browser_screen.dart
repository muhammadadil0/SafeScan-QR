import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SafeBrowserScreen extends StatefulWidget {
  final String url;

  const SafeBrowserScreen({super.key, required this.url});

  @override
  State<SafeBrowserScreen> createState() => _SafeBrowserScreenState();
}

class _SafeBrowserScreenState extends State<SafeBrowserScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onProgress: (int progress) {
            if (mounted) setState(() => _progress = progress / 100);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            // Handle errors quietly or show a snackbar
          },
          onNavigationRequest: (NavigationRequest request) {
            // SANDBOX LOGIC:
            // We can block specific schemes like 'tel:', 'sms:', 'mailto:' to prevent
            // the page from triggering external apps.
            if (request.url.startsWith('https://') || request.url.startsWith('http://')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.url,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _controller.clearCache();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Browser cache cleared')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Clear Cache'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white,
              color: Colors.green,
              minHeight: 3,
            ),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          // Bottom Safety Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Safe Sandbox Mode Active. This site cannot access your device files or other apps.',
                    style: TextStyle(color: Colors.green[900], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
