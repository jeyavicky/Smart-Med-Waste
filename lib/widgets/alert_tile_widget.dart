import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/alert_model.dart';

class AlertTileWidget extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onAcknowledge;

  const AlertTileWidget({
    super.key,
    required this.alert,
    this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceSlate : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alert.isAcknowledged
              ? (isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0))
              : alert.level.color.withOpacity(0.5),
          width: alert.isAcknowledged ? 1.0 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Level Badge + Time + Subsystem
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.level.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(alert.level.icon, color: alert.level.color, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      alert.level.displayName,
                      style: TextStyle(
                        color: alert.level.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                alert.relatedSubsystem,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                Formatters.formatRelativeTime(alert.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Title
          Text(
            alert.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: alert.isAcknowledged
                  ? (isDark ? AppConstants.lightSlate : Colors.black87)
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),

          const SizedBox(height: 4),

          // Message
          Text(
            alert.message,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 10),

          // Footer: Acknowledge status / action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Formatters.formatDateTime(alert.timestamp),
                style: const TextStyle(fontSize: 10, color: AppConstants.neutralGrey),
              ),
              if (!alert.isAcknowledged && onAcknowledge != null)
                TextButton.icon(
                  onPressed: onAcknowledge,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(0, 28),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 14),
                  label: const Text('ACKNOWLEDGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                )
              else
                Row(
                  children: const [
                    Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'Acknowledged',
                      style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
