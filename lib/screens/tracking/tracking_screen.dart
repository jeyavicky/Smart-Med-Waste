import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/robot_model.dart';
import '../../providers/robot_provider.dart';
import '../../widgets/robot_fleet_selector.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final robot = robotProvider.robot;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hospital Autonomous Transit Map', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(
              'Tracking: ${robot.name} (${robot.id})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Simulate Step Transit',
            icon: const Icon(Icons.fast_forward_rounded, color: AppConstants.medicalTeal),
            onPressed: () {
              robotProvider.stepAutonomousTransit();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fleet Selector Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: const RobotFleetSelector(),
          ),

          // Current Transit Status Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceSlate : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: robot.status.statusColor.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(robot.status.icon, color: robot.status.statusColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        robot.status.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: robot.status.statusColor,
                        ),
                      ),
                      Text(
                        'Location: ${robot.currentWard} • Floor 2 SLAM Grid',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.radar_rounded, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 4),
                      Text(
                        'LiDAR LOCKED',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Hospital Map Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1322) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppConstants.borderSlate : const Color(0xFFCBD5E1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _HospitalCorridorMapPainter(
                          robotCoordinates: robot.coordinates,
                          robotStatus: robot.status,
                          pulseProgress: _pulseController.value,
                          isDark: isDark,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Waypoint Navigation Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceSlate : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Autonomous Corridor Route',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => robotProvider.stepAutonomousTransit(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 14),
                      label: const Text('STEP TRANSIT', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Route Steps Horizontal Sequence
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRouteStep('ICU Station 01', 'Start / Pickup', isPassed: true, isCurrent: robotProvider.currentWaypointIndex == 0),
                      _buildStepDivider(),
                      _buildRouteStep('Airlock Door 1', 'Bio-Seal Check', isPassed: robotProvider.currentWaypointIndex >= 1, isCurrent: robotProvider.currentWaypointIndex == 1),
                      _buildStepDivider(),
                      _buildRouteStep('Corridor B West', 'SLAM Navigating', isPassed: robotProvider.currentWaypointIndex >= 2, isCurrent: robotProvider.currentWaypointIndex == 2),
                      _buildStepDivider(),
                      _buildRouteStep('Transfer Chute', 'Elevator Bay', isPassed: robotProvider.currentWaypointIndex >= 3, isCurrent: robotProvider.currentWaypointIndex == 3),
                      _buildStepDivider(),
                      _buildRouteStep('Central Waste Facility', 'Automated Deposit', isPassed: robotProvider.currentWaypointIndex >= 4, isCurrent: robotProvider.currentWaypointIndex == 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStep(
    String title,
    String subtitle, {
    required bool isPassed,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppConstants.tealPrimary.withOpacity(0.2)
            : (isPassed ? const Color(0xFF10B981).withOpacity(0.1) : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? AppConstants.tealAccent
              : (isPassed ? const Color(0xFF10B981) : AppConstants.borderSlate),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPassed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: 13,
                color: isCurrent
                    ? AppConstants.tealAccent
                    : (isPassed ? const Color(0xFF10B981) : AppConstants.neutralGrey),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isCurrent ? AppConstants.tealAccent : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppConstants.neutralGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 16,
      height: 2,
      color: AppConstants.borderSlate,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Custom painter for schematic hospital floor plan and autonomous route
class _HospitalCorridorMapPainter extends CustomPainter {
  final RobotCoordinates robotCoordinates;
  final RobotStatus robotStatus;
  final double pulseProgress;
  final bool isDark;

  _HospitalCorridorMapPainter({
    required this.robotCoordinates,
    required this.robotStatus,
    required this.pulseProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 320.0;
    final scaleY = size.height / 340.0;

    // Background architectural grid
    final gridPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)).withOpacity(0.35)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Room 1: ICU Wing
    _drawRoom(canvas, Rect.fromLTWH(20 * scaleX, 20 * scaleY, 90 * scaleX, 80 * scaleY), 'ICU WARD', isDark);

    // Room 2: Operation Theatres (OT 1-4)
    _drawRoom(canvas, Rect.fromLTWH(180 * scaleX, 20 * scaleY, 110 * scaleX, 80 * scaleY), 'OT COMPLEX', isDark);

    // Room 3: Pathology Lab
    _drawRoom(canvas, Rect.fromLTWH(20 * scaleX, 180 * scaleY, 90 * scaleX, 90 * scaleY), 'PATH LAB', isDark);

    // Room 4: Central Waste Disposal Facility
    _drawRoom(
      canvas,
      Rect.fromLTWH(180 * scaleX, 200 * scaleY, 120 * scaleX, 110 * scaleY),
      'CENTRAL BIO DISPOSAL',
      isDark,
      highlight: true,
    );

    // Corridor Navigation Path Line
    final pathPaint = Paint()
      ..color = AppConstants.tealPrimary.withOpacity(0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(75.0 * scaleX, 65.0 * scaleY);
    path.lineTo(140.0 * scaleX, 65.0 * scaleY);
    path.lineTo(140.0 * scaleX, 160.0 * scaleY);
    path.lineTo(230.0 * scaleX, 160.0 * scaleY);
    path.lineTo(230.0 * scaleX, 260.0 * scaleY);

    canvas.drawPath(path, pathPaint);

    // Waypoint dots
    final waypointPaint = Paint()
      ..color = AppConstants.tealAccent
      ..style = PaintingStyle.fill;

    final waypoints = [
      Offset(75.0 * scaleX, 65.0 * scaleY),
      Offset(140.0 * scaleX, 65.0 * scaleY),
      Offset(140.0 * scaleX, 160.0 * scaleY),
      Offset(230.0 * scaleX, 160.0 * scaleY),
      Offset(230.0 * scaleX, 260.0 * scaleY),
    ];

    for (final pt in waypoints) {
      canvas.drawCircle(pt, 4, waypointPaint);
    }

    // Draw Robot Position
    final rx = (robotCoordinates.x * scaleX).clamp(10.0, size.width - 10);
    final ry = (robotCoordinates.y * scaleY).clamp(10.0, size.height - 10);
    final robotCenter = Offset(rx, ry);

    // Pulsing radar ripple
    final pulsePaint = Paint()
      ..color = robotStatus.statusColor.withOpacity(1.0 - pulseProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(robotCenter, 12 + (pulseProgress * 16), pulsePaint);

    // Robot Body
    final robotBodyPaint = Paint()
      ..color = robotStatus.statusColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(robotCenter, 10, robotBodyPaint);
    canvas.drawCircle(robotCenter, 10, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);

    // Heading direction indicator
    final headingAngle = (robotCoordinates.headingDegrees * math.pi) / 180.0;
    final headingTip = Offset(
      robotCenter.dx + math.cos(headingAngle) * 16,
      robotCenter.dy + math.sin(headingAngle) * 16,
    );
    canvas.drawLine(
      robotCenter,
      headingTip,
      Paint()..color = Colors.white..strokeWidth = 3..strokeCap = StrokeCap.round,
    );

    // Robot Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: ' R-01 ',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.black.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(robotCenter.dx - 12, robotCenter.dy - 24));
  }

  void _drawRoom(Canvas canvas, Rect rect, String label, bool isDark, {bool highlight = false}) {
    final fillPaint = Paint()
      ..color = highlight
          ? AppConstants.tealPrimary.withOpacity(0.18)
          : (isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC))
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = highlight
          ? AppConstants.tealAccent.withOpacity(0.6)
          : (isDark ? AppConstants.borderSlate : const Color(0xFFCBD5E1))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: highlight ? AppConstants.tealAccent : (isDark ? AppConstants.lightSlate : AppConstants.neutralGrey),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 8);

    textPainter.paint(
      canvas,
      Offset(rect.left + (rect.width - textPainter.width) / 2, rect.top + 10),
    );
  }

  @override
  bool shouldRepaint(covariant _HospitalCorridorMapPainter oldDelegate) {
    return oldDelegate.robotCoordinates != robotCoordinates ||
        oldDelegate.robotStatus != robotStatus ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.isDark != isDark;
  }
}
