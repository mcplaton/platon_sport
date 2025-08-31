import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 64),
            const SizedBox(height: 12),
            const Text('تواصل مع المطوّر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('PlaToN Tv — للدعم والاشتراك في النسخة الكاملة', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => _open('https://t.me/PlatonTv_bot'),
                  icon: const Icon(Icons.telegram),
                  label: const Text('تيليجرام'),
                ),
                FilledButton.icon(
                  onPressed: () => _open('https://www.instagram.com/6rrx'),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('إنستقرام'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('لا يمكن فتح $url');
    }
  }
}
