import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/robot_model.dart';
import '../models/mission_model.dart';

class CorridorSchematicCanvas extends StatelessWidget {
  final List<RobotModel> robots;
  final String? selectedRobotId;
  final MissionModel? activeMission;
  final Function(String robotId)? onRobotSelected;

  const CorridorSchematicCanvas({
    super.key,
    required this.robots,
    this.selectedRobotId,
    this.activeMission,
    this.onRobotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pearlWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Custom Painter Canvas for Corridors & Waypoints
            CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _CorridorSchematicPainter(
                robots: robots,
                selectedRobotId: selectedRobotId,
                activeMission: activeMission,
              ),
            ),

            // Top-left Legend & Floor Indicator
            Positioned(
              top: 10,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.apartment_rounded, size: 14, color: AppTheme.primaryTeal),
                    const SizedBox(width: 6),
                    Text(
                      'CLINICAL WING - LEVEL 2 & 3 SCHEMATIC',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-right Interactive Robot Quick Chips
            Positioned(
              bottom: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: robots.map((r) {
                    final isSelected = r.id == selectedRobotId;
                    return GestureDetector(
                      onTap: () => onRobotSelected?.call(r.id),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.surfacePorcelain,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                          ),
                        ),
                        child: Text(
                          r.id,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.textMain,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CorridorSchematicPainter extends CustomPainter {
  final List<RobotModel> robots;
  final String? selectedRobotId;
  final MissionModel? activeMission;

  _CorridorSchematicPainter({
    required this.robots,
    this.selectedRobotId,
    this.activeMission,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid lines
    final gridPaint = Paint()
      ..color = AppTheme.borderSubtle.withOpacity(0.35)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Corridors & Ward Rooms
    final corridorPaint = Paint()
      ..color = AppTheme.surfacePorcelain
      ..style = PaintingStyle.fill;
    final wallBorderPaint = Paint()
      ..color = AppTheme.borderSubtle
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Corridor Paths: Horizontal main + Vertical connectors
    final r1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 60, size.width - 40, 45),
      const Radius.circular(6),
    );
    final r2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.45, 60, 45, 140),
      const Radius.circular(6),
    );
    final r3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 160, size.width - 40, 45),
      const Radius.circular(6),
    );

    canvas.drawRRect(r1, corridorPaint);
    canvas.drawRRect(r1, wallBorderPaint);
    canvas.drawRRect(r2, corridorPaint);
    canvas.drawRRect(r2, wallBorderPaint);
    canvas.drawRRect(r3, corridorPaint);
    canvas.drawRRect(r3, wallBorderPaint);

    // 3. Waypoint Stations
    _drawStationNode(canvas, const Offset(60, 82), 'ICU-01', AppTheme.accentTeal);
    _drawStationNode(canvas, Offset(size.width - 70, 82), 'OT-01', AppTheme.infectiousColor);
    _drawStationNode(canvas, const Offset(70, 182), 'Dock Bay', AppTheme.sageEmerald);
    _drawStationNode(canvas, Offset(size.width - 75, 182), 'Disposal Bay', AppTheme.plasticColor);

    // 4. Transit Path for Active Mission
    final transitPathPaint = Paint()
      ..color = AppTheme.accentTeal.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(70, 182)
      ..lineTo(size.width * 0.48, 182)
      ..lineTo(size.width * 0.48, 82)
      ..lineTo(size.width - 70, 82);
    canvas.drawPath(path, transitPathPaint);

    // 5. Draw Robots
    for (final r in robots) {
      final isSelected = r.id == selectedRobotId;
      // Scale coordinates to fit canvas
      final normX = 30.0 + (r.coordinates.x % (size.width - 80));
      final normY = 70.0 + (r.coordinates.y % 110);
      final center = Offset(normX, normY);

      // Shadow / Aura
      if (isSelected) {
        canvas.drawCircle(
          center,
          18,
          Paint()..color = AppTheme.accentTeal.withOpacity(0.25),
        );
      }

      // Robot Dot
      final robotPaint = Paint()
        ..color = isSelected ? AppTheme.primaryTeal : AppTheme.accentTeal
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, isSelected ? 9.0 : 7.5, robotPaint);

      // White inner ring
      canvas.drawCircle(
        center,
        3.0,
        Paint()..color = Colors.white,
      );

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: r.id,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryTeal : AppTheme.textMain,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(center.dx - 9, center.dy - 22));
    }
  }

  void _drawStationNode(Canvas canvas, Offset offset, String label, Color color) {
    // Station badge circle
    canvas.drawCircle(
      offset,
      8,
      Paint()..color = color.withOpacity(0.18),
    );
    canvas.drawCircle(
      offset,
      4.5,
      Paint()..color = color,
    );

    // Station name label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: AppTheme.textMain,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy + 7));
  }

  @override
  bool shouldRepaint(covariant _CorridorSchematicPainter oldDelegate) => true;
}
