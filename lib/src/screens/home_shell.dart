import 'package:flutter/material.dart';

import 'package:platon_sport/src/screens/matches_webview.dart';
import 'package:platon_sport/src/screens/channels_screen.dart';
import 'package:platon_sport/src/screens/cinema_screen.dart';
import 'package:platon_sport/src/screens/subscription_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    MatchesWebView(),   // المباريات (ويب فيو)
    ChannelsScreen(),   // القنوات
    CinemaScreen(),     // السينما
    SubscriptionScreen(),  // الاشتراك
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'مباريات'),
          NavigationDestination(icon: Icon(Icons.live_tv),        label: 'قنوات'),
          NavigationDestination(icon: Icon(Icons.movie),          label: 'سينما'),
          NavigationDestination(icon: Icon(Icons.verified_user_outlined),  selectedIcon: Icon(Icons.verified_user),  label: 'اشتراك'),
        ],
      ),
    );
  }
}
