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
    final currentRoute = robotProvider.currentRoute;
    final currentWaypointIndex = robotProvider.currentWaypointIndex;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hospital Autonomous Transit Map',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            Text(
              'Tracking: ${robot.name} (${robot.id}) • Destination: ${robot.destination}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Step Next Waypoint',
            icon: const Icon(Icons.skip_next_rounded, color: AppConstants.medicalTeal),
            onPressed: () => robotProvider.stepAutonomousTransit(),
          ),
          IconButton(
            tooltip: 'Reset to Route Start',
            icon: const Icon(Icons.replay_rounded, color: AppConstants.textSecondary),
            onPressed: () => robotProvider.resetRoute(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fleet Selector Bar
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: RobotFleetSelector(),
          ),

          // Current Transit & Destination Status Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceSlate : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(isDark ? 0.25 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
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
                          Row(
                            children: [
                              Text(
                                robot.status.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: robot.status.statusColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppConstants.clinicalNavy.withOpacity(isDark ? 0.4 : 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  robot.id,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppConstants.clinicalNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Current: ${robot.currentWard}',
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
                            'SLAM ACTIVE',
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
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Destination row + Quick Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.flag_rounded, size: 14, color: AppConstants.medicalTeal),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Target: ${robot.destination}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppConstants.clinicalNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Auto Transit Toggle Button
                    InkWell(
                      onTap: () => robotProvider.toggleAutoTransit(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: robotProvider.isAutoTraveling
                              ? AppConstants.medicalTeal
                              : (isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              robotProvider.isAutoTraveling ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 14,
                              color: robotProvider.isAutoTraveling ? Colors.white : AppConstants.clinicalNavy,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              robotProvider.isAutoTraveling ? 'PAUSE TRANSIT' : 'AUTO-TRAVEL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: robotProvider.isAutoTraveling ? Colors.white : AppConstants.clinicalNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Hospital Map Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                          selectedRobot: robot,
                          fleet: robotProvider.fleet,
                          currentRoute: currentRoute,
                          currentWaypointIndex: currentWaypointIndex,
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

          // Waypoint Navigation & Route Sequence Card
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceSlate : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.alt_route_rounded, size: 16, color: AppConstants.medicalTeal),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Route to ${robot.destination}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark ? Colors.white : AppConstants.clinicalNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => robotProvider.stepAutonomousTransit(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 30),
                        backgroundColor: AppConstants.clinicalNavy,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 13),
                      label: const Text('STEP TRANSIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Route Steps Horizontal Sequence
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < currentRoute.length; i++) ...[
                        InkWell(
                          onTap: () => robotProvider.navigateToWaypoint(i),
                          borderRadius: BorderRadius.circular(10),
                          child: _buildRouteStep(
                            index: i + 1,
                            title: currentRoute[i].title,
                            subtitle: currentRoute[i].subtitle,
                            isPassed: currentWaypointIndex >= i,
                            isCurrent: currentWaypointIndex == i,
                            isDestination: i == currentRoute.length - 1,
                          ),
                        ),
                        if (i < currentRoute.length - 1) _buildStepDivider(isPassed: currentWaypointIndex > i),
                      ],
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

  Widget _buildRouteStep({
    required int index,
    required String title,
    required String subtitle,
    required bool isPassed,
    required bool isCurrent,
    required bool isDestination,
  }) {
    final Color badgeColor = isCurrent
        ? AppConstants.medicalTeal
        : (isPassed ? const Color(0xFF10B981) : AppConstants.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppConstants.medicalTeal.withOpacity(0.15)
            : (isPassed ? const Color(0xFF10B981).withOpacity(0.08) : Colors.transparent),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? AppConstants.medicalTeal
              : (isPassed ? const Color(0xFF10B981) : const Color(0xFFCBD5E1)),
          width: isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDestination
                    ? (isPassed ? Icons.check_circle_rounded : Icons.flag_rounded)
                    : (isPassed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
                size: 13,
                color: badgeColor,
              ),
              const SizedBox(width: 5),
              Text(
                '$index. $title',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                  color: isCurrent ? AppConstants.medicalTeal : null,
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

  Widget _buildStepDivider({required bool isPassed}) {
    return Container(
      width: 16,
      height: 2,
      color: isPassed ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Custom painter for schematic hospital floor plan, all AMRs, and active autonomous route
class _HospitalCorridorMapPainter extends CustomPainter {
  final RobotModel selectedRobot;
  final List<RobotModel> fleet;
  final List<RobotRouteStep> currentRoute;
  final int currentWaypointIndex;
  final double pulseProgress;
  final bool isDark;

  _HospitalCorridorMapPainter({
    required this.selectedRobot,
    required this.fleet,
    required this.currentRoute,
    required this.currentWaypointIndex,
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

    // Dynamic Route Path for Currently Selected Robot
    if (currentRoute.isNotEmpty) {
      final pathPaint = Paint()
        ..color = AppConstants.medicalTeal.withOpacity(0.75)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(currentRoute.first.coordinates.x * scaleX, currentRoute.first.coordinates.y * scaleY);
      for (int i = 1; i < currentRoute.length; i++) {
        path.lineTo(currentRoute[i].coordinates.x * scaleX, currentRoute[i].coordinates.y * scaleY);
      }
      canvas.drawPath(path, pathPaint);

      // Route Waypoint Dots
      for (int i = 0; i < currentRoute.length; i++) {
        final wp = currentRoute[i].coordinates;
        final pt = Offset(wp.x * scaleX, wp.y * scaleY);
        final isPassed = currentWaypointIndex >= i;
        final isCurrent = currentWaypointIndex == i;
        final isDest = i == currentRoute.length - 1;

        final Color dotColor = isCurrent
            ? AppConstants.medicalTeal
            : (isPassed ? const Color(0xFF10B981) : (isDest ? AppConstants.crimsonDanger : const Color(0xFF94A3B8)));

        canvas.drawCircle(pt, isCurrent ? 5.5 : 4.0, Paint()..color = dotColor);
        canvas.drawCircle(
          pt,
          isCurrent ? 5.5 : 4.0,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }

    // Draw Other Fleet Robots (Inactive Markers)
    for (final bot in fleet) {
      if (bot.id == selectedRobot.id) continue;

      final bx = (bot.coordinates.x * scaleX).clamp(10.0, size.width - 10);
      final by = (bot.coordinates.y * scaleY).clamp(10.0, size.height - 10);
      final botCenter = Offset(bx, by);

      // Other robot circular dot
      canvas.drawCircle(
        botCenter,
        7,
        Paint()..color = bot.status.statusColor.withOpacity(0.7),
      );
      canvas.drawCircle(
        botCenter,
        7,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Other robot ID text
      final otherPainter = TextPainter(
        text: TextSpan(
          text: bot.id,
          style: const TextStyle(
            color: Colors.white,
            backgroundColor: Color(0xCC0F172A),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      otherPainter.paint(canvas, Offset(botCenter.dx - (otherPainter.width / 2), botCenter.dy - 18));
    }

    // Draw Active Selected Robot Position & Heading
    final rx = (selectedRobot.coordinates.x * scaleX).clamp(10.0, size.width - 10);
    final ry = (selectedRobot.coordinates.y * scaleY).clamp(10.0, size.height - 10);
    final robotCenter = Offset(rx, ry);

    // Pulsing radar ripple
    final pulsePaint = Paint()
      ..color = selectedRobot.status.statusColor.withOpacity((1.0 - pulseProgress).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(robotCenter, 12 + (pulseProgress * 16), pulsePaint);

    // Selected Robot Body
    final robotBodyPaint = Paint()
      ..color = selectedRobot.status.statusColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(robotCenter, 11, robotBodyPaint);
    canvas.drawCircle(
      robotCenter,
      11,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Heading direction indicator arrow
    final headingAngle = (selectedRobot.coordinates.headingDegrees * math.pi) / 180.0;
    final headingTip = Offset(
      robotCenter.dx + math.cos(headingAngle) * 18,
      robotCenter.dy + math.sin(headingAngle) * 18,
    );
    canvas.drawLine(
      robotCenter,
      headingTip,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    // Selected Robot Label - DYNAMIC ROBOT ID!
    final textPainter = TextPainter(
      text: TextSpan(
        text: ' ${selectedRobot.id} • ${selectedRobot.name} ',
        style: const TextStyle(
          color: Colors.white,
          backgroundColor: Color(0xEE0F2942),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(robotCenter.dx - (textPainter.width / 2), robotCenter.dy - 26));
  }

  void _drawRoom(Canvas canvas, Rect rect, String label, bool isDark, {bool highlight = false}) {
    final fillPaint = Paint()
      ..color = highlight
          ? AppConstants.medicalTeal.withOpacity(0.15)
          : (isDark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC))
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = highlight
          ? AppConstants.medicalTeal.withOpacity(0.6)
          : (isDark ? AppConstants.borderSlate : const Color(0xFFCBD5E1))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), fillPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: highlight ? AppConstants.medicalTeal : (isDark ? AppConstants.lightSlate : AppConstants.neutralGrey),
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
    return oldDelegate.selectedRobot != selectedRobot ||
        oldDelegate.selectedRobot.coordinates != selectedRobot.coordinates ||
        oldDelegate.selectedRobot.status != selectedRobot.status ||
        oldDelegate.currentWaypointIndex != currentWaypointIndex ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.isDark != isDark;
  }
}
