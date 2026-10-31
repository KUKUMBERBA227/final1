import 'package:flutter/material.dart';

void main() {
  runApp(const PixelLauncherApp());
}

class PixelLauncherApp extends StatelessWidget {
  const PixelLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pixel Experience',
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Roboto'),
      home: const PixelHomeScreen(),
    );
  }
}

class PixelHomeScreen extends StatelessWidget {
  const PixelHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B2A4A), Color(0xFF0F172A), Color(0xFF0A0F1D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Верхняя часть: Виджет "At a Glance" и строка состояния
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '9:31',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.signal_cellular_4_bar, size: 14),
                            SizedBox(width: 6),
                            Icon(Icons.wifi, size: 14),
                            SizedBox(width: 6),
                            Icon(Icons.battery_full, size: 14),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Сб, 31 окт.',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.wb_sunny_outlined,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '18° · Преимущественно ястно',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Центральная часть: Сетка приложений
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  children: const [
                    PixelAppIcon(
                      icon: Icons.g_mobiledata,
                      label: 'Google',
                      color: Colors.white,
                    ),
                    PixelAppIcon(
                      icon: Icons.camera_alt_outlined,
                      label: 'Камера',
                      color: Color(0xFF8AB4F8),
                    ),
                    PixelAppIcon(
                      icon: Icons.photo_outlined,
                      label: 'Фото',
                      color: Color(0xFFF28B82),
                    ),
                    PixelAppIcon(
                      icon: Icons.map_outlined,
                      label: 'Карты',
                      color: Color(0xFF81C995),
                    ),
                    PixelAppIcon(
                      icon: Icons.chat_bubble_outline,
                      label: 'Сообщения',
                      color: Color(0xFF8AB4F8),
                    ),
                    PixelAppIcon(
                      icon: Icons.phone_outlined,
                      label: 'Телефон',
                      color: Color(0xFF81C995),
                    ),
                    PixelAppIcon(
                      icon: Icons.folder_outlined,
                      label: 'Файлы',
                      color: Color(0xFFFDD663),
                    ),
                    PixelAppIcon(
                      icon: Icons.settings_outlined,
                      label: 'Настройки',
                      color: Color(0xFFE8EAED),
                    ),
                  ],
                ),
              ),

              // Нижняя часть: Строка поиска Google и Док-бар с жестом
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          PixelDockIcon(
                            icon: Icons.phone,
                            color: Color(0xFF81C995),
                          ),
                          PixelDockIcon(
                            icon: Icons.message,
                            color: Color(0xFF8AB4F8),
                          ),
                          PixelDockIcon(
                            icon: Icons.public,
                            color: Color(0xFFF28B82),
                          ),
                          PixelDockIcon(
                            icon: Icons.music_note,
                            color: Color(0xFFFDD663),
                          ),
                          PixelDockIcon(icon: Icons.apps, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3544),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8AB4F8),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Поиск или веб-адрес',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.mic_none,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.lens_outlined,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white54,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PixelAppIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const PixelAppIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black45,
                offset: Offset(0, 1),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class PixelDockIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const PixelDockIcon({super.key, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
