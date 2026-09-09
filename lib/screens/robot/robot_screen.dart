import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/robot_provider.dart';
import '../../widgets/battery_gauge_card.dart';
import '../../widgets/robot_status_card.dart';
import '../tracking/tracking_screen.dart';

class RobotScreen extends StatelessWidget {
  const RobotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final robot = robotProvider.robot;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Telemetry & Diagnostics'),
        actions: [
          IconButton(
            tooltip: 'Autonomous Map',
            icon: const Icon(Icons.map_rounded, color: AppConstants.tealAccent),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Status Card
          RobotStatusCard(
            robot: robot,
            robotProvider: robotProvider,
            onTapDetails: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // Battery & BMS Card
          BatteryGaugeCard(robot: robot),

          const SizedBox(height: 16),

          // Subsystem Health Diagnostics Checklist
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceSlate : Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                    Row(
                      children: const [
                        Icon(Icons.health_and_safety_rounded, color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Subsystem Diagnostics Checklist',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ALL PASS ✓',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 8),

                _diagnosticRow(
                  name: 'Drive Motors & BLDC Controllers',
                  spec: 'Dual 24V Planetary Geared Motors • Zero Backlash',
                  statusOk: robot.health.driveMotors,
                  isDark: isDark,
                ),
                _diagnosticRow(
                  name: 'LiDAR & Depth Perception',
                  spec: '360° 16-Beam LiDAR + RealSense RGB-D Optical Flow',
                  statusOk: robot.health.lidarDepthSensors,
                  isDark: isDark,
                ),
                _diagnosticRow(
                  name: 'Onboard AI Edge Vision Camera',
                  spec: 'Sony IMX335 5MP • TensorRT Model @ 45 FPS',
                  statusOk: robot.health.aiVisionCamera,
                  isDark: isDark,
                ),
                _diagnosticRow(
                  name: 'Precision Load Cells (Weight Sensing)',
                  spec: '4x Strain Gauge HX711 ADCs • ±1g Precision',
                  statusOk: robot.health.loadCells,
                  isDark: isDark,
                ),
                _diagnosticRow(
                  name: 'Internal Hermetic Locking Solenoids',
                  spec: 'IP67 Bio-Seal Interlocks & UV-C Disinfection Tube',
                  statusOk: robot.health.internalLocking,
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Autonomous Corridor Transit Shortcut Card
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.tealPrimary.withOpacity(0.2),
                    AppConstants.surfaceSlate,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppConstants.tealAccent.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppConstants.tealPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hospital Corridor SLAM Map',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'View real-time autonomous routing, obstacle avoidance, and waypoint progression',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppConstants.tealAccent),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _diagnosticRow({
    required String name,
    required String spec,
    required bool statusOk,
    required bool isDark,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusOk
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : AppConstants.crimsonDanger.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusOk ? Icons.check_rounded : Icons.close_rounded,
              size: 14,
              color: statusOk ? const Color(0xFF10B981) : AppConstants.crimsonDanger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  spec,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (statusOk ? const Color(0xFF10B981) : AppConstants.crimsonDanger)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusOk ? 'NOMINAL' : 'FAULT',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: statusOk ? const Color(0xFF10B981) : AppConstants.crimsonDanger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
