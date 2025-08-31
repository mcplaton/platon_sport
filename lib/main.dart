import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // أنشأه flutterfire configure
import 'src/screens/splash_screen.dart';

Future<void> _ensureFirebase() async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // fallback إذا لم يتم توليد firebase_options.dart
      await Firebase.initializeApp();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureFirebase();

  // تفعيل وضع الحواف الطبيعية (EdgeToEdge) بدون مشاكل في الارتفاع
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const PlatonSportApp());
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
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF181C24),
        ),
      ),
      // ✅ التعريب
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
