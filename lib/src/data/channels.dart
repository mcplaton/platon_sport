class ChannelSource {
  final String url;
  final Map<String, String>? headers;
  const ChannelSource(this.url, {this.headers});
}

class Channel {
  final String name;
  final List<ChannelSource> sources;
  const Channel(this.name, this.sources);
}

// أمثلة قانونية
final List<Channel> channels = [
  Channel('بين سبورت 1', [
    ChannelSource('http://live.lynxiptv.xyz:80/313777735078/nSOXHhjiXE/67742'),
    ChannelSource('http://live.lynxiptv.xyz:80/313777735078/nSOXHhjiXE/196179'),
  ]),
  Channel('قناة مع ترويسات', [
    ChannelSource(
      'http://live.lynxiptv.xyz:80/313777735078/nSOXHhjiXE/67743',
      headers: {
        'Referer': 'https://your-legal-site.example/',
        'User-Agent': 'VLC/3.0.0 LibVLC/3.0.0',
      },
    ),
  ]),
];
