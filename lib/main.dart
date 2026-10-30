import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const LiquidGlassRadarApp());
}

class RadarPageModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  final List> _tabs = const [
    {
      'title': 'Detector',
      'icon': Icons.radar_rounded,
      'url': 'https://detector-aero.ru/',
    },
    {
      'title': 'Radar',
      'icon': Icons.map_outlined,
      'url': 'https://radar-map.ru/',
    },
  ];

  List get tabs => _tabs;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}

class LiquidGlassRadarApp extends StatelessWidget {
  const LiquidGlassRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aero Radar Glass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: ChangeNotifierProvider<RadarPageModel>(
        create: (_) => RadarPageModel(),
        builder: (context, _) => const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<RadarPageModel>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: model.currentIndex,
            children: model.tabs.map<Widget>((tabItem) {
              final tab = tabItem as Map<String, dynamic>;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tab['icon'] as IconData, size: 64, color: const Color(0xFF69F0AE)),
                      const SizedBox(height: 20),
                      Text(
                        'External Source: ${tab['title']}',
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        label: const Text('Open in Browser'),
                        onPressed: () async {
                          final uri = Uri.parse(tab['url'] as String);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF69F0AE).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: model.tabs.asMap().entries.map<Widget>((entry) {
                        int idx = entry.key;
                        final val = entry.value as Map<String, dynamic>;
                        return TabButton(
                          title: val['title'] as String,
                          icon: val['icon'] as IconData,
                          isSelected: model.currentIndex == idx,
                          onTap: () => model.setIndex(idx),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF69F0AE).withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF69F0AE) : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
