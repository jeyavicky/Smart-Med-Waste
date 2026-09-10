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
            // Background Clinical Inspection Grid & Calibration Reticles
            Positioned.fill(
              child: CustomPaint(
                painter: _ClinicalInspectionPainter(
                  sweepProgress: _sweepController.value,
                  targetCategoryColor: widget.item.category.badgeColor,
                ),
              ),
            ),

            // Precision Optical Scanning Line
            AnimatedBuilder(
              animation: _sweepController,
              builder: (context, child) {
                final sweepY = boxTop + (_sweepController.value * boxHeight);
                return Positioned(
                  left: boxLeft - 4,
                  top: sweepY,
                  width: boxWidth + 8,
                  child: Container(
                    height: 1.5,
                    color: widget.item.category.badgeColor.withOpacity(0.85),
                  ),
                );
              },
            ),

            // Bounding Box with Clean Corner Brackets
            Positioned(
              left: boxLeft,
              top: boxTop,
              width: boxWidth,
              height: boxHeight,
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  color: widget.item.category.badgeColor,
                ),
              ),
            ),

            // Top-left Classification Badge
            Positioned(
              left: boxLeft,
              top: (boxTop - 36).clamp(8.0, constraints.maxHeight - 44),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.item.category.badgeColor,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: widget.item.category.badgeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.item.detectedObject.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: widget.item.category.badgeColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${(widget.item.confidence * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: widget.item.category.badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
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
              top: (boxTop + boxHeight + 8).clamp(8.0, constraints.maxHeight - 56),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF334155),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.scale_rounded, color: AppConstants.medicalTeal, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'MASS: ${Formatters.formatWeight(widget.item.weightKg)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.tune_rounded, color: AppConstants.coolSlate, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.category.compartmentGateId,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
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

/// Custom painter for clinical camera grid lines, center crosshairs, and corner marks
class _ClinicalInspectionPainter extends CustomPainter {
  final double sweepProgress;
  final Color targetCategoryColor;

  _ClinicalInspectionPainter({
    required this.sweepProgress,
    required this.targetCategoryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // Subtle calibration grid
    const double step = 45.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Center Crosshair
    final centerPaint = Paint()
      ..color = targetCategoryColor.withOpacity(0.4)
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(center.dx - 12, center.dy), Offset(center.dx + 12, center.dy), centerPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx, center.dy + 12), centerPaint);
    canvas.drawCircle(center, 20, gridPaint..color = targetCategoryColor.withOpacity(0.25));

    // Outer Viewfinder Corner Markers
    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const cornerSize = 16.0;
    const margin = 14.0;

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
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin + cornerSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _ClinicalInspectionPainter oldDelegate) {
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
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Light enclosing rect
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    final bracketPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final armLength = size.width * 0.16;

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
