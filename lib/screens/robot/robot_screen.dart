import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/robot_provider.dart';
import '../../widgets/battery_gauge_card.dart';
import '../../widgets/robot_status_card.dart';
import '../../widgets/robot_fleet_selector.dart';
import '../tracking/tracking_screen.dart';

class RobotScreen extends StatelessWidget {
  const RobotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final robot = robotProvider.robot;

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Robot Telemetry & Diagnostics',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
            ),
            Text(
              'Node: ${robot.name} (${robot.id}) • ${robot.assignedWard}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Autonomous Map',
            icon: const Icon(Icons.map_outlined, color: AppConstants.clinicalNavy),
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
          // Persistent Multi-Robot Fleet Selector
          const RobotFleetSelector(),

          const SizedBox(height: 14),

          // Selected AMR Hero Status Card
          RobotStatusCard(
            robot: robot,
            robotProvider: robotProvider,
            onTapDetails: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
          ),

          const SizedBox(height: 14),

          // Battery & BMS Card
          BatteryGaugeCard(robot: robot),

          const SizedBox(height: 14),

          // Subsystem Health Diagnostics Checklist
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.health_and_safety_rounded, color: AppConstants.statusNominal, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Subsystem Diagnostics Checklist',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppConstants.clinicalNavy,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppConstants.statusNominal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ALL PASS ✓',
                        style: TextStyle(
                          color: AppConstants.statusNominal,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),

                _diagnosticRow(
                  name: 'Drive Motors & BLDC Controllers',
                  spec: 'Dual 24V Planetary Geared Motors • Zero Backlash',
                  statusOk: robot.health.driveMotors,
                ),
                _diagnosticRow(
                  name: 'LiDAR & Depth Perception',
                  spec: '360° 16-Beam LiDAR + RealSense RGB-D Optical Flow',
                  statusOk: robot.health.lidarDepthSensors,
                ),
                _diagnosticRow(
                  name: 'Onboard AI Edge Vision Camera',
                  spec: 'Sony IMX335 5MP • TensorRT Model @ 45 FPS',
                  statusOk: robot.health.aiVisionCamera,
                ),
                _diagnosticRow(
                  name: 'Precision Load Cells (Weight Sensing)',
                  spec: '5x Strain Gauge HX711 ADCs • ±1g Precision',
                  statusOk: robot.health.loadCells,
                ),
                _diagnosticRow(
                  name: '5-Chamber Hermetic Locking Solenoids',
                  spec: 'IP67 Bio-Seal Interlocks & UV-C 254nm Lamp Active',
                  statusOk: robot.health.internalLocking,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Autonomous Corridor Transit Shortcut Card
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.clinicalNavy.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore_outlined, color: AppConstants.clinicalNavy, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hospital Corridor SLAM Map',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppConstants.clinicalNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Real-time autonomous routing, obstacle avoidance & waypoint progression',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppConstants.coolSlate),
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
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusOk
                  ? AppConstants.statusNominal.withOpacity(0.12)
                  : AppConstants.crimsonDanger.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusOk ? Icons.check_rounded : Icons.close_rounded,
              size: 13,
              color: statusOk ? AppConstants.statusNominal : AppConstants.crimsonDanger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppConstants.clinicalNavy,
                  ),
                ),
                Text(
                  spec,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (statusOk ? AppConstants.statusNominal : AppConstants.crimsonDanger)
                  .withOpacity(0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusOk ? 'NOMINAL' : 'FAULT',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: statusOk ? AppConstants.statusNominal : AppConstants.crimsonDanger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
