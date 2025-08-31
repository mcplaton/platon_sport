import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MatchesWebView extends StatefulWidget {
  const MatchesWebView({super.key});

  @override
  State<MatchesWebView> createState() => _MatchesWebViewState();
}

class _MatchesWebViewState extends State<MatchesWebView> {
  InAppWebViewController? _c;
  final _pull = PullToRefreshController(
    options: PullToRefreshOptions(color: Colors.white),
  );

  static const _CSS_HIDE = '''
button:has(svg[aria-label="refresh"]),
button:has(i.bi-arrow-clockwise),
a:has(svg[aria-label="refresh"]) {
  display:none !important;
}
''';

  static const _GENERIC_HIDE = r'''
try{
  const hide = () => {
    document.querySelectorAll('button, a').forEach(el=>{
      const t=(el.innerText||'').trim();
      if (['تحديث','Refresh'].includes(t)) { el.style.setProperty('display','none','important'); }
    });
  };
  hide();
  new MutationObserver(hide).observe(document.documentElement,{childList:true,subtree:true});
}catch(e){}
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://www.yalla-shoot-365.com/matches/'),
          ),
          pullToRefreshController: _pull,
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            domStorageEnabled: true,
            cacheEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            userAgent:
                "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Mobile Safari/537.36 AppWebView/PlatonSport",
          ),
          onWebViewCreated: (c) => _c = c,
          onLoadStop: (c, _) async {
            _pull.endRefreshing();
            await c.injectCSSCode(source: _CSS_HIDE);
            await c.evaluateJavascript(source: _GENERIC_HIDE);
          },
        ),
      ),
    );
  }
}
