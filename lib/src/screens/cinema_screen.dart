import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CinemaScreen extends StatelessWidget {
  const CinemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_CinemaItem>[
      _CinemaItem(
        title: 'سينمانا',
        url: 'https://cinemana.shabakaty.com/home',
        iconUrl: 'https://pbs.twimg.com/profile_images/1555882172178907136/jismNIAg_400x400.jpg',
      ),
      _CinemaItem(
        title: 'فودو',
        url: 'https://movie.vodu.me/',
        iconUrl: 'https://apkrabi.com/uploads/2022/7/vodu-icon.jpg',
      ),
      _CinemaItem(
        title: 'CEE',
        url: 'https://cee.buzz/home',
        iconUrl: 'https://cee.buzz/assets/images/logos/logo-new.svg',
      ),
      _CinemaItem(
        title: 'شاشتي',
        url: 'https://cinema.shashety.com/',
        iconUrl: 'https://play-lh.googleusercontent.com/qYwNLSG1xEadJC-MzwkyIqR1EqpLHyniLri-PVx4oimYbH9jxzEskmoX_dMky8IHTO4',
      ),
      _CinemaItem(
        title: 'سينما بوكس',
        url: 'https://cinema.albox.co/',
        iconUrl: 'https://play-lh.googleusercontent.com/q3GPQMOBx4XYhVo5fTz5ds43bF0Y98bztmPT8Gs5sLtxQkwWvHSidX9BqqJ83FtwbVJ-',
      ),
      _CinemaItem(
        title: 'ستارز اون',
        url: 'https://starzplay.com/ar',
        iconUrl: 'https://play-lh.googleusercontent.com/ZF0lnNTgrJqZ-WLubeF09m_gLt4IaL7189Wv0F6uwHmO7gJB3Om5bhanXdJci8FenNuS',
      ),
      _CinemaItem(
        title: 'فشار',
        url: 'https://www.fushaar.com/',
        iconUrl: 'https://pbs.twimg.com/profile_images/1161967424578740224/NrkWA2j9_400x400.jpg',
      ),
      _CinemaItem(
        title: 'سيما فوريو',
        url: 'https://cima4u.info/',
        iconUrl: 'https://apkrabi.com/uploads/2023/3/cima4u-icon.jpg',
      ),
    ];

    return SafeArea(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,           // بطاقتين بكل صف
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => _CinemaCard(item: items[i]),
      ),
    );
  }
}

class _CinemaCard extends StatelessWidget {
  final _CinemaItem item;
  const _CinemaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final border = Border.all(color: Colors.white12);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EmbeddedWebAppPage(title: item.title, url: item.url),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF151A22),
          borderRadius: BorderRadius.circular(18),
          border: border,
        ),
        child: Column(
          children: [
            // صورة/شعار الخدمة
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF0E1116),
                  child: _Logo(url: item.iconUrl),
                ),
              ),
            ),
            // العنوان + زر فتح
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EmbeddedWebAppPage(title: item.title, url: item.url),
                        ),
                      ),
                      child: const Text('فتح'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ويدجت ذكي لعرض الشعار (يدعم SVG/PNG/JPG)
class _Logo extends StatelessWidget {
  final String url;
  const _Logo({required this.url});

  @override
  Widget build(BuildContext context) {
    final isSvg = url.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.network(
        url,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, evt) => evt == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.white38)),
      );
    }
  }
}

class _CinemaItem {
  final String title;
  final String url;
  final String iconUrl;
  _CinemaItem({required this.title, required this.url, required this.iconUrl});
}

/// صفحة ويب مدمجة تبدو كتطبيق حقيقي
class EmbeddedWebAppPage extends StatefulWidget {
  final String title;
  final String url;
  const EmbeddedWebAppPage({super.key, required this.title, required this.url});

  @override
  State<EmbeddedWebAppPage> createState() => _EmbeddedWebAppPageState();
}

class _EmbeddedWebAppPageState extends State<EmbeddedWebAppPage> {
  InAppWebViewController? _controller;
  late final PullToRefreshController _pull;

