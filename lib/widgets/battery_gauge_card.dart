import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/robot_model.dart';

class BatteryGaugeCard extends StatelessWidget {
  final RobotModel robot;

  const BatteryGaugeCard({
    super.key,
    required this.robot,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarning = robot.batteryPercent <= AppConstants.batteryWarningThreshold;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceSlate : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isWarning
              ? AppConstants.amberWarning
              : (isDark ? AppConstants.borderSlate : AppConstants.cardBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isWarning ? AppConstants.amberWarning : AppConstants.medicalTeal)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isWarning
                            ? Icons.battery_alert_rounded
                            : Icons.battery_charging_full_rounded,
                        color: isWarning ? AppConstants.amberWarning : AppConstants.medicalTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Power & Battery BMS',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppConstants.clinicalNavy,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'LiFePO4 4S 24Ah Clinical Pack • ${robot.name}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HEALTH: 99%',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main Battery Percentage Big Display + Runtime
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatBattery(robot.batteryPercent),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: isWarning ? AppConstants.amberWarning : AppConstants.clinicalNavy,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Formatters.formatRuntimeEstimate(robot.batteryPercent)} remaining',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                    Text(
                      'Estimated standby ~14.2h',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (robot.batteryPercent / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF334155) : AppConstants.cardBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isWarning ? AppConstants.amberWarning : AppConstants.medicalTeal,
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Telemetry Grid: Voltage, Current, Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricTile(
                icon: Icons.electric_bolt_rounded,
                label: 'VOLTAGE',
                value: Formatters.formatVoltage(robot.voltage),
                isDark: isDark,
              ),
              _metricTile(
                icon: Icons.speed_rounded,
                label: 'CURRENT DRAW',
                value: Formatters.formatCurrent(robot.currentAmps),
                isDark: isDark,
              ),
              _metricTile(
                icon: Icons.thermostat_rounded,
                label: 'CELL TEMP',
                value: Formatters.formatTemperature(robot.temperatureC),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppConstants.clinicalNavy,
          ),
        ),
      ],
    );
  }
}
