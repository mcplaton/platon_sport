import 'dart:async';
import 'package:flutter/material.dart';
import 'home_shell.dart'; // ✅ سينتقل لها بعد السبلش

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    // انتقال تلقائي بعد 2.2 ثانية
    Timer(const Duration(milliseconds: 2200), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgTop = Color(0xFF0E1116);
    const bgBottom = Color(0xFF151A22);
    const accent = Color(0xFFE11D48);

    return WillPopScope(
      onWillPop: () async => false, // منع الرجوع أثناء السبلش
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [bgTop, bgBottom],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: const Icon(Icons.play_circle_fill_rounded,
                        color: accent, size: 72),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'PlaToN Sport',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: .2),
                  ),
                  const SizedBox(height: 8),
                  const Text('مرحباً بك في أفلاطون سبورت',
                      style: TextStyle(fontSize: 15, color: Colors.white70)),
                  const SizedBox(height: 4),
                  const Text('عالمك الترفيهي بين يديك',
                      style: TextStyle(fontSize: 13, color: Colors.white54)),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 28, height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
