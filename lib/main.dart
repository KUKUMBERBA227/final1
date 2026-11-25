
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFAAC7FF),
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

const List<BunkerSite> sites = [
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
        backgroundColor: const Color(0xFF111318),
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              height: 43,
              width: 43,
              decoration: BoxDecoration(
                color: const Color(0xFF26364D),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFFAAC7FF),
                size: 26,
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
                    letterSpacing: 1.5,
                    color: Color(0xFFAAC7FF),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Обновить страницу',
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF20242C),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  current.icon,
                  color: const Color(0xFFAAC7FF),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    current.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF81C995),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'WEB',
                  style: TextStyle(
                    color: Color(0xFF81C995),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: List.generate(
                sites.length,
                (index) => BunkerWebView(
                  key: ValueKey(sites[index].url),
                  url: sites[index].url,
                  active: selectedIndex == index,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        height: 78,
        selectedIndex: selectedIndex,
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
  final bool active;

  const BunkerWebView({
    super.key,
    required this.url,
    required this.active,
  });

  @override
  State<BunkerWebView> createState() => _BunkerWebViewState();
}

class _BunkerWebViewState extends State<BunkerWebView> {
  late final WebViewController controller;

  int progress = 0;
  bool loading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF111318))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (!mounted) return;
            setState(() {
              progress = value;
            });
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              loading = true;
              hasError = false;
              progress = 0;
            });
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {
              loading = false;
              progress = 100;
            });
          },
          onWebResourceError: (error) {
         if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              loading = false;
              hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> reloadPage() async {
    setState(() {
      loading = true;
      hasError = false;
    });
    await controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          controller: controller,
        ),

        if (loading)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress / 100,
              minHeight: 3,
              color: const Color(0xFFAAC7FF),
              backgroundColor: const Color(0xFF20242C),
            ),
          ),

        if (hasError)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF111318),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 55,
                        color: Color(0xFFAAC7FF),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Не удалось загрузить сайт',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Проверь подключение к интернету '
                        'и попробуй ещё раз.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: reloadPage,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
