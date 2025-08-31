import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:firebase_core/firebase_core.dart';

import '../services/channels_service.dart';
import '../data/channel_logos.dart';

class ChannelsScreen extends StatelessWidget {
  const ChannelsScreen({super.key});

  Future<void> _ready() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _ready(),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return const _ChannelsBody();
      },
    );
  }
}

class _ChannelsBody extends StatelessWidget {
  const _ChannelsBody();

  @override
  Widget build(BuildContext context) {
    final service = ChannelsService();

    return StreamBuilder<List<Channel>>(
      stream: service.watch(),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Text('لا توجد قنوات متاحة الآن'));
        }

        // ترتيب BEIN 1..9 أولاً
        final order = const ["BEIN 1","BEIN 2","BEIN 3","BEIN 4","BEIN 5","BEIN 6","BEIN 7","BEIN 8","BEIN 9"];
        list.sort((a, b) {
          final ai = order.indexOf(a.name.toUpperCase());
          final bi = order.indexOf(b.name.toUpperCase());
          if (ai == -1 && bi == -1) return a.name.compareTo(b.name);
          if (ai == -1) return 1;
          if (bi == -1) return -1;
          return ai.compareTo(bi);
        });

        return SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final ch = list[i];
              final logo = channelLogos[ch.name] ??
                  channelLogos[ch.name.toUpperCase()] ??
                  channelLogos[ch.name.toLowerCase()];
              return Card(
                color: const Color(0xFF151A22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: (logo != null && logo.toString().isNotEmpty)
                        ? Image.network(
                            logo.toString(),
                            width: 40, height: 40, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.tv, size: 32),
                          )
                        : const Icon(Icons.tv, size: 32),
                  ),
                  title: Text(
                    ch.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${ch.sources.length} روابط',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlayerPage(channel: ch)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class PlayerPage extends StatefulWidget {
  final Channel channel;
  const PlayerPage({super.key, required this.channel});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with RouteAware {
  late VlcPlayerController _controller;
  int _index = 0;

  String get _currentUrl => widget.channel.sources[_index].url;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _controller = VlcPlayerController.network(
      _currentUrl,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  Future<void> _switchSource(int i) async {
    if (i == _index) return;
    setState(() => _index = i);
    final url = _currentUrl;
    try {
      await _controller.setMediaFromNetwork(url, autoPlay: true);
      await _controller.play();
    } catch (_) {
      try { await _controller.stop(); await _controller.dispose(); } catch (_) {}
      _controller = VlcPlayerController.network(
        url, hwAcc: HwAcc.full, autoPlay: true, options: VlcPlayerOptions(),
      );
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    try { _controller.stop(); _controller.dispose(); } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sources = widget.channel.sources;

    final playerNormal = AspectRatio(
      aspectRatio: 16 / 9, // بسيط لتفادي مشكلة "صوت فقط"
      child: VlcPlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
        placeholder: const Center(child: CircularProgressIndicator()),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () async {
              // أوقف تشغيل الكنترولر الحالي قبل فتح fullscreen
              try { await _controller.pause(); } catch (_) {}
              final pos = await _controller.getPosition(); // قد تكون null
              await Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: true,
                  pageBuilder: (_, __, ___) => FullscreenPlayerPage(
                    url: _currentUrl,
                    startAt: pos,
                  ),
                ),
              );
              // بعد الرجوع: أعِد تشغيل المشغّل الأصلي لنفس الرابط
              try {
                await _controller.setMediaFromNetwork(_currentUrl, autoPlay: true);
                await _controller.play();
              } catch (_) {}
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: playerNormal)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(sources.length, (i) {
                final selected = i == _index;
                final q = sources[i].quality;
                final label = (q != null && q.isNotEmpty)
                    ? 'مصدر ${i + 1} • $q'
                    : 'مصدر ${i + 1}';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => _switchSource(i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          const Text('إذا تعطل مصدر، جرّب مصدرًا آخر.',
              style: TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
}

/// صفحة ملء الشاشة بكنترولر مستقل (لا نشارك الـTextureId)
class FullscreenPlayerPage extends StatefulWidget {
  final String url;
  final Duration? startAt;
  const FullscreenPlayerPage({
    super.key,
    required this.url,
    this.startAt,
  });

  @override
  State<FullscreenPlayerPage> createState() => _FullscreenPlayerPageState();
}

class _FullscreenPlayerPageState extends State<FullscreenPlayerPage> {
  late VlcPlayerController _fsController;

  @override
  void initState() {
    super.initState();
    // تفعيل ملء الشاشة + أفقياً فقط
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    WakelockPlus.enable();

    _fsController = VlcPlayerController.network(
      widget.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    // استئناف من نفس الموضع (إن وجد)
    if (widget.startAt != null) {
      // أعطِ VLC لحظة للتهيئة ثم اقفز
      Future.delayed(const Duration(milliseconds: 350), () async {
        try { await _fsController.seekTo(widget.startAt!); } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    // إعادة الوضع الطبيعي
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WakelockPlus.disable();

    try { _fsController.stop(); _fsController.dispose(); } catch (_) {}
    super.dispose();
  }

  Future<bool> _onBack() async {
    Navigator.of(context).pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBack,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (context, box) {
            final screenAR = box.maxWidth / box.maxHeight;
            return SizedBox.expand(
              child: VlcPlayer(
                controller: _fsController,
                aspectRatio: screenAR, // يملأ الشاشة بلا حواف وبلا لفوف إضافية
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            );
          },
        ),
      ),
    );
  }
}
