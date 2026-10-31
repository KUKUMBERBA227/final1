import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const DroneGameApp());
}

class DroneGameApp extends StatelessWidget {
  const DroneGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const DroneGameScreen(),
    );
  }
}

class DroneGameScreen extends StatefulWidget {
  const DroneGameScreen({super.key});

  @override
  State<DroneGameScreen> createState() => _DroneGameScreenState();
}

class Point2D {
  double x;
  double y;
  Point2D(this.x, this.y);
}

class _DroneGameScreenState extends State<DroneGameScreen> {
  // Игровые параметры
  double droneX = 0;
  double droneY = 0.6;
  double maxBattery = 100.0;
  double batteryLevel = 100.0;
  int score = 0;
  
  // Валюта и магазин
  int totalCoins = 0;
  int runCoins = 0;
  int batteryUpgradeLevel = 0;
  int efficiencyUpgradeLevel = 0;

  // Механика возрождения
  int revivesUsed = 0;
  bool isInvulnerable = false;
  Timer? invulnerabilityTimer;

  bool isPlaying = false;
  bool isGameOver = false;
  bool isShopOpen = false;

  Timer? gameTimer;
  final Random random = Random();

  List<Point2D> obstacles = [];
  List<Point2D> batteries = [];
  List<Point2D> coins = [];

  int get reviveCost => 10 + (revivesUsed * 10);

