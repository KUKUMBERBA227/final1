
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

void main() {
  runApp(const BunkerApp());
}

class BunkerApp extends StatelessWidget {
  const BunkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF8AB4F8);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Бункер России',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: const Color(0xFF111318),
        ),
        scaffoldBackgroundColor: const Color(0xFF111318),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111318),
          centerTitle: false,
        ),
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
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF26364D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: Color(0xFFAAC7FF),
                size: 25,
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
                    fontWeight: FontWeight.w700,
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
        actions: [
          IconButton(
            tooltip: 'Открыть в браузере',
            onPressed: () {
              html.window.open(current.url, '_blank');
            },
            icon: const Icon(Icons.open_in_new_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // Информация о выбранном разделе
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                Icon(
                  current.icon,
                  color: const Color(0xFFAAC7FF),
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    current.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B332B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: Color(0xFF81C995),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ОНЛАЙН',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF81C995),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Окно сайта
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                for (final site in sites)
                  WebSiteView(
                    key: ValueKey(site.url),
                    url: site.url,
                  ),
              ],
            ),
          ),
        ],
      ),

      // Нижняя панель переключения сайтов
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        height: 78,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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

// Отображение сайтов внутри приложения
class WebSiteView extends StatefulWidget {
  final String url;

  const WebSiteView({
    super.key,
    required this.url,
  });

  @override
  State<WebSiteView> createState() => _WebSiteViewState();
}

class _WebSiteViewState extends State<WebSiteView> {
  static int nextId = 0;

  late final String viewType;
  late final html.IFrameElement iframe;

  @override
  void initState() {
    super.initState();

    viewType = 'bunker-frame-${nextId++}';

    iframe = html.IFrameElement()
      ..src = widget.url
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true
      ..referrerPolicy = 'no-referrer-when-downgrade';

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(18),
      ),
      child: HtmlElementView(
        viewType: viewType,
      ),
    );
  }
}
