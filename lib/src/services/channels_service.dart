import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelSource {
  final String url;
  final String? quality;
  final Map<String, String>? headers; // اختياري لاحقاً
  ChannelSource({required this.url, this.quality, this.headers});

  factory ChannelSource.fromMap(Map<String, dynamic> m) => ChannelSource(
        url: (m['url'] ?? '').toString(),
        quality: (m['quality'] ?? '').toString(),
      );
}

class Channel {
  final String name;                 // مثال: "BE: BEIN SPORTS 1"
  final List<ChannelSource> sources; // روابط متعددة لنفس القناة
  Channel({required this.name, required this.sources});
}

class ChannelsService {
  final _doc = FirebaseFirestore.instance
      .collection('bein_streams')
      .doc('bein_streams');

  Stream<List<Channel>> watch() => _doc.snapshots().map(_map);
  Future<List<Channel>> fetch() async => _map(await _doc.get());

  List<Channel> _map(DocumentSnapshot snap) {
    if (!snap.exists) return [];
    final map = (snap.get('data') as Map<String, dynamic>? ?? {});
    final out = <Channel>[];
    map.forEach((key, value) {
      final list = (value as List)
          .map((e) => ChannelSource.fromMap(Map<String, dynamic>.from(e)))
          .where((s) => s.url.isNotEmpty)
          .toList();
      if (list.isNotEmpty) out.add(Channel(name: key.toString(), sources: list));
    });
    return out;
  }
}
