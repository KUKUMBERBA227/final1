import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<PaymentData>(create: (_) => PaymentData()),
        ChangeNotifierProvider<ThemeDataNotifier>(create: (_) => ThemeDataNotifier()),
      ],
      builder: (context, _) => const SberTerminalApp(),
    ),
  );
}

class ThemeDataNotifier extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class PaymentData extends ChangeNotifier {
  double _enteredAmount = 1500.0;
  int _selectedTip = 0;
  String _selectedMethod = 'Карта';

  final List<int> tipOptions = [0, 100, 300, 500];
  final List<String> methods = ['Карта', 'Улыбка', 'QR', 'Вжух'];

  double get enteredAmount => _enteredAmount;
  int get selectedTip => _selectedTip;
  String get selectedMethod => _selectedMethod;
  double get total => _enteredAmount + _selectedTip;

  void updateAmount(double amount) {
    _enteredAmount = amount;
    notifyListeners();
  }

  void updateTip(int tip) {
    _selectedTip = tip;
    notifyListeners();
  }

  void updateMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  bool attemptPayment() {
    final random = Random();
    return random.nextDouble() > 0.25;
  }

  bool attemptQrGeneration() {
    final random = Random();
    return random.nextDouble() > 0.17;
  }

  bool needsBluetooth() {
    return Random().nextDouble() < 0.20;
  }

  bool attemptFaceRecognition() {
    return Random().nextDouble() > 0.20;
  }
}

class InfinityLogo extends StatelessWidget {
  const InfinityLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Icon(Icons.all_inclusive, color: primaryColor, size: 28),
        const SizedBox(width: 8),
        Text(
          'infinity Bank',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class SberTerminalApp extends StatelessWidget {
  const SberTerminalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeDataNotifier>(context);
    final isDark = themeNotifier.isDark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark
          ? ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0A0D18),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFE5FF44),
                surface: Color(0xFF161A29),
              ),
            )
          : ThemeData.light().copyWith(
              scaffoldBackgroundColor: const Color(0xFFF0F2F5),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF247BFF),
                surface: Colors.white,
              ),
            ),
      home: const TerminalScreen(),
    );
  }
}

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1500');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _navigateToPayment(BuildContext context) {
    final data = Provider.of<PaymentData>(context, listen: false);
    final input = double.tryParse(_amountController.text) ?? 0.0;
    data.updateAmount(input);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PaymentSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeDataNotifier>(context);
    final isDark = themeNotifier.isDark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: InfinityLogo(),
        ),
        actions: [
          IconButton(
            onPressed: () => themeNotifier.toggleTheme(),
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Введите сумму', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(border: InputBorder.none, suffixText: '₽'),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => _navigateToPayment(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('ДАЛЕЕ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaymentSelectionScreen extends StatelessWidget {
  const PaymentSelectionScreen({super.key});

  void _handlePayment(BuildContext context) {
    final data = Provider.of<PaymentData>(context, listen: false);
    
    if (data.selectedMethod == 'QR') {
      if (!data.attemptQrGeneration()) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const QRErrorScreen()));
        return;
      }
    }

    if (data.selectedMethod == 'Улыбка') {
      if (!data.attemptFaceRecognition()) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceUnrecognizedScreen()));
        return;
      }
    }

    if (data.selectedMethod == 'Вжух' && data.needsBluetooth()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const BluetoothRequiredScreen()));
      return;
    }

    if (data.attemptPayment()) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FailureScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeDataNotifier>(context).isDark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const InfinityLogo(),
      ),
      body: Consumer<PaymentData>(
        builder: (context, data, _) => Center(
          child: SingleChildScrollView(
            child: Container(
              width: 400,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(48),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('К оплате', style: TextStyle(fontSize: 16)),
                  Text('${data.total.toInt()} ₽', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 32),
                  TipSelector(data: data),
                  const SizedBox(height: 32),
                  const Align(alignment: Alignment.centerLeft, child: Text('Способ оплаты')),
                  const SizedBox(height: 12),
                  MethodSelector(data: data),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => _handlePayment(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('ОПЛАТИТЬ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
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

class TipSelector extends StatelessWidget {
  final PaymentData data;
  const TipSelector({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeDataNotifier>(context).isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Чаевые'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: data.tipOptions.map<Widget>((tip) {
            final isSelected = data.selectedTip == tip;
            return ChoiceChip(
              label: Text(tip == 0 ? 'Без чаевых' : '$tip ₽'),
              selected: isSelected,
              onSelected: (_) => data.updateTip(tip),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              labelStyle: TextStyle(color: isSelected ? (isDark ? Colors.black : Colors.white) : null),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class MethodSelector extends StatelessWidget {
  final PaymentData data;
  const MethodSelector({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: data.methods.map<Widget>((method) {
        final isSelected = data.selectedMethod == method;
        return Expanded(
          child: GestureDetector(
            onTap: () => data.updateMethod(method),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: Text(method, style: const TextStyle(fontWeight: FontWeight.w500))),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class QRErrorScreen extends StatelessWidget {
  const QRErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code, color: Colors.orange, size: 80),
            const SizedBox(height: 32),
            const Text('Ошибка генерации QR кода', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceUnrecognizedScreen extends StatelessWidget {
  const FaceUnrecognizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.face_retouching_off, color: Colors.purple, size: 80),
            const SizedBox(height: 32),
            const Text('Мы вас не узнали', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}

class BluetoothRequiredScreen extends StatelessWidget {
  const BluetoothRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled, color: Colors.blueAccent, size: 80),
            const SizedBox(height: 32),
            const Text('Для оплаты требуется включить Bluetooth', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.check, color: Theme.of(context).colorScheme.primary, size: 80)),
            const SizedBox(height: 32),
            const Text('Оплата прошла успешно!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Вернуться'),
            ),
          ],
        ),
      ),
    );
  }
}

class FailureScreen extends StatelessWidget {
  const FailureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 32),
            const Text('Ошибка оплаты', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Недостаточно средств на счете.'),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}
