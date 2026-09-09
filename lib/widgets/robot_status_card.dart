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

    return InkWell(
      onTap: onTapDetails,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: robot.status == RobotStatus.emergencyStop
                ? AppConstants.crimsonDanger
                : (isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0)),
            width: robot.status == RobotStatus.emergencyStop ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: (robot.status == RobotStatus.emergencyStop
                      ? AppConstants.crimsonDanger
                      : AppConstants.tealPrimary)
                  .withOpacity(isDark ? 0.12 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Robot Name + Online Indicator + Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: robot.status.statusColor.withOpacity(0.15),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Pulsing online dot
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
                        'ID: ${robot.id} • ${robot.currentWard}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
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
                    color: robot.status.statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: robot.status.statusColor.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    robot.status.displayName,
                    style: TextStyle(
                      color: robot.status.statusColor,
                      fontWeight: FontWeight.w700,
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

            // Battery + Telemetry stats row
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
                            robot.batteryPercent > 20
                                ? Icons.battery_charging_full_rounded
                                : Icons.battery_alert_rounded,
                            size: 16,
                            color: robot.batteryPercent > 20
                                ? AppConstants.tealAccent
                                : AppConstants.crimsonDanger,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            Formatters.formatBattery(robot.batteryPercent),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${Formatters.formatRuntimeEstimate(robot.batteryPercent)})',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
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
                              : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            robot.batteryPercent > 20
                                ? AppConstants.tealAccent
                                : AppConstants.crimsonDanger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Subsystems green check badge
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
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // E-Stop / Action Button
                if (robot.status == RobotStatus.emergencyStop)
                  ElevatedButton(
                    onPressed: () => robotProvider.resumeOperations(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text('RESUME', style: TextStyle(fontSize: 11)),
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
        backgroundColor: AppConstants.surfaceSlate,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppConstants.crimsonDanger),
            SizedBox(width: 8),
            Text('Trigger E-STOP?'),
          ],
        ),
        content: const Text(
          'This will immediately cut motor power, lock all waste diverter gates, and notify hospital safety officers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.triggerEmergencyStop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.crimsonDanger,
            ),
            child: const Text('STOP ROBOT NOW'),
          ),
        ],
      ),
    );
  }
}
