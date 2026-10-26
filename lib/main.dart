import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MotoLuxApp());
}

class MotoLuxApp extends StatelessWidget {
  const MotoLuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Мото-Люкс App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFE53935),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935),
          secondary: Colors.amber,
        ),
      ),
      home: const MotoLuxHomeScreen(),
    );
  }
}

class MotoLuxHomeScreen extends StatefulWidget {
  const MotoLuxHomeScreen({super.key});

  @override
  State<MotoLuxHomeScreen> createState() => _MotoLuxHomeScreenState();
}

class _MotoLuxHomeScreenState extends State<MotoLuxHomeScreen> {
  final Uri _websiteUri = Uri.parse('https://мото-люкс.рф/');

  Future<void> _launchWebsite() async {
    if (await canLaunchUrl(_websiteUri)) {
      await launchUrl(_websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.two_wheeler, color: Colors.redAccent),
            SizedBox(width: 10),
            Text('Мото-Люкс', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.amber.shade900.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Перейдите на официальный сайт (Мото-люкс.рф) для просмотра актуальных предложений.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.web, size: 64, color: Colors.white24),
                    const SizedBox(height: 20),
                    const Text(
                      'Мото-Люкс',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _launchWebsite,
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Открыть сайт'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
