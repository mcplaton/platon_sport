import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart' as fo;
import 'src/screens/splash_screen.dart';

Future<void> _initFirebaseSafely() async {
  if (Firebase.apps.isNotEmpty) return;
  try {
    if (Platform.isIOS) {
      // أحيانًا يفشل إن لم يجد plist وقت الإقلاع.
      await Future.delayed(const Duration(milliseconds: 200));
    }
    try {
      await Firebase.initializeApp(options: fo.DefaultFirebaseOptions.currentPlatform);
    } catch (_) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    // لا توقف التطبيق؛ فقط اطبع الخطأ.
    debugPrint('Firebase init error: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebaseSafely();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runZonedGuarded(() {
    runApp(const PlatonSportApp());
  }, (e, st) {
    // لو حدث استثناء مزمن في أول الإقلاع سنراه على الشاشة
    runApp(MaterialApp(home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Text('Startup error:\n$e', textAlign: TextAlign.center)),
    )));
  });
}

class PlatonSportApp extends StatelessWidget {
  const PlatonSportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlaToN Sport',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF181C24),
        scaffoldBackgroundColor: const Color(0xFF0E1116),
        appBarTheme: const AppBarTheme(centerTitle: true, backgroundColor: Color(0xFF181C24)),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const SplashScreen(),
    );
  }
}