  void startGame() {
    setState(() {
      droneX = 0;
      droneY = 0.6;
      maxBattery = 100.0 + (batteryUpgradeLevel * 20.0);
      batteryLevel = maxBattery;
      score = 0;
      runCoins = 0;
      revivesUsed = 0;
      isInvulnerable = false;
      isPlaying = true;
      isGameOver = false;
      isShopOpen = false;
      obstacles.clear();
      batteries.clear();
      coins.clear();
    });

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      updateGame();
    });
  }

  void reviveDrone() {
    int currentAvailableCoins = totalCoins + runCoins;
    if (currentAvailableCoins < reviveCost) return;

    setState(() {
      if (runCoins >= reviveCost) {
        runCoins -= reviveCost;
      } else {
        int remainder = reviveCost - runCoins;
        runCoins = 0;
        totalCoins -= remainder;
      }

      revivesUsed++;
      batteryLevel = maxBattery * 0.5;
      isGameOver = false;
      isPlaying = true;
      obstacles.clear();
      isInvulnerable = true;
    });

    invulnerabilityTimer?.cancel();
    invulnerabilityTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isInvulnerable = false;
        });
      }
    });

    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      updateGame();
    });
  }

  void updateGame() {
    if (!isPlaying) return;

    setState(() {
      double drainRate = 0.15 - (efficiencyUpgradeLevel * 0.02);
      batteryLevel -= drainRate.clamp(0.05, 0.15);
      
      if (batteryLevel <= 0) {
        gameOver();
        return;
      }

      score += 1;

      if (random.nextDouble() < 0.08) {
        obstacles.add(Point2D(random.nextDouble() * 1.8 - 0.9, -1.2));
      }

      if (random.nextDouble() < 0.025) {
        batteries.add(Point2D(random.nextDouble() * 1.8 - 0.9, -1.2));
      }

      if (random.nextDouble() < 0.04) {
        coins.add(Point2D(random.nextDouble() * 1.8 - 0.9, -1.2));
      }

      for (var o in obstacles) o.y += 0.03;
      for (var b in batteries) b.y += 0.03;
      for (var c in coins) c.y += 0.03;

      obstacles.removeWhere((o) => o.y > 1.2);
      batteries.removeWhere((b) => b.y > 1.2);
      coins.removeWhere((c) => c.y > 1.2);

      if (!isInvulnerable) {
        for (var o in obstacles) {
          if ((o.x - droneX).abs() < 0.18 && (o.y - droneY).abs() < 0.12) {
            gameOver();
            return;
          }
        }
      }

      batteries.removeWhere((b) {
        if ((b.x - droneX).abs() < 0.18 && (b.y - droneY).abs() < 0.12) {
          batteryLevel = (batteryLevel + 30.0).clamp(0.0, maxBattery);
          return true;
        }
        return false;
      });

      coins.removeWhere((c) {
        if ((c.x - droneX).abs() < 0.18 && (c.y - droneY).abs() < 0.12) {
          runCoins += 1;
          return true;
        }
        return false;
      });
    });
  }

  void gameOver() {
    gameTimer?.cancel();
    setState(() {
      isPlaying = false;
      isGameOver = true;
    });
  }

  void finalizeGameOver() {
    totalCoins += runCoins;
    runCoins = 0;
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    invulnerabilityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentAvailableCoins = totalCoins + runCoins;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (!isPlaying) return;
          final size = MediaQuery.of(context).size;
          setState(() {
            droneX += (details.delta.dx / (size.width / 2));
            droneY += (details.delta.dy / (size.height / 2));
            droneX = droneX.clamp(-0.9, 0.9);
            droneY = droneY.clamp(-0.8, 0.8);
          });
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: RadarGridPainter(),
              ),
            ),

            ...obstacles.map((o) => Align(
                  alignment: Alignment(o.x, o.y),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.warning_amber, size: 20, color: Colors.white),
                  ),
                )),

            ...batteries.map((b) => Align(
                  alignment: Alignment(b.x, b.y),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8EFF00),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: const Color(0xFF8EFF00).withOpacity(0.6), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.bolt, size: 20, color: Colors.black),
                  ),
                )),

            ...coins.map((c) => Align(
                  alignment: Alignment(c.x, c.y),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.amberAccent.withOpacity(0.6), blurRadius: 8)],
                    ),
                    child: const Center(
                      child: Text('₽', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                )),

            if (isPlaying || !isGameOver)
              Align(
                alignment: Alignment(droneX, droneY),
                child: DroneWidget(isInvulnerable: isInvulnerable),
              ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'СЧЕТ: $score',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$currentAvailableCoins',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.battery_charging_full, color: Color(0xFF8EFF00)),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 80,
                          child: LinearProgressIndicator(
                            value: (batteryLevel / maxBattery).clamp(0.0, 1.0),
                            backgroundColor: Colors.white10,
                            color: batteryLevel > (maxBattery * 0.3) ? const Color(0xFF8EFF00) : Colors.red,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (!isPlaying)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8EFF00), width: 1.5),
                  ),
                  child: isShopOpen
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'МАГАЗИН УЛУЧШЕНИЙ',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 16),
                            Text('Доступно монет: $totalCoins', style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Емкость батареи', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: Text('Уровень: $batteryUpgradeLevel', style: const TextStyle(color: Colors.cyanAccent)),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8EFF00), foregroundColor: Colors.black),
                                onPressed: totalCoins >= 10 ? () {
                                  setState(() {
                                    totalCoins -= 10;
                                    batteryUpgradeLevel++;
                                  });
                                } : null,
                                child: const Text('10 ₽'),
                              ),
                            ),
                            ListTile(
                              title: const Text('Энергоэффективность', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: Text('Уровень: $efficiencyUpgradeLevel', style: const TextStyle(color: Colors.cyanAccent)),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8EFF00), foregroundColor: Colors.black),
                                onPressed: efficiencyUpgradeLevel < 4 && totalCoins >= 15 ? () {
                                  setState(() {
                                    totalCoins -= 15;
                                    efficiencyUpgradeLevel++;
                                  });
                                } : null,
                                child: const Text('15 ₽'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => setState(() => isShopOpen = false),
                              child: const Text('НАЗАД', style: TextStyle(color: Color(0xFF8EFF00), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isGameOver ? 'СВЯЗЬ ПОТЕРЯНА' : 'DRONE COMMANDER',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isGameOver ? Colors.redAccent : const Color(0xFF8EFF00),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (isGameOver) ...[
                              Text('Счет: $score', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                icon: const Icon(Icons.bolt),
                                label: Text('ВОЗРОДИТЬСЯ ($reviveCost ₽)'),
                                onPressed: currentAvailableCoins >= reviveCost ? reviveDrone : null,
                              ),
                              const SizedBox(height: 30),
                            ],
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8EFF00),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              onPressed: () {
                                if (isGameOver) finalizeGameOver();
                                startGame();
                              },
                              child: Text(
                                isGameOver ? 'НОВАЯ ИГРА' : 'ЗАПУСК',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.amber),
                                foregroundColor: Colors.amber,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                              ),
                              onPressed: () => setState(() => isShopOpen = true),
                              child: const Text('МАГАЗИН', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DroneWidget extends StatelessWidget {
  final bool isInvulnerable;
  const DroneWidget({super.key, this.isInvulnerable = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isInvulnerable
            ? Colors.cyanAccent.withOpacity(0.4)
            : const Color(0xFF8EFF00).withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: isInvulnerable ? Colors.cyanAccent : const Color(0xFF8EFF00),
          width: isInvulnerable ? 2.5 : 1.5,
        ),
        boxShadow: isInvulnerable
            ? [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.8),
                  blurRadius: 12,
                )
              ]
            : [],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.navigation,
            color: isInvulnerable ? Colors.cyanAccent : const Color(0xFF8EFF00),
            size: 28,
          ),
          Positioned(
            top: 2,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
            ),
          )
        ],
      ),
    );
  }
}

class RadarGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double step = 40;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}                                             
