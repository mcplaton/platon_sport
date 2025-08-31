import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EmbeddedWebAppPage extends StatefulWidget {
  final String title;
  final String url;
  const EmbeddedWebAppPage({super.key, required this.title, required this.url});

  @override
  State<EmbeddedWebAppPage> createState() => _EmbeddedWebAppPageState();
}

class _EmbeddedWebAppPageState extends State<EmbeddedWebAppPage> {
  InAppWebViewController? _c;

  // نعطّل edge-to-edge هنا فقط حتى لا تزحف الصفحة للأعلى
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    // نعيد الوضع الافتراضي للتطبيق
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // CSS عام لإخفاء لافتات/أزرار فتح التطبيق
  static const _CSS = '''
#smartbanner, .smartbanner, .app-banner, .install-app, .download-app, .open-in-app,
[data-open-app], a[href*="play.google.com"], a[href*="apps.apple.com"],
a[href^="market:"], a[href^="intent:"], .store-btn, .get-the-app, .pwa-install,
div[role="dialog"] button:has(svg[aria-label="android"]), 
div[role="dialog"] a:has(svg[aria-label="android"]) {
  display:none !important; visibility:hidden !important; height:0 !important; overflow:hidden !important;
}
html,body{ overscroll-behavior-y:contain; }
''';

  // JS عام + مراقِب لإزالة أي عناصر دعائية وفتح التطبيق
  static const _GENERIC = r'''
try{
  // منع شاشة تنصيب PWA والمتاجر
  window.addEventListener('beforeinstallprompt', e => { e.preventDefault(); return false; }, {capture:true, passive:false});
  const kill = (el)=>{ try{ el.style.setProperty('display','none','important'); el.remove(); }catch(e){} };
  const sel = ['#smartbanner','.smartbanner','.app-banner','.download-app','.install-app','.open-in-app','[data-open-app]','a[href*="play.google.com"]','a[href*="apps.apple.com"]','a[href^="market:"]','a[href^="intent:"]','.store-btn','.get-the-app','.pwa-install'];
  const hide = ()=>{
    sel.forEach(s=>document.querySelectorAll(s).forEach(kill));
    // اخفاء أي دايالوج فيه ترويج للتطبيق
    document.querySelectorAll('div[role="dialog"], .modal, .sheet').forEach(d=>{
      const t=(d.innerText||'').trim();
      if (/تطبيق|App|Android|iOS|المتجر/i.test(t)) kill(d);
    });
  };
  hide();
  new MutationObserver(hide).observe(document.documentElement,{childList:true,subtree:true,attributes:true});
}catch(e){}
''';

  // سينمانا: اضغط "الاستمرار في الموقع" تلقائيًا واخفِ الطبقة
  static const _CINEMANA = r'''
try{
  const pressContinue = ()=>{
    const ok = ['الاستمرار في الموقع','تابع بالموقع','Continue on website'];
    // اضغط الزر
    document.querySelectorAll('button,a').forEach(el=>{
      const t=(el.innerText||'').trim();
      if (ok.some(k=>t.includes(k))) { try{ el.click(); }catch(e){} }
    });
    // اخفاء طبقة البنر/المودال
    document.querySelectorAll('div[role="dialog"], .modal, .sheet, .install-app, .download-app')
      .forEach(el=>{ el.style.setProperty('display','none','important'); el.remove(); });
  };
  pressContinue();
  setInterval(pressContinue, 900);
}catch(e){}
''';

  Future<bool> _onBack() async {
    if (_c != null && await _c!.canGoBack()) {
      await _c!.goBack();
      return false; // لا تخرج من الصفحة
    }
    return true; // اخرج
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              cacheEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              thirdPartyCookiesEnabled: true,
              allowsBackForwardNavigationGestures: true,
              verticalScrollBarEnabled: false,
              horizontalScrollBarEnabled: false,
              transparentBackground: false,
              // UA يُوهم الموقع أننا متصفح موبايل عادي داخل تطبيق
              userAgent:
                "Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36 AppWebView/PlatonSport",
            ),
            onWebViewCreated: (c) => _c = c,

            // امنع أي فتح خارجي للمتاجر/النيات
            shouldOverrideUrlLoading: (c, nav) async {
              final url = nav.request.url?.toString() ?? '';
              if (url.contains('play.google.com') ||
                  url.contains('apps.apple.com') ||
                  url.startsWith('market:') ||
                  url.startsWith('intent:')) {
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },

            onLoadStop: (c, url) async {
              await c.injectCSSCode(source: _CSS);
              await c.evaluateJavascript(source: _GENERIC);

              final host = (url?.host ?? '').toLowerCase();
              if (host.contains('cinemana.shabakaty.com')) {
                await c.evaluateJavascript(source: _CINEMANA);
              }
            },

            // أي نافذة جديدة افتحها في نفس الويب فيو
            onCreateWindow: (c, req) async {
              final u = req.request.url;
              if (u != null) {
                await _c?.loadUrl(urlRequest: URLRequest(url: u));
              }
              return true;
            },
          ),
        ),
      ),
    );
  }
}
