import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const OrbitApp());

// ============================================================ состояние ====

enum Conn { off, connecting, on }

class Server {
  final String city;
  final String code;
  int ping;
  Server(this.city, this.code, this.ping);
}

class Subscription {
  final String name;
  final String url;
  final List<Server> servers;
  bool expanded = true;
  Subscription(this.name, this.url, this.servers);

  String get host {
    final h = Uri.tryParse(url)?.host ?? '';
    return h.isEmpty ? url : h;
  }
}

const _cities = [
  ('Франкфурт', 'DE'),
  ('Амстердам', 'NL'),
  ('Хельсинки', 'FI'),
  ('Стамбул', 'TR'),
  ('Варшава', 'PL'),
  ('Париж', 'FR'),
  ('Вена', 'AT'),
  ('Стокгольм', 'SE'),
];

const protocolNames = ['Авто', 'WireGuard', 'Xray'];

const seedColors = [
  Color(0xFF3B6EF5),
  Color(0xFF00897B),
  Color(0xFF7C4DFF),
  Color(0xFFE8506A),
  Color(0xFFF59E0B),
];

class AppState extends ChangeNotifier {
  final _rnd = Random();

  Conn conn = Conn.off;
  Server? selected;
  final List<Subscription> subs = [];
  Duration elapsed = Duration.zero;
  double down = 0;
  double up = 0;
  Timer? _timer;

  bool killSwitch = true;
  bool autoConnect = false;
  bool splitTunnel = false;
  int protocol = 0;
  ThemeMode themeMode = ThemeMode.system;
  Color seed = seedColors.first;

  AppState() {
    final demo = Subscription(
      'Демо-подписка',
      'https://example.com/sub/demo',
      _makeServers(),
    );
    subs.add(demo);
    selected = demo.servers.first;
  }

  List<Server> _makeServers() {
    final list = List.of(_cities)..shuffle(_rnd);
    return [
      for (final c in list.take(4 + _rnd.nextInt(3)))
        Server(c.$1, c.$2, 20 + _rnd.nextInt(160)),
    ];
  }

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  Future<void> connect() async {
    if (conn != Conn.off) return;
    if (selected == null) {
      final all = subs.expand((s) => s.servers).toList();
      if (all.isEmpty) return;
      selected = all.first;
    }
    conn = Conn.connecting;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (conn != Conn.connecting) return;
    conn = Conn.on;
    elapsed = Duration.zero;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      down = down * 0.5 + (5 + _rnd.nextDouble() * 80) * 0.5;
      up = up * 0.5 + (1 + _rnd.nextDouble() * 25) * 0.5;
      notifyListeners();
    });
    notifyListeners();
  }

  void disconnect() {
    _timer?.cancel();
    conn = Conn.off;
    down = 0;
    up = 0;
    notifyListeners();
  }

  void select(Server s) {
    selected = s;
    if (conn == Conn.on) {
      disconnect();
      connect();
    } else {
      notifyListeners();
    }
  }

  Future<void> addSubscription(String name, String url) async {
    await Future.delayed(const Duration(milliseconds: 1400));
    subs.add(Subscription(name, url, _makeServers()));
    notifyListeners();
  }

  void removeSubscription(Subscription s) {
    if (selected != null && s.servers.contains(selected)) {
      selected = null;
      if (conn != Conn.off) disconnect();
    }
    subs.remove(s);
    notifyListeners();
  }

  void refreshPing(Subscription s) {
    for (final srv in s.servers) {
      srv.ping = 20 + _rnd.nextInt(160);
    }
    notifyListeners();
  }

  void toggle(Subscription s) {
    s.expanded = !s.expanded;
    notifyListeners();
  }
}

final app = AppState();

String fmt(Duration d) {
  String t(int n) => n.toString().padLeft(2, '0');
  return '${t(d.inHours)}:${t(d.inMinutes % 60)}:${t(d.inSeconds % 60)}';
}

// ================================================================ приложение ==

class OrbitApp extends StatelessWidget {
  const OrbitApp({super.key});

  ThemeData _theme(Brightness b) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: app.seed, brightness: b),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Orbit',
        themeMode: app.themeMode,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(onOpenServers: () => setState(() => index = 1)),
      const ServersPage(),
      const SettingsPage(),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.dns_outlined),
            selectedIcon: Icon(Icons.dns),
            label: 'Серверы',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

// ==================================================================== главная ==

