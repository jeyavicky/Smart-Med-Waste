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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOffline = robot.status == RobotStatus.offline;

    return InkWell(
      onTap: onTapDetails,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOffline
                ? AppConstants.crimsonDanger
                : (isDark ? AppConstants.borderSlate : AppConstants.cardBorder),
            width: isOffline ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (isOffline
                      ? AppConstants.crimsonDanger
                      : const Color(0xFF0F172A))
                  .withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
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
                    size: 22,
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
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isDark ? Colors.white : AppConstants.clinicalNavy,
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
                                  ? const Color(0xFF10B981)
                                  : AppConstants.neutralGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${robot.id} • ${robot.assignedWard}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: robot.status.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: robot.status.statusColor.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    robot.status.displayName,
                    style: TextStyle(
                      color: robot.status.statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppConstants.clinicalNavy,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${Formatters.formatRuntimeEstimate(robot.batteryPercent)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (robot.batteryPercent / 100.0).clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: isDark
                              ? const Color(0xFF334155)
                              : AppConstants.cardBorder,
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
                const SizedBox(width: 16),

                // Subsystems OK badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Subsystems OK',
                        style: TextStyle(
                          color: Color(0xFF10B981),
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
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
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
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppConstants.cardBorder),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppConstants.crimsonDanger),
            SizedBox(width: 8),
            Text(
              'Trigger AMR E-STOP?',
              style: TextStyle(fontWeight: FontWeight.w800, color: AppConstants.clinicalNavy),
            ),
          ],
        ),
        content: Text(
          'This will immediately halt drive motors on ${robot.name} (${robot.id}), seal all 5 internal chambers, and broadcast an alert to Central Waste Command.',
          style: const TextStyle(color: AppConstants.textPrimary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.triggerEmergencyStop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.crimsonDanger,
            ),
            child: const Text('STOP ROBOT NOW', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
