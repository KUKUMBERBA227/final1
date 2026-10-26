import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const InfinityBankApp());
}

class InfinityBankApp extends StatelessWidget {
  const InfinityBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFCCFF00),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFCCFF00),
          secondary: Color(0xFFB3E600),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _balance = 125400.50;
  double _cashback = 3450.00;

  final List<Map<String, dynamic>> _history = [
    {
      'title': 'Супермаркет',
      'amount': -1450.0,
      'date': 'Сегодня',
      'icon': Icons.shopping_bag
    },
    {
      'title': 'Пополнение',
      'amount': 5000.0,
      'date': 'Вчера',
      'icon': Icons.add_circle
    },
    {
      'title': 'Кэшбек за месяц',
      'amount': 850.0,
      'date': '24 Окт',
      'icon': Icons.all_inclusive
    },
  ];

  void _depositMoney(double amount) {
    setState(() {
      _balance += amount;
      _cashback += amount * 0.01;
      _history.insert(0, {
        'title': 'Пополнение',
        'amount': amount,
        'date': 'Только что',
        'icon': Icons.add_circle,
      });
    });
  }

  void _makeTransfer(double amount, String recipient) {
    if (_balance >= amount) {
      setState(() {
        _balance -= amount;
        _history.insert(0, {
          'title': 'Перевод ($recipient)',
          'amount': -amount,
          'date': 'Только что',
          'icon': Icons.send,
        });
      });
    }
  }

  void _payService(double amount, String title) {
    if (_balance >= amount) {
      setState(() {
        _balance -= amount;
        double cb = amount * 0.03;
        _cashback += cb;
        _history.insert(0, {
          'title': title,
          'amount': -amount,
          'date': 'Только что',
          'icon': Icons.payment,
        });
      });
    }
  }

  void _payVzhuh(double amount) {
    if (_balance >= amount) {
      setState(() {
        _balance -= amount;
        double cb = amount * 0.05;
        _cashback += cb;
        _history.insert(0, {
          'title': 'Оплата Вжух ⚡',
          'amount': -amount,
          'date': 'Только что',
          'icon': Icons.flash_on,
        });
      });
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFCCFF00),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.black, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDepositDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Пополнение', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Сумма (₽)',
            labelStyle: TextStyle(color: Color(0xFFCCFF00)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFCCFF00)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCFF00),
            ),
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null && val > 0) {
                _depositMoney(val);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Пополнить', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    final amountController = TextEditingController();
    final recipientController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Перевод средств', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: recipientController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Получатель (Имя/Карта)',
                labelStyle: TextStyle(color: Color(0xFFCCFF00)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCFF00)),
                ),
              ),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Сумма (₽)',
                labelStyle: TextStyle(color: Color(0xFFCCFF00)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCFF00)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCFF00),
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final name = recipientController.text;
              if (amount != null && amount > 0 && name.isNotEmpty) {
                _makeTransfer(amount, name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Отправить', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showPayDialog(BuildContext context) {
    final amountController = TextEditingController();
    final serviceController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Оплата услуг (+3% Кэшбек)',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: serviceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Услуга (Мобильная связь, ЖКХ и т.д.)',
                labelStyle: TextStyle(color: Color(0xFFCCFF00)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCFF00)),
                ),
              ),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Сумма (₽)',
                labelStyle: TextStyle(color: Color(0xFFCCFF00)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCFF00)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCFF00),
            ),
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              final service = serviceController.text;
              if (amount != null && amount > 0 && service.isNotEmpty) {
                _payService(amount, service);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Оплатить', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showVzhuhInputScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VzhuhInputScreen(
          onConfirm: (amount) {
            _payVzhuh(amount);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.all_inclusive, color: Color(0xFFCCFF00), size: 36),
            SizedBox(width: 8),
            Text(
              'INFINITY BANK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFFCCFF00)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Карта баланса
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCCFF00), Color(0xFF88B300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCCFF00).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Главный счёт',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.all_inclusive, color: Colors.black, size: 28),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_balance.toStringAsFixed(2)} ₽',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '**** 8888',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'INFINITY CARD',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Блок Кэшбека
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFCCFF00).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFF00).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Color(0xFFCCFF00),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Накопленный Кэшбэк',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      Text(
                        '${_cashback.toStringAsFixed(2)} ₽',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Действия
            const Text(
              'Действия',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.add,
                  label: 'Пополнить',
                  onTap: () => _showDepositDialog(context),
                ),
                _buildActionButton(
                  icon: Icons.send,
                  label: 'Перевести',
                  onTap: () => _showTransferDialog(context),
                ),
                _buildActionButton(
                  icon: Icons.flash_on,
                  label: 'Вжух',
                  onTap: () => _showVzhuhInputScreen(context),
                ),
                _buildActionButton(
                  icon: Icons.receipt_long,
                  label: 'Оплатить',
                  onTap: () => _showPayDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // История операций
            const Text(
              'История операций',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final isPositive = item['amount'] > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          const Color(0xFFCCFF00).withOpacity(0.15),
                      child: Icon(item['icon'], color: const Color(0xFFCCFF00)),
                    ),
                    title: Text(item['title'],
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(item['date'],
                        style: const TextStyle(color: Colors.grey)),
                    trailing: Text(
                      '${isPositive ? "+" : ""}${item['amount']} ₽',
                      style: TextStyle(
                        color: isPositive
                            ? const Color(0xFFCCFF00)
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Страница ввода суммы Вжух
class VzhuhInputScreen extends StatefulWidget {
  final Function(double) onConfirm;

  const VzhuhInputScreen({super.key, required this.onConfirm});

  @override
  State<VzhuhInputScreen> createState() => _VzhuhInputScreenState();
}

class _VzhuhInputScreenState extends State<VzhuhInputScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Оплата Вжух', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Color(0xFFCCFF00)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Мгновенный платёж по технологии Вжух',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(
                labelText: 'Введите сумму (₽)',
                labelStyle: TextStyle(color: Color(0xFFCCFF00)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCFF00)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFCCFF00), width: 2),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCCFF00),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final amount = double.tryParse(_controller.text);
                if (amount != null && amount > 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VzhuhAnimationScreen(
                        amount: amount,
                        onFinished: () {
                          widget.onConfirm(amount);
                        },
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'Вжух! Оплатить',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Страница анимации (только чистые потоки и шлейф)
class VzhuhAnimationScreen extends StatefulWidget {
  final double amount;
  final VoidCallback onFinished;

  const VzhuhAnimationScreen({
    super.key,
    required this.amount,
    required this.onFinished,
  });

  @override
  State<VzhuhAnimationScreen> createState() => _VzhuhAnimationScreenState();
}

class _VzhuhAnimationScreenState extends State<VzhuhAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Вжух! Успешно оплачено ${widget.amount} ₽'),
            backgroundColor: const Color(0xFFCCFF00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              CustomPaint(
                size: MediaQuery.of(context).size,
                painter: MatrixVzhuhPainter(progress: _controller.value),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCCFF00).withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCCFF00).withOpacity(0.2),
                        blurRadius: 20,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.flash_on,
                        color: Color(0xFFCCFF00),
                        size: 54,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ВЖУХ...',
                        style: TextStyle(
                          color: Color(0xFFCCFF00),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.amount.toStringAsFixed(2)} ₽',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Рендерер только для динамических линий/шлейфов
class MatrixVzhuhPainter extends CustomPainter {
  final double progress;
  MatrixVzhuhPainter({required this.progress});

  final Random _random = Random(1337);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;

    // Падающие цифровые потоки со шлейфом
    for (int i = 0; i < 40; i++) {
      double x = (_random.nextDouble() * size.width);
      double speed = 200 + _random.nextDouble() * 400;
      double startY = -100 - _random.nextDouble() * 300;
      double currentY = startY + (progress * (size.height + 400) * (speed / 300)) % (size.height + 300);

      for (int j = 0; j < 8; j++) {
        double trailY = currentY - (j * 18.0);
        if (trailY < 0 || trailY > size.height) continue;

        double opacity = (1.0 - (j * 0.12)).clamp(0.0, 1.0);
        paint.color = const Color(0xFFCCFF00).withOpacity(opacity * 0.7);
        paint.strokeWidth = 2.5;

        canvas.drawCircle(Offset(x, trailY), paint.strokeWidth, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MatrixVzhuhPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