class HomePage extends StatefulWidget {
  final VoidCallback onOpenServers;
  const HomePage({super.key, required this.onOpenServers});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    if (app.conn == Conn.off) {
      app.connect();
    } else {
      app.disconnect();
    }
  }

  Widget _connectButton(ColorScheme cs) {
    final on = app.conn == Conn.on;
    final busy = app.conn == Conn.connecting;
    final bg = on
        ? cs.primary
        : busy
        ? cs.tertiaryContainer
        : cs.secondaryContainer;
    final fg = on
        ? cs.onPrimary
        : busy
        ? cs.onTertiaryContainer
        : cs.onSecondaryContainer;
    final radius = BorderRadius.circular(on ? 95 : 64);

    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final k in const [0.0, 0.5])
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: (on || busy) ? 1 : 0,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final t = (_ctrl.value + k) % 1;
                  return Opacity(
                    opacity: (1 - t) * 0.30,
                    child: Transform.scale(
                      scale: 1 + 0.45 * t,
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubicEmphasized,
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: on ? 0.35 : 0),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: radius,
                onTap: _toggle,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: busy
                        ? SizedBox(
                            key: const ValueKey('busy'),
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              color: fg,
                            ),
                          )
                        : Icon(
                            Icons.power_settings_new_rounded,
                            key: ValueKey(on),
                            size: 84,
                            color: fg,
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

  Widget _stat(
    ColorScheme cs,
    TextTheme tt,
    IconData icon,
    String label,
    double value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: tt.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(end: value),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, v, __) => Text.rich(
                TextSpan(
                  text: v.toStringAsFixed(1).replaceAll('.', ','),
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  children: [TextSpan(text: ' Мбит/с', style: tt.bodySmall)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final on = app.conn == Conn.on;
        final busy = app.conn == Conn.connecting;
        final title = on
            ? 'Защищено'
            : busy
            ? 'Подключение…'
            : 'Не защищено';
        final subtitle = on
            ? fmt(app.elapsed)
            : busy
            ? 'Устанавливаем туннель'
            : 'Нажмите, чтобы подключиться';
        final s = app.selected;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -140,
              left: -40,
              right: -40,
              child: IgnorePointer(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: on ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (_, v, __) => Container(
                    height: 460,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          cs.primary.withValues(alpha: 0.08 + 0.22 * v),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.public,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Orbit',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.bolt, size: 16, color: cs.primary),
                              const SizedBox(width: 4),
                              Text(
                                protocolNames[app.protocol],
                                style: tt.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: Text(
                        title,
                        key: ValueKey(title),
                        style: tt.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        subtitle,
                        key: ValueKey(on ? 'time' : subtitle),
                        style: tt.titleMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _connectButton(cs),
                    const SizedBox(height: 24),
                    Material(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: widget.onOpenServers,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CodeBadge(code: s?.code ?? '--'),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s?.city ?? 'Сервер не выбран',
                                      style: tt.titleMedium,
                                    ),
                                    Text(
                                      s == null
                                          ? 'Откройте список серверов'
                                          : '${s.ping} мс',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.swap_horiz,
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: on
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Row(
                                children: [
                                  _stat(
                                    cs,
                                    tt,
                                    Icons.arrow_downward,
                                    'Загрузка',
                                    app.down,
                                  ),
                                  const SizedBox(width: 12),
                                  _stat(
                                    cs,
                                    tt,
                                    Icons.arrow_upward,
                                    'Отдача',
                                    app.up,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CodeBadge extends StatelessWidget {
  final String code;
  const CodeBadge({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cs.onTertiaryContainer,
        ),
      ),
    );
  }
}

// ==================================================================== серверы ==

class ServersPage extends StatelessWidget {
  const ServersPage({super.key});

  void _add(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddSubSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context),
        icon: const Icon(Icons.add_link),
        label: const Text('Подписка'),
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final cs = Theme.of(context).colorScheme;
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Серверы')),
              if (app.subs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Подписок пока нет',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Добавьте ссылку стороннего сервиса',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SubCard(sub: app.subs[i]),
                    childCount: app.subs.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
    );
  }
}

class SubCard extends StatelessWidget {
  final Subscription sub;
  const SubCard({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainer,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          InkWell(
            onTap: () => app.toggle(sub),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.cloud_outlined,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sub.name, style: tt.titleMedium),
                        Text(
                          '${sub.host} · ${sub.servers.length} серв.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'r') {
                        app.refreshPing(sub);
                      } else {
                        app.removeSubscription(sub);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'r', child: Text('Обновить пинг')),
                      PopupMenuItem(value: 'd', child: Text('Удалить')),
                    ],
                  ),
                  AnimatedRotation(
                    turns: sub.expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.expand_more),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: sub.expanded
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      children: [
                        for (final s in sub.servers) ServerTile(server: s),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class ServerTile extends StatelessWidget {
  final Server server;
  const ServerTile({super.key, required this.server});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sel = identical(app.selected, server);
    final pingColor = server.ping < 60
        ? cs.tertiary
        : server.ping > 120
        ? cs.error
        : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: sel ? cs.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => app.select(server),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CodeBadge(code: server.code),
                  const SizedBox(width: 14),
                  Expanded(child: Text(server.city, style: tt.bodyLarge)),
                  Text(
                    '${server.ping} мс',
                    style: tt.labelLarge?.copyWith(color: pingColor),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) =>
                        ScaleTransition(scale: a, child: c),
                    child: sel
                        ? Padding(
                            key: const ValueKey('on'),
                            padding: const EdgeInsets.only(left: 10),
                            child: Icon(
                              Icons.check_circle,
                              color: cs.primary,
                              size: 22,
                            ),
                          )
                        : const SizedBox(key: ValueKey('off'), width: 32),
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

InputDecoration _dec(String label, {String? hint, Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
  );
}

class AddSubSheet extends StatefulWidget {
  const AddSubSheet({super.key});

  @override
  State<AddSubSheet> createState() => _AddSubSheetState();
}

class _AddSubSheetState extends State<AddSubSheet> {
  final _name = TextEditingController();
  final _url = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    try {
      final d = await Clipboard.getData(Clipboard.kTextPlain);
      if (d?.text != null) setState(() => _url.text = d!.text!.trim());
    } catch (_) {}
  }

  Future<void> _submit() async {
    final url = _url.text.trim();
    if (url.isEmpty) return;
    final sm = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    var name = _name.text.trim();
    if (name.isEmpty) name = Uri.tryParse(url)?.host ?? '';
    if (name.isEmpty) name = 'Подписка';
    setState(() => _busy = true);
    await app.addSubscription(name, url);
    nav.pop();
    sm.showSnackBar(
      SnackBar(
        content: Text('Добавлено: $name'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Новая подписка', style: tt.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Вставьте ссылку из стороннего сервиса. Серверы подгрузятся автоматически.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          TextField(controller: _name, decoration: _dec('Название')),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            decoration: _dec(
              'Ссылка на подписку',
              hint: 'https://…',
              suffix: IconButton(
                icon: const Icon(Icons.content_paste),
                onPressed: _paste,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _busy
                    ? const SizedBox(
                        key: ValueKey('p'),
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Text('Импортировать', key: ValueKey('t')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================== настройки ==

class Group extends StatelessWidget {
  final List<Widget> children;
  const Group({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(children: children),
    );
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  const IconBubble(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, size: 22, color: cs.onPrimaryContainer),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final cs = Theme.of(context).colorScheme;
          final tt = Theme.of(context).textTheme;
          return CustomScrollView(
            slivers: [
              const SliverAppBar.large(title: Text('Настройки')),
              SliverList(
                delegate: SliverChildListDelegate([
                  Group(
                    children: [
                      SwitchListTile(
                        secondary: const IconBubble(Icons.block),
                        title: const Text('Kill Switch'),
                        subtitle: const Text('Блокировать трафик без VPN'),
                        value: app.killSwitch,
                        onChanged: (v) => app.update(() => app.killSwitch = v),
                      ),
                      SwitchListTile(
                        secondary: const IconBubble(Icons.autorenew),
                        title: const Text('Автоподключение'),
                        subtitle: const Text('При запуске приложения'),
                        value: app.autoConnect,
                        onChanged: (v) => app.update(() => app.autoConnect = v),
                      ),
                      SwitchListTile(
                        secondary: const IconBubble(Icons.call_split),
                        title: const Text('Раздельное туннелирование'),
                        subtitle: const Text('Выбор приложений для VPN'),
                        value: app.splitTunnel,
                        onChanged: (v) => app.update(() => app.splitTunnel = v),
                      ),
                    ],
                  ),
                  Group(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconBubble(Icons.route),
                                const SizedBox(width: 16),
                                Text('Протокол', style: tt.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<int>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment<int>(
                                    value: 0,
                                    label: Text('Авто'),
                                  ),
                                  ButtonSegment<int>(
                                    value: 1,
                                    label: Text('WireGuard'),
                                  ),
                                  ButtonSegment<int>(
                                    value: 2,
                                    label: Text('Xray'),
                                  ),
                                ],
                                selected: {app.protocol},
                                onSelectionChanged: (s) =>
                                    app.update(() => app.protocol = s.first),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Group(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IconBubble(Icons.palette_outlined),
                                const SizedBox(width: 16),
                                Text('Оформление', style: tt.titleMedium),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<ThemeMode>(
                                showSelectedIcon: false,
                                segments: const [
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.system,
                                    label: Text('Авто'),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.light,
                                    label: Text('Светлая'),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.dark,
                                    label: Text('Тёмная'),
                                  ),
                                ],
                                selected: {app.themeMode},
                                onSelectionChanged: (s) =>
                                    app.update(() => app.themeMode = s.first),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Цвет акцента',
                              style: tt.labelLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              children: [
                                for (final c in seedColors)
                                  GestureDetector(
                                    onTap: () => app.update(() => app.seed = c),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: c,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: app.seed == c
                                              ? cs.onSurface
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        transitionBuilder: (w, a) =>
                                            ScaleTransition(scale: a, child: w),
                                        child: app.seed == c
                                            ? const Icon(
                                                Icons.check,
                                                key: ValueKey('c'),
                                                color: Colors.white,
                                              )
                                            : const SizedBox(
                                                key: ValueKey('n'),
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Group(
                    children: [
                      ListTile(
                        leading: IconBubble(Icons.info_outline),
                        title: Text('Orbit'),
                        subtitle: Text('Демо-версия 1.0 · Material 3'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}
