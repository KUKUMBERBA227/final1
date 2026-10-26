import 'package:flutter/material.dart';

void main() {
  runApp(const IbisPaintApp());
}

// Палитра из изображения
class AppTheme {
  static const Color darkBackground = Color(0xFF000F22);
  static const Color panelColor = Color(0xFF1B3554);
  static const Color activeBlue = Color(0xFF3F6593);
  static const Color accentBlue = Color(0xFF5B86B6);
  static const Color iconColor = Color(0xFF80AAD3);
  static const Color lightText = Color(0xFFC0E6FD);

  static const List<Color> palette = [
    Color(0xFFC0E6FD),
    Color(0xFF80AAD3),
    Color(0xFF5B86B6),
    Color(0xFF3F6593),
    Color(0xFF1B3554),
    Color(0xFF000F22),
    Colors.white,
    Colors.black,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.amber,
  ];
}

enum ToolType { brush, eraser, rectangle, circle }

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;
  final double opacity;
  final ToolType toolType;

  DrawnLine({
    required this.path,
    required this.color,
    required this.width,
    required this.opacity,
    required this.toolType,
  });
}

class CanvasLayer {
  final String name;
  List<DrawnLine> lines;
  bool isVisible;

  CanvasLayer({
    required this.name,
    List<DrawnLine>? lines,
    this.isVisible = true,
  }) : lines = lines ?? [];
}

class IbisPaintApp extends StatelessWidget {
  const IbisPaintApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ibisPaint Canvas',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppTheme.darkBackground,
        primaryColor: AppTheme.activeBlue,
      ),
      home: const PaintingScreen(),
    );
  }
}

class PaintingScreen extends StatefulWidget {
  const PaintingScreen({Key? key}) : super(key: key);

  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> with TickerProviderStateMixin {
  // Настройки рисования
  Color selectedColor = AppTheme.lightText;
  double strokeWidth = 5.0;
  double strokeOpacity = 1.0;
  ToolType currentTool = ToolType.brush;

  // Слои
  List<CanvasLayer> layers = [
    CanvasLayer(name: 'Слой 1'),
  ];
  int activeLayerIndex = 0;

  // Траектория текущей линии
  List<Offset> currentPath = [];

  // Анимационные панели
  bool showLayerPanel = false;
  bool showColorPicker = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.panelColor,
        elevation: 4,
        title: const Text(
          'VibePAINT Studio',
          style: TextStyle(color: AppTheme.lightText, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: AppTheme.iconColor),
            tooltip: 'Отменить',
            onPressed: undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.iconColor),
            tooltip: 'Очистить слой',
            onPressed: clearCurrentLayer,
          ),
          IconButton(
            icon: Icon(
              Icons.layers,
              color: showLayerPanel ? AppTheme.lightText : AppTheme.iconColor,
            ),
            tooltip: 'Слои',
            onPressed: () {
              setState(() {
                showLayerPanel = !showLayerPanel;
                if (showLayerPanel) showColorPicker = false;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Холст для рисования
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentPath = [details.localPosition];
              });
            },
            onPanUpdate: (details) {
              setState(() {
                currentPath.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                if (currentPath.isNotEmpty) {
                  layers[activeLayerIndex].lines.add(
                    DrawnLine(
                      path: List.from(currentPath),
                      color: selectedColor,
                      width: strokeWidth,
                      opacity: strokeOpacity,
                      toolType: currentTool,
                    ),
                  );
                }
                currentPath = [];
              });
            },
            child: CustomPaint(
              painter: CanvasPainter(
                layers: layers,
                currentPath: currentPath,
                currentColor: selectedColor,
                currentWidth: strokeWidth,
                currentOpacity: strokeOpacity,
                currentTool: currentTool,
              ),
              child: Container(color: Colors.white.withOpacity(0.05)),
            ),
          ),

