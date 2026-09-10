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
    final isWarning = robot.batteryPercent <= AppConstants.batteryWarningThreshold;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? AppConstants.amberWarning : AppConstants.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
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
                        borderRadius: BorderRadius.circular(8),
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
                          const Text(
                            'Power & Battery BMS',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppConstants.clinicalNavy,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'LiFePO4 4S 24Ah Clinical Pack • ${robot.name}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppConstants.textSecondary,
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
                  color: AppConstants.statusNominal.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppConstants.statusNominal.withOpacity(0.3)),
                ),
                child: const Text(
                  'HEALTH: 99%',
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

          const SizedBox(height: 16),

          // Main Battery Percentage Big Display + Runtime
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatBattery(robot.batteryPercent),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: isWarning ? AppConstants.amberWarning : AppConstants.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Formatters.formatRuntimeEstimate(robot.batteryPercent)} remaining',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppConstants.clinicalNavy,
                      ),
                    ),
                    const Text(
                      'Estimated standby ~14.2h',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Rounded linear progress indicator (minHeight: 8.0, borderRadius: BorderRadius.circular(4))
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (robot.batteryPercent / 100.0).clamp(0.0, 1.0),
              minHeight: 8.0,
              backgroundColor: AppConstants.surfaceInteractive,
              valueColor: AlwaysStoppedAnimation<Color>(
                isWarning ? AppConstants.amberWarning : AppConstants.medicalTeal,
              ),
            ),
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 12),

          // Telemetry Grid: Voltage, Current, Cell Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricTile(
                icon: Icons.electric_bolt_rounded,
                label: 'VOLTAGE',
                value: Formatters.formatVoltage(robot.voltage),
              ),
              _metricTile(
                icon: Icons.speed_rounded,
                label: 'CURRENT DRAW',
                value: Formatters.formatCurrent(robot.currentAmps),
              ),
              _metricTile(
                icon: Icons.thermostat_rounded,
                label: 'CELL TEMP',
                value: Formatters.formatTemperature(robot.temperatureC),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: AppConstants.coolSlate),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: AppConstants.textPrimary,
          ),
        ),
      ],
    );
  }
}
