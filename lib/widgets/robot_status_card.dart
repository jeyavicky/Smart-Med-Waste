import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/robot_model.dart';
import '../providers/robot_provider.dart';

class RobotStatusCard extends StatelessWidget {
  final RobotModel robot;
  final RobotProvider robotProvider;
  final VoidCallback? onTapDetails;

  const RobotStatusCard({
    super.key,
    required this.robot,
    required this.robotProvider,
    this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isOffline = robot.status == RobotStatus.offline;

    return InkWell(
      onTap: onTapDetails,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstants.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isOffline ? AppConstants.crimsonDanger : AppConstants.cardBorder,
            width: isOffline ? 1.5 : 1.0,
          ),
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
            // Top Row: Robot Avatar + Name + Assigned Ward + Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: robot.status.statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    robot.status.icon,
                    color: robot.status.statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              robot.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppConstants.clinicalNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: robot.isOnline
                                  ? AppConstants.statusNominal
                                  : AppConstants.neutralGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Node ${robot.id} • ${robot.assignedWard}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppConstants.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: robot.status.statusColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: robot.status.statusColor.withOpacity(0.35),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    robot.status.displayName,
                    style: TextStyle(
                      color: robot.status.statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),

            // Battery + Subsystem Telemetry Row
            Row(
              children: [
                // Battery metric
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            robot.batteryLevel > 20
                                ? Icons.battery_charging_full_rounded
                                : Icons.battery_alert_rounded,
                            size: 16,
                            color: robot.batteryLevel > 20
                                ? AppConstants.medicalTeal
                                : AppConstants.crimsonDanger,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Formatters.formatBattery(robot.batteryPercent),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: -0.5,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${Formatters.formatRuntimeEstimate(robot.batteryPercent)})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (robot.batteryPercent / 100.0).clamp(0.0, 1.0),
                          minHeight: 8.0,
                          backgroundColor: AppConstants.surfaceInteractive,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            robot.batteryLevel > 20
                                ? AppConstants.medicalTeal
                                : AppConstants.crimsonDanger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Subsystems OK badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppConstants.statusNominal.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppConstants.statusNominal.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppConstants.statusNominal,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Subsystems OK',
                        style: TextStyle(
                          color: AppConstants.statusNominal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // E-Stop / Action Button
                if (robot.status == RobotStatus.offline)
                  ElevatedButton(
                    onPressed: () => robotProvider.resumeOperations(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.statusNominal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('RESUME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  )
                else
                  IconButton(
                    onPressed: () {
                      _showEmergencyStopDialog(context, robotProvider);
                    },
                    tooltip: 'Emergency Stop',
                    icon: const Icon(Icons.dangerous_rounded, color: AppConstants.crimsonDanger),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyStopDialog(BuildContext context, RobotProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppConstants.cardBorder),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppConstants.crimsonDanger),
            SizedBox(width: 8),
            Text(
              'Trigger AMR E-STOP?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
            ),
          ],
        ),
        content: Text(
          'This will immediately halt drive motors on ${robot.name} (${robot.id}), seal all 5 internal chambers, and broadcast an alert to Central Waste Command.',
          style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppConstants.dividerSubtle),
              minimumSize: const Size(0, 40),
            ),
            child: const Text('CANCEL', style: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.triggerEmergencyStop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.crimsonDangerLight,
              foregroundColor: AppConstants.crimsonDanger,
              side: const BorderSide(color: AppConstants.crimsonDanger, width: 1.0),
              minimumSize: const Size(0, 40),
            ),
            child: const Text('STOP ROBOT NOW', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
