import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/fleet_provider.dart';
import '../../providers/mission_provider.dart';
import '../../models/robot_model.dart';
import '../../widgets/corridor_schematic_canvas.dart';

class RobotsScreen extends StatelessWidget {
  const RobotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();
    final missionProv = context.watch<MissionProvider>();
    final activeRobot = fleet.selectedRobot;
    final score = fleet.calculateScore(activeRobot);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FLEET DISPATCH & AMR TELEMETRY'),
        actions: [
          IconButton(
            icon: Icon(
              fleet.isAutoAssignmentEnabled ? Icons.auto_awesome : Icons.tune_rounded,
              color: AppTheme.primaryTeal,
            ),
            tooltip: 'Smart Assignment Engine',
            onPressed: () {
              fleet.toggleAutoAssignment(!fleet.isAutoAssignmentEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    fleet.isAutoAssignmentEnabled
                        ? 'Intelligent Auto-Assignment: ACTIVE'
                        : 'Manual Override Mode: ACTIVE',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Live Corridor Schematic Map Canvas
            CorridorSchematicCanvas(
              robots: fleet.robotList,
              selectedRobotId: fleet.selectedRobotId,
              activeMission: missionProv.activeMission,
              onRobotSelected: (id) => fleet.selectRobot(id),
            ),
            const SizedBox(height: 16),

            // 2. Robot Selector Tabs (R01–R04)
            Row(
              children: fleet.robotList.map((r) {
                final isSelected = r.id == fleet.selectedRobotId;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => fleet.selectRobot(r.id),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryTeal : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryTeal : AppTheme.borderSubtle,
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            r.id,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${r.batteryLevel}% Bat',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 3. Smart Assignment Scoring Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_alt_rounded, size: 18, color: AppTheme.primaryTeal),
                            const SizedBox(width: 6),
                            Text(
                              'SMART ASSIGNMENT SCORE (${activeRobot.id})',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AppTheme.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${score.totalScore} / 100 PTS',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Algorithm: Fill Level (${score.fillScore}) + Risk (${score.riskScore}) + Dept Priority (${score.priorityScore}) + Battery/ETA (${score.batteryEtaScore})',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfacePorcelain,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.primaryTeal),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              score.rationale,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 4. 5 Internal Compartments Status
            Text(
              '5 INTERNAL VAULTS / COMPARTMENTS (${activeRobot.id})',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
            ),
            const SizedBox(height: 10),
            Column(
              children: activeRobot.compartments.values.map((comp) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: comp.lightColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderSubtle, width: 1.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: comp.badgeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                comp.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: comp.badgeColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${comp.currentWeightKg.toStringAsFixed(1)} / ${comp.capacityKg.toStringAsFixed(0)} kg (${comp.fillPercentage}%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: comp.badgeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: comp.fillRatio,
                        backgroundColor: Colors.white70,
                        valueColor: AlwaysStoppedAnimation<Color>(comp.badgeColor),
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 5. Telemetry & Subsystem Diagnostics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUBSYSTEM HEALTH & SENSORS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMuted,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _buildSubsystemRow('LiDAR & Depth SLAM', activeRobot.health.lidarDepthSensors),
                    _buildSubsystemRow('YOLO AI Inspection Camera', activeRobot.health.aiVisionCamera),
                    _buildSubsystemRow('Brushless Drive Motors', activeRobot.health.driveMotors),
                    _buildSubsystemRow('Load Cell Weight Sensors', activeRobot.health.loadCells),
                    _buildSubsystemRow('Hermetic Bio-Seal Gate Locks', activeRobot.health.internalLocking),
                    const Divider(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text('Core Temp: ${activeRobot.temperatureC.toStringAsFixed(1)}°C', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Text('Current Draw: ${activeRobot.currentAmps.toStringAsFixed(1)} A', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        Text('Location: ${activeRobot.assignedWard}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Action Controls (Emergency Stop / Recall)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                    ),
                    onPressed: () {
                      fleet.recallToDisposalBay(activeRobot.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${activeRobot.id} recalled to Disposal Bay')),
                      );
                    },
                    icon: const Icon(Icons.home_repair_service_rounded, size: 16),
                    label: const Text('RECALL TO BAY'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.plasticColor),
                      foregroundColor: AppTheme.plasticColor,
                    ),
                    onPressed: () {
                      fleet.triggerEmergencyStop(activeRobot.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('E-Stop Toggled for ${activeRobot.id}')),
                      );
                    },
                    icon: const Icon(Icons.dangerous_rounded, size: 16),
                    label: Text(activeRobot.status == RobotStatus.offline ? 'RESUME ROVER' : 'EMERGENCY STOP'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubsystemRow(String label, bool isHealthy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMain)),
          Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 15,
                color: isHealthy ? AppTheme.sageEmerald : AppTheme.plasticColor,
              ),
              const SizedBox(width: 4),
              Text(
                isHealthy ? 'NOMINAL' : 'FAULT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isHealthy ? AppTheme.sageEmerald : AppTheme.plasticColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
