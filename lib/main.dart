
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const BunkerApp());
}

class BunkerApp extends StatelessWidget {
  const BunkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Бункер России',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8AB4F8),
          brightness: Brightness.dark,
          surface: const Color(0xFF111318),
        ),
        scaffoldBackgroundColor: const Color(0xFF111318),
      ),
      home: const BunkerHome(),
    );
  }
}

class BunkerSite {
  final String name;
  final String url;
  final IconData icon;

  const BunkerSite(this.name, this.url, this.icon);
}

const sites = [
  BunkerSite(
    'БПЛА Alert',
    'https://bplaalert.ru/?ysclid=mwwiudy45b811494353',
    Icons.notifications_active_rounded,
  ),
  BunkerSite(
    'Radar Map',
    'https://radar-map.ru/?z=14.89&lon=39.31291&lat=48.55824&bm=openmaptiles_bright',
    Icons.map_rounded,
  ),
  BunkerSite(
    'Детектор АЭРО',
    'https://detector-aero.ru/',
    Icons.radar_rounded,
  ),
  BunkerSite(
    'БПЛА Radar',
    'https://bpla-radar.ft-g.su/',
    Icons.track_changes_rounded,
  ),
  BunkerSite(
    'Радар России',
    'https://radar-russia.ru/?ysclid=mwwiwn80dn376750749',
    Icons.public_rounded,
  ),
  BunkerSite(
    'ГдеЛетит',
    'https://gdeletit.ru/?ysclid=mwwiyjuacw178383603',
    Icons.travel_explore_rounded,
  ),
];

class BunkerHome extends StatefulWidget {
  const BunkerHome({super.key});

  @override
  State<BunkerHome> createState() => _BunkerHomeState();
}

class _BunkerHomeState extends State<BunkerHome> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final current = sites[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xFF26364D),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFFAAC7FF),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Бункер России',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ИНФОРМАЦИОННЫЙ ЦЕНТР',
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.4,
                    color: Color(0xFFAAC7FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Icon(current.icon, color: const Color(0xFFAAC7FF)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    current.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.circle,
                  size: 9,
                  color: Color(0xFF81C995),
                ),
                const SizedBox(width: 6),
                const Text(
                  'WEB',
                  style: TextStyle(
                    color: Color(0xFF81C995),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                for (final site in sites)
                  BunkerWebView(
                    key: ValueKey(site.url),
                    url: site.url,
                  ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        height: 76,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: [
          for (final site in sites)
            NavigationDestination(
              icon: Icon(site.icon),
              selectedIcon: Icon(
                site.icon,
                color: const Color(0xFFAAC7FF),
              ),
              label: site.name,
            ),
        ],
      ),
    );
  }
}

class BunkerWebView extends StatefulWidget {
  final String url;

  const BunkerWebView({
    super.key,
    required this.url,
  });

  @override
  State<BunkerWebView> createState() => _BunkerWebViewState();
}

class _BunkerWebViewState extends State<BunkerWebView> {
  late final WebViewController controller;
  int progress = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111318))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) {
              setState(() {
                progress = value;
                loading = value < 100;
              });
            }
          },
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                loading = true;
                progress = 0;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                loading = false;
                progress = 100;
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: controller),

        if (loading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress / 100,
              minHeight: 3,
              backgroundColor: const Color(0xFF20242C),
              color: const Color(0xFFAAC7FF),
            ),
          ),
      ],
    );
  }
}
