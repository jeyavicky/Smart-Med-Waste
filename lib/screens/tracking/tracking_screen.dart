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
    final currentRoute = robotProvider.currentRoute;
    final currentWaypointIndex = robotProvider.currentWaypointIndex;

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hospital Autonomous Transit Map',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
            ),
            Text(
              'Tracking: ${robot.name} (${robot.id}) • Destination: ${robot.destination}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppConstants.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Step Next Waypoint',
            icon: const Icon(Icons.skip_next_rounded, color: AppConstants.clinicalNavy),
            onPressed: () => robotProvider.stepAutonomousTransit(),
          ),
          IconButton(
            tooltip: 'Reset Route',
            icon: const Icon(Icons.replay_rounded, color: AppConstants.coolSlate),
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
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppConstants.cardBorder, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
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
                        color: robot.status.statusColor.withOpacity(0.12),
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
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                  color: robot.status.statusColor,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppConstants.clinicalNavy.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  robot.id,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.clinicalNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Current Location: ${robot.currentWard}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.statusNominal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.radar_rounded, size: 12, color: AppConstants.statusNominal),
                          SizedBox(width: 4),
                          Text(
                            'SLAM ACTIVE',
                            style: TextStyle(
                              color: AppConstants.statusNominal,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.4,
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
                          const Icon(Icons.flag_rounded, size: 14, color: AppConstants.clinicalNavy),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Target: ${robot.destination}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppConstants.clinicalNavy,
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
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: robotProvider.isAutoTraveling
                              ? AppConstants.clinicalNavy
                              : AppConstants.surfaceInteractive,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: robotProvider.isAutoTraveling
                                ? AppConstants.clinicalNavy
                                : AppConstants.dividerSubtle,
                          ),
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
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
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

          // Main Hospital Map Canvas - High Contrast 2D Floor Plan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Slate 100 Architectural canvas
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppConstants.dividerSubtle,
                    width: 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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
              color: AppConstants.cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border.all(color: AppConstants.cardBorder, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                          const Icon(Icons.alt_route_rounded, size: 16, color: AppConstants.clinicalNavy),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Transit Route: ${robot.destination}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppConstants.clinicalNavy,
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
                        minimumSize: const Size(0, 32),
                        backgroundColor: AppConstants.clinicalNavy,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      icon: const Icon(Icons.navigation_rounded, size: 12),
                      label: const Text('STEP TRANSIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
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
                          borderRadius: BorderRadius.circular(8),
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
        ? AppConstants.clinicalNavy
        : (isPassed ? AppConstants.statusNominal : AppConstants.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppConstants.clinicalNavy.withOpacity(0.08)
            : (isPassed ? AppConstants.statusNominal.withOpacity(0.08) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent
              ? AppConstants.clinicalNavy
              : (isPassed ? AppConstants.statusNominal : AppConstants.dividerSubtle),
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
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                  color: isCurrent ? AppConstants.clinicalNavy : AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider({required bool isPassed}) {
    return Container(
      width: 14,
      height: 2,
      color: isPassed ? AppConstants.statusNominal : AppConstants.dividerSubtle,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Custom painter for schematic 2D clinical hospital floor plan, AMRs, and active autonomous route
class _HospitalCorridorMapPainter extends CustomPainter {
  final RobotModel selectedRobot;
  final List<RobotModel> fleet;
  final List<RobotRouteStep> currentRoute;
  final int currentWaypointIndex;
  final double pulseProgress;

  _HospitalCorridorMapPainter({
    required this.selectedRobot,
    required this.fleet,
    required this.currentRoute,
    required this.currentWaypointIndex,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 320.0;
    final scaleY = size.height / 340.0;

    // Background architectural grid
    final gridPaint = Paint()
      ..color = AppConstants.dividerSubtle.withOpacity(0.5)
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += 25) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Room 1: ICU Wing
    _drawRoom(canvas, Rect.fromLTWH(20 * scaleX, 20 * scaleY, 90 * scaleX, 80 * scaleY), 'ICU WARD');

    // Room 2: Operation Theatres (OT 1-4)
    _drawRoom(canvas, Rect.fromLTWH(180 * scaleX, 20 * scaleY, 110 * scaleX, 80 * scaleY), 'OT COMPLEX');

    // Room 3: Pathology Lab
    _drawRoom(canvas, Rect.fromLTWH(20 * scaleX, 180 * scaleY, 90 * scaleX, 90 * scaleY), 'PATH LAB');

    // Room 4: Central Waste Disposal Facility
    _drawRoom(
      canvas,
      Rect.fromLTWH(180 * scaleX, 200 * scaleY, 120 * scaleX, 110 * scaleY),
      'CENTRAL BIO DISPOSAL',
      highlight: true,
    );

    // Dynamic Route Path for Currently Selected Robot
    if (currentRoute.isNotEmpty) {
      final pathPaint = Paint()
        ..color = AppConstants.medicalTeal.withOpacity(0.7)
        ..strokeWidth = 2.5
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

        final dotPaint = Paint()
          ..color = isDest
              ? AppConstants.statusNominal
              : (isCurrent
                  ? AppConstants.clinicalNavy
                  : (isPassed ? AppConstants.statusNominal : AppConstants.coolSlate))
          ..style = PaintingStyle.fill;

        canvas.drawCircle(pt, isCurrent ? 5.5 : 3.5, dotPaint);

        if (isCurrent) {
          final ringPaint = Paint()
            ..color = AppConstants.clinicalNavy.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5;
          canvas.drawCircle(pt, 9.0, ringPaint);
        }
      }
    }

    // Render other fleet robots on map
    for (final bot in fleet) {
      if (bot.id == selectedRobot.id) continue;
      final bx = bot.coordinates.x * scaleX;
      final by = bot.coordinates.y * scaleY;

      final botPaint = Paint()
        ..color = AppConstants.coolSlate
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(bx, by), 7, botPaint);

      final textSpan = TextSpan(
        text: bot.id,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(bx - textPainter.width / 2, by - textPainter.height / 2));
    }

    // Selected Active AMR Rendering with Pulse
    final rx = selectedRobot.coordinates.x * scaleX;
    final ry = selectedRobot.coordinates.y * scaleY;

    // Pulse animation ring
    final pulsePaint = Paint()
      ..color = AppConstants.medicalTeal.withOpacity((1.0 - pulseProgress) * 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(rx, ry), 10 + (pulseProgress * 12), pulsePaint);

    // Selected AMR solid marker
    final selectedBotPaint = Paint()
      ..color = AppConstants.clinicalNavy
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(rx, ry), 10, selectedBotPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(rx, ry), 10, borderPaint);

    // AMR ID label inside marker
    final activeTextSpan = TextSpan(
      text: selectedRobot.id,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    );
    final activeTextPainter = TextPainter(
      text: activeTextSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    activeTextPainter.paint(canvas, Offset(rx - activeTextPainter.width / 2, ry - activeTextPainter.height / 2));
  }

  void _drawRoom(Canvas canvas, Rect rect, String name, {bool highlight = false}) {
    final fillPaint = Paint()
      ..color = highlight ? const Color(0xFFFEF3C7) : Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = highlight ? AppConstants.amberWarning : AppConstants.dividerSubtle
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);

    final textSpan = TextSpan(
      text: name,
      style: TextStyle(
        color: highlight ? AppConstants.amberWarning : AppConstants.clinicalNavy,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(rect.left + 8, rect.top + 8));
  }

  @override
  bool shouldRepaint(covariant _HospitalCorridorMapPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.selectedRobot.id != selectedRobot.id ||
        oldDelegate.currentWaypointIndex != currentWaypointIndex;
  }
}
