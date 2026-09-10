import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../models/robot_model.dart';
import '../providers/robot_provider.dart';

class RobotFleetSelector extends StatelessWidget {
  const RobotFleetSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final fleet = robotProvider.fleet;
    final selectedId = robotProvider.selectedRobotId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceSlate : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Fleet Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppConstants.medicalTeal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hub_rounded,
                      color: AppConstants.medicalTeal,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FLEET ORCHESTRATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: AppConstants.clinicalNavy,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '4 AMRs ONLINE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Selected: $selectedId',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.medicalTeal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal Carousel of 4 AMRs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: fleet.map((bot) {
                final isSelected = bot.id == selectedId;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () => robotProvider.selectRobot(bot.id),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 148,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppConstants.tealPrimary.withOpacity(0.15)
                                : const Color(0xFFF0FDFA))
                            : (isDark
                                ? const Color(0xFF131D31)
                                : AppConstants.surfaceInteractive),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppConstants.medicalTeal
                              : (isDark
                                  ? AppConstants.borderSlate
                                  : AppConstants.cardBorder),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppConstants.medicalTeal.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: ID + Status Dot
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                bot.id,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppConstants.medicalTeal
                                      : (isDark ? Colors.white : AppConstants.clinicalNavy),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bot.status.statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Short Ward Name
                          Text(
                            _formatWardShort(bot.assignedWard),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppConstants.lightSlate : AppConstants.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Bottom Row: Status Badge + Battery %
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: bot.status.statusColor.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _statusShort(bot.status),
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: bot.status.statusColor,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    bot.batteryLevel > 20
                                        ? Icons.battery_charging_full_rounded
                                        : Icons.battery_alert_rounded,
                                    size: 11,
                                    color: bot.batteryLevel > 20
                                        ? (isDark ? AppConstants.tealAccent : AppConstants.medicalTeal)
                                        : AppConstants.crimsonDanger,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${bot.batteryLevel}%',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatWardShort(String ward) {
    if (ward.contains('ICU')) return 'ICU Wing';
    if (ward.contains('OT') || ward.contains('Surgery')) return 'Surgery OT';
    if (ward.contains('Bay') || ward.contains('Basement')) return 'Central Bay';
    if (ward.contains('Ward 3') || ward.contains('General')) return 'General Ward';
    return ward;
  }

  static String _statusShort(RobotStatus status) {
    switch (status) {
      case RobotStatus.collecting:
        return 'ACTIVE';
      case RobotStatus.enRoute:
        return 'TRANSIT';
      case RobotStatus.docked:
        return 'DOCKED';
      case RobotStatus.idle:
        return 'STANDBY';
      case RobotStatus.discharging:
        return 'DISCHARGE';
      case RobotStatus.offline:
        return 'OFFLINE';
    }
  }
}
