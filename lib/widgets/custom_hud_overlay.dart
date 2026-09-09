import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/waste_item_model.dart';

class CustomHudOverlay extends StatefulWidget {
  final WasteItemModel item;
  final bool isScanning;

  const CustomHudOverlay({
    super.key,
    required this.item,
    this.isScanning = true,
  });

  @override
  State<CustomHudOverlay> createState() => _CustomHudOverlayState();
}

class _CustomHudOverlayState extends State<CustomHudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = widget.item.boundingBox;
        final boxLeft = box.left * constraints.maxWidth;
        final boxTop = box.top * constraints.maxHeight;
        final boxWidth = box.width * constraints.maxWidth;
        final boxHeight = box.height * constraints.maxHeight;

        return Stack(
          children: [
            // Background Simulated Camera Grid & Corner Reticles
            Positioned.fill(
              child: CustomPaint(
                painter: _HudGridPainter(
                  sweepProgress: _sweepController.value,
                  targetCategoryColor: widget.item.category.color,
                ),
              ),
            ),

            // Animated Scanner Sweep Line
            AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                final sweepY = boxTop + (_sweepController.value * boxHeight);
                return Positioned(
                  left: boxLeft - 10,
                  top: sweepY,
                  width: boxWidth + 20,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.item.category.accentColor.withOpacity(0.0),
                          widget.item.category.accentColor,
                          widget.item.category.accentColor.withOpacity(0.0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.item.category.accentColor.withOpacity(0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Bounding Box with Corner Brackets & Glowing Aura
            Positioned(
              left: boxLeft,
              top: boxTop,
              width: boxWidth,
              height: boxHeight,
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  color: widget.item.category.accentColor,
                ),
              ),
            ),

            // Top-left Classification Badge
            Positioned(
              left: boxLeft,
              top: (boxTop - 42).clamp(10.0, constraints.maxHeight - 50),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.item.category.accentColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.item.category.accentColor.withOpacity(0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.item.category.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI: ${widget.item.detectedObject.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.item.category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${(widget.item.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: widget.item.category.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-left Sensor Tag: Weight & Diverter Gate
            Positioned(
              left: boxLeft,
              top: (boxTop + boxHeight + 10).clamp(10.0, constraints.maxHeight - 65),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppConstants.tealPrimary,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.scale_rounded, color: AppConstants.tealAccent, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'LOAD CELL: ${Formatters.formatWeight(widget.item.weightKg)}',
                          style: const TextStyle(
                            color: AppConstants.tealAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          'DEPTH: 42.4 cm',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppConstants.amberWarning, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'ROBOT ACTION: ${widget.item.category.compartmentGateId}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

/// Custom painter for camera grid lines, center crosshairs, and corner marks
class _HudGridPainter extends CustomPainter {
  final double sweepProgress;
  final Color targetCategoryColor;

  _HudGridPainter({
    required this.sweepProgress,
    required this.targetCategoryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.10)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw subtle grid
    const double step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Center Crosshair
    final centerPaint = Paint()
      ..color = targetCategoryColor.withOpacity(0.5)
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx - 15, center.dy), Offset(center.dx + 15, center.dy), centerPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 15), Offset(center.dx, center.dy + 15), centerPaint);
    canvas.drawCircle(center, 24, gridPaint..color = targetCategoryColor.withOpacity(0.3));

    // Outer Viewfinder Corner Markers
    final cornerPaint = Paint()
      ..color = const Color(0xFF38BDF8).withOpacity(0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerSize = 20.0;
    const margin = 16.0;

    // Top-left
    canvas.drawLine(const Offset(margin, margin), const Offset(margin + cornerSize, margin), cornerPaint);
    canvas.drawLine(const Offset(margin, margin), const Offset(margin, margin + cornerSize), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - cornerSize, margin), cornerPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerSize), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerSize, size.height - margin), cornerPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - cornerSize), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - cornerSize, size.height - margin), cornerPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _HudGridPainter oldDelegate) {
    return oldDelegate.sweepProgress != sweepProgress ||
        oldDelegate.targetCategoryColor != targetCategoryColor;
  }
}

/// Custom painter for the 4 corner brackets of the object's targeting bounding box
class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Light enclosing rect
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    final bracketPaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final armLength = size.width * 0.18;

    // Top-Left
    canvas.drawLine(const Offset(0, 0), Offset(armLength, 0), bracketPaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, armLength), bracketPaint);

    // Top-Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - armLength, 0), bracketPaint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, armLength), bracketPaint);

    // Bottom-Left
    canvas.drawLine(Offset(0, size.height), Offset(armLength, size.height), bracketPaint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - armLength), bracketPaint);

    // Bottom-Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - armLength, size.height), bracketPaint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - armLength), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