          // Панель выбора цвета (Выдвижная)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: showColorPicker ? 90 : -200,
            left: 20,
            right: 20,
            child: _buildColorPaletteWidget(),
          ),

          // Панель слоев (Выдвижная справа)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: 10,
            right: showLayerPanel ? 10 : -260,
            width: 240,
            height: 380,
            child: _buildLayerPanelWidget(),
          ),

          // Нижняя панель инструментов
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomToolbar(),
          ),
        ],
      ),
    );
  }

  void undo() {
    if (layers[activeLayerIndex].lines.isNotEmpty) {
      setState(() {
        layers[activeLayerIndex].lines.removeLast();
      });
    }
  }

  void clearCurrentLayer() {
    setState(() {
      layers[activeLayerIndex].lines.clear();
    });
  }

  // Виджет панели цветов
  Widget _buildColorPaletteWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panelColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Палитра цветов', style: TextStyle(color: AppTheme.lightText, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppTheme.palette.map((color) {
              final isSelected = selectedColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                    showColorPicker = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 36 : 30,
                  height: isSelected ? 36 : 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.lightText : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Виджет панели слоев
  Widget _buildLayerPanelWidget() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Слои', style: TextStyle(color: AppTheme.lightText, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, color: AppTheme.iconColor),
                onPressed: () {
                  setState(() {
                    layers.add(CanvasLayer(name: 'Слой ${layers.length + 1}'));
                    activeLayerIndex = layers.length - 1;
                  });
                },
              )
            ],
          ),
          const Divider(color: AppTheme.accentBlue),
          Expanded(
            child: ListView.builder(
              itemCount: layers.length,
              itemBuilder: (context, index) {
                final layer = layers[index];
                final isSelected = activeLayerIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.activeBlue : AppTheme.darkBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.lightText : Colors.transparent,
                    ),
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(layer.name, style: const TextStyle(color: AppTheme.lightText)),
                    leading: IconButton(
                      icon: Icon(
                        layer.isVisible ? Icons.visibility : Icons.visibility_off,
                        color: AppTheme.iconColor,
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          layer.isVisible = !layer.isVisible;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        activeLayerIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Нижняя панель с ползунками и инструментами
  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.panelColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Слайдеры размера и прозрачности
          Row(
            children: [
              const Icon(Icons.brush, size: 16, color: AppTheme.iconColor),
              Expanded(
                child: Slider(
                  value: strokeWidth,
                  min: 1,
                  max: 40,
                  activeColor: AppTheme.accentBlue,
                  inactiveColor: AppTheme.darkBackground,
                  onChanged: (val) => setState(() => strokeWidth = val),
                ),
              ),
              const Icon(Icons.opacity, size: 16, color: AppTheme.iconColor),
              Expanded(
                child: Slider(
                  value: strokeOpacity,
                  min: 0.1,
                  max: 1.0,
                  activeColor: AppTheme.accentBlue,
                  inactiveColor: AppTheme.darkBackground,
                  onChanged: (val) => setState(() => strokeOpacity = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Кнопки инструментов
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Цвет
              GestureDetector(
                onTap: () {
                  setState(() {
                    showColorPicker = !showColorPicker;
                    if (showColorPicker) showLayerPanel = false;
                  });
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.lightText, width: 2),
                  ),
                ),
              ),
              _buildToolButton(ToolType.brush, Icons.edit),
              _buildToolButton(ToolType.eraser, Icons.cleaning_services),
              _buildToolButton(ToolType.rectangle, Icons.crop_square),
              _buildToolButton(ToolType.circle, Icons.circle_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(ToolType tool, IconData icon) {
    final isSelected = currentTool == tool;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? AppTheme.lightText : AppTheme.iconColor,
      iconSize: isSelected ? 28 : 24,
      onPressed: () {
        setState(() {
          currentTool = tool;
        });
      },
    );
  }
}

// Отрисовка холста
class CanvasPainter extends CustomPainter {
  final List<CanvasLayer> layers;
  final List<Offset> currentPath;
  final Color currentColor;
  final double currentWidth;
  final double currentOpacity;
  final ToolType currentTool;

  CanvasPainter({
    required this.layers,
    required this.currentPath,
    required this.currentColor,
    required this.currentWidth,
    required this.currentOpacity,
    required this.currentTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Отрисовка всех видимых слоев
    for (var layer in layers) {
      if (!layer.isVisible) continue;

      for (var line in layer.lines) {
        _drawLine(canvas, line.path, line.color, line.width, line.opacity, line.toolType);
      }
    }

    // Отрисовка текущей проведенной линии в реальном времени
    if (currentPath.isNotEmpty) {
      _drawLine(canvas, currentPath, currentColor, currentWidth, currentOpacity, currentTool);
    }
  }

  void _drawLine(Canvas canvas, List<Offset> path, Color color, double width, double opacity, ToolType tool) {
    if (path.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (tool == ToolType.eraser) {
      paint.color = AppTheme.darkBackground; // Затирание фоновым цветом
    } else {
      paint.color = color.withOpacity(opacity);
    }

    if (tool == ToolType.brush || tool == ToolType.eraser) {
      for (int i = 0; i < path.length - 1; i++) {
        canvas.drawLine(path[i], path[i + 1], paint);
      }
    } else if (tool == ToolType.rectangle && path.length > 1) {
      final rect = Rect.fromPoints(path.first, path.last);
      canvas.drawRect(rect, paint);
    } else if (tool == ToolType.circle && path.length > 1) {
      final radius = (path.last - path.first).distance / 2;
      final center = Offset(
        (path.first.dx + path.last.dx) / 2,
        (path.first.dy + path.last.dy) / 2,
      );
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}