  @override
  void initState() {
    super.initState();
    // منع زحف المحتوى للأعلى داخل هذه الصفحة فقط
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _pull = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.white),
      onRefresh: () async => await _controller?.reload(),
    );
  }

  @override
  void dispose() {
    // إعادة الوضع الافتراضي للتطبيق
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  // CSS عام لإخفاء لافتات/أزرار فتح التطبيق
  static const _CSS_HIDE = '''
#smartbanner, .smartbanner, .app-banner, .install-app, .download-app, .open-in-app,
[data-open-app], a[href*="play.google.com"], a[href*="apps.apple.com"],
a[href^="market:"], a[href^="intent:"], .store-btn, .get-the-app, .pwa-install {
  display:none !important; visibility:hidden !important; height:0 !important; overflow:hidden !important;
}
html,body{ overscroll-behavior-y:contain; }
''';

  // JS عام لإلغاء أي محاولة لفتح المتاجر/تنصيب PWA وإخفاء العناصر الدعائية
  static const _ANTI_INSTALL_JS = r'''
try{
  window.addEventListener('beforeinstallprompt', e => { e.preventDefault(); return false; }, {capture:true, passive:false});
  const kill = (el)=>{ try{ el.style.setProperty('display','none','important'); el.remove(); }catch(e){} };
  const sel = ['#smartbanner','.smartbanner','.app-banner','.download-app','.install-app','.open-in-app','[data-open-app]',
               'a[href*="play.google.com"]','a[href*="apps.apple.com"]','a[href^="market:"]','a[href^="intent:"]',
               '.store-btn','.get-the-app','.pwa-install'];
  const hide = ()=>{
    sel.forEach(s=>document.querySelectorAll(s).forEach(kill));
    document.querySelectorAll('div[role="dialog"], .modal, .sheet').forEach(d=>{
      const t=(d.innerText||'').trim();
      if (/تطبيق|App|Android|iOS|المتجر|Install/i.test(t)) kill(d);
    });
  };
  hide();
  new MutationObserver(hide).observe(document.documentElement,{childList:true,subtree:true,attributes:true,characterData:true});
}catch(e){}
''';

  // سكربت خاص لسينمانا: اضغط "الاستمرار في الموقع" تلقائيًا وأخفِ أي طبقات
  static const _CINEMANA_JS = r'''
try{
  const pressContinue = ()=>{
    const ok = ['الاستمرار في الموقع','تابع بالموقع','Continue on website'];
    document.querySelectorAll('button,a').forEach(el=>{
      const t=(el.innerText||'').trim();
      if (ok.some(k=>t.includes(k))) { try{ el.click(); }catch(e){} }
    });
    document.querySelectorAll('div[role="dialog"], .modal, .sheet, .install-app, .download-app')
      .forEach(el=>{ el.style.setProperty('display','none','important'); el.remove(); });
  };
  pressContinue();
  setInterval(pressContinue, 900);
}catch(e){}
''';

  Future<bool> _onBack() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
      return false; // لا تخرج من الصفحة؛ ارجع خطوة داخل الموقع
    }
    return true; // اخرج من الشاشة
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
            pullToRefreshController: _pull,
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
              // UA يوحي أن الصفحة تعمل داخل تطبيق
              userAgent:
                "Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36 AppWebView/PlatonSport",
            ),
            onWebViewCreated: (c) => _controller = c,

            // أي محاولة لفتح متجر/Intent تُمنع
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
              _pull.endRefreshing();
              await c.injectCSSCode(source: _CSS_HIDE);
              await c.evaluateJavascript(source: _ANTI_INSTALL_JS);
              final host = (url?.host ?? '').toLowerCase();
              if (host.contains('cinemana.shabakaty.com')) {
                await c.evaluateJavascript(source: _CINEMANA_JS);
              }
            },

            // افتح النوافذ المنبثقة في نفس الويب فيو
            onCreateWindow: (c, req) async {
              final u = req.request.url;
              if (u != null) {
                await _controller?.loadUrl(urlRequest: URLRequest(url: u));
              }
              return true;
            },
          ),
        ),
      ),
    );
  }
}
