import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const TerminalApp());

class TerminalApp extends StatelessWidget {
  const TerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Кассовый терминал',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14161B),
      ),
      home: const HomeScreen(),
    );
  }
}

// ----------------------------------------------------------------- данные --

class TileData {
  final String title;
  final IconData icon;
  final Color color;
  final int span;
  final String? badge;
  const TileData(this.title, this.icon, this.color,
      {this.span = 1, this.badge});
}

const tiles = <TileData>[
  TileData('Продажа', Icons.point_of_sale, Color(0xFF2E9E5B), span: 2),
  TileData('Возврат', Icons.assignment_return, Color(0xFFE08A1E)),
  TileData('Товары', Icons.inventory_2, Color(0xFF2F7DD1)),
  TileData('Отчёты', Icons.bar_chart, Color(0xFF8A4FD0)),
  TileData('Касса', Icons.payments, Color(0xFF16A3A3)),
  TileData('Чеки', Icons.receipt_long, Color(0xFF4A5BD0), span: 2),
  TileData('Сотрудники', Icons.groups, Color(0xFFD0447F)),
  TileData('Скидки', Icons.percent, Color(0xFFD14B3A)),
  TileData('Клиенты', Icons.people_alt, Color(0xFF1C93C4)),
  TileData('Магазин приложений', Icons.apps, Color(0xFF2B3A67),
      span: 2, badge: '3'),
  TileData('Настройки', Icons.settings, Color(0xFF5A6270)),
  TileData('Поддержка', Icons.support_agent, Color(0xFFC79A12)),
];

List<List<TileData>> packRows(List<TileData> items, int cols) {
  final rows = <List<TileData>>[];
  var cur = <TileData>[];
  var used = 0;
  for (final t in items) {
    final s = t.span > cols ? cols : t.span;
    if (used + s > cols) {
      rows.add(cur);
      cur = <TileData>[];
      used = 0;
    }
    cur.add(t);
    used += s;
  }
  if (cur.isNotEmpty) rows.add(cur);
  return rows;
}

String money(double v) => '${v.toStringAsFixed(2).replaceAll('.', ',')} ₽';

// ------------------------------------------------------------ рабочий стол --

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _time =>
      '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';

  static const _months = [
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
  ];

  String get _date => '${_now.day} ${_months[_now.month - 1]}';

  void _open(TileData t) {
    if (t.title == 'Продажа') {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SaleScreen()));
    } else {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('«${t.title}» — раздел в разработке'),
          duration: const Duration(seconds: 1),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth < 600 ? 2 : 4;
          final rows = packRows(tiles, cols);
          return Column(
            children: [
              _topBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Column(
                    children: [
                      for (final row in rows)
                        Expanded(
                          child: Row(
                            children: [
                              for (final t in row)
                                Expanded(
                                  flex: t.span > cols ? cols : t.span,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: TileCard(
                                        data: t, onTap: () => _open(t)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _bottomBar(),
            ],
          );
        }),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1C1F26),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Colors.white70),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Мой магазин',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('Смена №12 открыта',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6FD08C))),
              ],
            ),
          ),
          const Icon(Icons.wifi, size: 20, color: Colors.white70),
          const SizedBox(width: 10),
          const Icon(Icons.battery_5_bar, size: 20, color: Colors.white70),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_time,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              Text(_date,
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF1C1F26),
      child: const Row(
        children: [
          Icon(Icons.person, size: 16, color: Colors.white54),
          SizedBox(width: 6),
          Text('Кассир: Иванов И.',
              style: TextStyle(fontSize: 12, color: Colors.white54)),
          Spacer(),
          Icon(Icons.cloud_done, size: 16, color: Color(0xFF6FD08C)),
          SizedBox(width: 6),
          Text('Синхронизировано',
              style: TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }
}

class TileCard extends StatelessWidget {
  final TileData data;
  final VoidCallback onTap;
  const TileCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: data.color,
      borderRadius: BorderRadius.circular(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(data.icon, size: 34, color: Colors.white),
                  const Spacer(),
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
            if (data.badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5484D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(data.badge!,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ экран продажи --

class Product {
  final String name;
  final double price;
  const Product(this.name, this.price);
}

const products = <Product>[
  Product('Вода 0,5 л', 55),
  Product('Кофе', 150),
  Product('Чай', 90),
  Product('Круассан', 120),
  Product('Сэндвич', 230),
  Product('Шоколад', 99),
  Product('Сок', 110),
  Product('Печенье', 75),
];

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final Map<int, int> cart = {};

  double get total {
    var s = 0.0;
    cart.forEach((i, q) => s += products[i].price * q);
    return s;
  }

  void _add(int i) => setState(() => cart[i] = (cart[i] ?? 0) + 1);

  void _remove(int i) => setState(() {
        final q = (cart[i] ?? 0) - 1;
        if (q <= 0) {
          cart.remove(i);
        } else {
          cart[i] = q;
        }
      });

  void _pay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1F26),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('К оплате: ${money(total)}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            for (final m in const [
              ('Наличные', Icons.payments),
              ('Банковская карта', Icons.credit_card),
              ('СБП / QR-код', Icons.qr_code_2),
            ])
              ListTile(
                leading: Icon(m.$2),
                title: Text(m.$1),
                onTap: () {
                  Navigator.pop(context);
                  _done(m.$1);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _done(String method) {
    final sum = total;
    setState(() => cart.clear());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Color(0xFF6FD08C), size: 48),
        title: const Text('Чек сформирован'),
        content: Text('$method\n${money(sum)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Готово')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E9E5B),
        title: const Text('Продажа'),
        actions: [
          IconButton(
            tooltip: 'Очистить',
            icon: const Icon(Icons.delete_outline),
            onPressed: cart.isEmpty ? null : () => setState(cart.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                final q = cart[i] ?? 0;
                return Material(
                  color: const Color(0xFF2A2F3A),
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () => _add(i),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Row(
                            children: [
                              Text(money(p.price),
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12)),
                              const Spacer(),
                              if (q > 0)
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: const Color(0xFF2E9E5B),
                                  child: Text('$q',
                                      style: const TextStyle(fontSize: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 230,
            color: const Color(0xFF1C1F26),
            child: Column(
              children: [
                Expanded(
                  child: cart.isEmpty
                      ? const Center(
                          child: Text('Добавьте товары из списка',
                              style: TextStyle(color: Colors.white38)))
                      : ListView(
                          children: [
                            for (final e in cart.entries)
                              ListTile(
                                dense: true,
                                title: Text(products[e.key].name),
                                subtitle: Text(
                                    '${e.value} × ${money(products[e.key].price)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(money(products[e.key].price * e.value),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () => _remove(e.key),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E9E5B),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: cart.isEmpty ? null : _pay,
                      child: Text('Оплатить  ${money(total)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
