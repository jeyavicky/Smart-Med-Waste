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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.isAcknowledged
              ? AppConstants.cardBorder
              : alert.level.color.withOpacity(0.5),
          width: alert.isAcknowledged ? 1.2 : 1.5,
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
          // Header: Level Badge + Time + Subsystem
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: alert.level.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
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
                        fontWeight: FontWeight.w700,
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
                style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                Formatters.formatRelativeTime(alert.timestamp),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.textSecondary,
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
              fontSize: 13.5,
              color: alert.isAcknowledged
                  ? AppConstants.textSecondary
                  : AppConstants.clinicalNavy,
            ),
          ),

          const SizedBox(height: 3),

          // Message
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textBody,
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
                style: const TextStyle(fontSize: 10, color: AppConstants.coolSlate),
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
                    Icon(Icons.done_all_rounded, size: 14, color: AppConstants.statusNominal),
                    SizedBox(width: 4),
                    Text(
                      'Acknowledged',
                      style: TextStyle(fontSize: 11, color: AppConstants.statusNominal, fontWeight: FontWeight.w600),
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
