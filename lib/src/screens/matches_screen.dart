import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  static const String _matchesUrl = 'https://www.yalla-shoot-365.com/matches/';

  late final WebViewController _controller;
  double _progress = 0.0;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0E1116))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100.0),
          onWebResourceError: (err) {
            // يمكنك إظهار Snackbar هنا إن رغبت
          },
        ),
      )
      ..loadRequest(Uri.parse(_matchesUrl));

    // تحديث تلقائي كل 5 دقائق
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _controller.reload();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress < 1.0)
          LinearProgressIndicator(value: _progress, minHeight: 2),
        Expanded(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              // تلميح بسيط للسحب للتحديث (يدوي: نسوي Gesture يطلب إعادة تحميل)
              // إن أردتها حقيقية، نستبدل الحزمة بـ flutter_inappwebview.
              Positioned(
                right: 12,
                bottom: 12,
                child: FloatingActionButton.extended(
                  heroTag: 'refreshMatches',
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
