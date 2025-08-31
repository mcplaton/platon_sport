import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

class MatchItem {
  final String league;
  final String home;
  final String away;
  final String time;   // "HH:mm" أو "جارية"
  final bool isLive;
  final String? channel;
  final String? commentator;

  MatchItem({
    required this.league,
    required this.home,
    required this.away,
    required this.time,
    required this.isLive,
    this.channel,
    this.commentator,
  });

  factory MatchItem.fromJson(Map<String, dynamic> j) => MatchItem(
    league: j['league'] ?? '',
    home: j['home'] ?? '',
    away: j['away'] ?? '',
    time: j['time'] ?? '',
    isLive: j['isLive'] == true,
    channel: j['channel'],
    commentator: j['commentator'],
  );
}

class MatchesService {
  static const String _url = 'https://www.yalla-shoot-365.com/matches/';

  Future<List<MatchItem>> fetch() async {
    try {
      final res = await http.get(Uri.parse(_url), headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Mobile Safari/537.36',
        'Accept-Language': 'ar,en;q=0.8',
      });
      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final doc = html_parser.parse(utf8.decode(res.bodyBytes));

      // التقط مجموعات واسعة من الكروت/الصفوف
      final cards = <Element>[
        ...doc.querySelectorAll(
          '.match, .match-card, .matchItem, .matche, .game, .matches-list .item, .row .match',
        )
      ];

      final out = <MatchItem>[];
      for (final c in cards) {
        final text = _normalize(c.text);

        // الدوري: جرّب داخل الكرت
        String league =
            c.querySelector('.league, .league-title, .league-name, header h3, h3, h4')?.text.trim() ?? '';

        // لو فاضي، ابحث في الآباء (يدويًا بدل closest)
        if (league.isEmpty) {
          Element? parent = c.parent;
          while (parent != null && league.isEmpty) {
            final h = parent.querySelector('h3,h4');
            if (h != null) league = h.text.trim();
            parent = parent.parent;
          }
        }

        // أسماء الفرق
        String home = c.querySelector('.home, .team-home, .teamA, .team1, .team-left')?.text.trim() ?? '';
        String away = c.querySelector('.away, .team-away, .teamB, .team2, .team-right')?.text.trim() ?? '';

        if (home.isEmpty || away.isEmpty) {
          final vs = RegExp(r'([\p{L}\d\s\-_.]{2,})\s+(?:vs|VS|ضد)\s+([\p{L}\d\s\-_.]{2,})', unicode: true)
              .firstMatch(text);
          if (vs != null) {
            home = vs.group(1)!.trim();
            away = vs.group(2)!.trim();
          }
        }
        if (home.isEmpty || away.isEmpty) continue;

        // الوقت/الحالة
        String time = c.querySelector('.time, .match-time, .status, .date')?.text.trim() ?? '';
        bool isLive = false;
        if (time.isEmpty) {
          isLive = RegExp(r'(جارية|live|حي)', caseSensitive: false).hasMatch(text);
          final tm = RegExp(r'(\d{1,2}:\d{2}(?::\d{2})?)').firstMatch(text)?.group(1) ?? '';
          time = isLive ? 'جارية' : (tm.isNotEmpty ? tm : 'اليوم');
        } else {
          isLive = time.contains('جارية') || time.toLowerCase().contains('live');
        }

        final channel = c.querySelector('.channel, .tv, .ch, .chan')?.text.trim();
        final commentator = c.querySelector('.commentator, .comm, .voice')?.text.trim();

        out.add(MatchItem(
          league: league,
          home: home,
          away: away,
          time: time,
          isLive: isLive,
          channel: _nullable(channel),
          commentator: _nullable(commentator),
        ));
      }

      if (out.isEmpty) {
        throw Exception('لم يتم التقاط أي مباراة (قد يكون DOM تغيّر)');
      }
      return out.take(60).toList();
    } catch (e) {
      return [
        MatchItem(league: '—', home: '—', away: '—', time: 'اليوم', isLive: false),
      ];
    }
  }
}

String _normalize(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();
String? _nullable(String? s) {
  if (s == null) return null;
  final t = s.trim();
  return t.isEmpty ? null : t;
}
