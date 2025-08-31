import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // أنشأه flutterfire configure
import 'src/screens/splash_screen.dart';  

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlatonSportApp());
}

class PlatonSportApp extends StatelessWidget {
  const PlatonSportApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF181C24);
    return MaterialApp(
      title: 'PlaToN Sport',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: seed,
        scaffoldBackgroundColor: const Color(0xFF0E1116),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const SplashScreen(), // ✅ هذه أهم نقطة
    );
  }
}
