import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/compartment_model.dart';
import '../models/waste_item_model.dart';

class CompartmentBarWidget extends StatelessWidget {
  final CompartmentModel compartment;
  final VoidCallback? onTap;

  const CompartmentBarWidget({
    super.key,
    required this.compartment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWarning = compartment.isWarning;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWarning
                ? AppConstants.amberWarning
                : (isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0)),
            width: isWarning ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category Icon + Title + Status Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: compartment.color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: compartment.color.withOpacity(0.5),
                    ),
                  ),
                  child: Icon(
                    compartment.category.icon,
                    color: compartment.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compartment.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        compartment.category.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: compartment.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gate Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: compartment.gateStatus == GateStatus.actuating
                        ? AppConstants.amberWarning.withOpacity(0.2)
                        : (isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: compartment.gateStatus == GateStatus.actuating
                          ? AppConstants.amberWarning
                          : (isDark ? AppConstants.borderSlate : const Color(0xFFCBD5E1)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        compartment.gateStatus == GateStatus.actuating
                            ? Icons.sync_rounded
                            : Icons.lock_outline_rounded,
                        size: 11,
                        color: compartment.gateStatus == GateStatus.actuating
                            ? AppConstants.amberWarning
                            : (isDark ? AppConstants.lightSlate : AppConstants.neutralGrey),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        compartment.gateStatus == GateStatus.actuating
                            ? 'ACTUATING'
                            : 'SEALED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: compartment.gateStatus == GateStatus.actuating
                              ? AppConstants.amberWarning
                              : (isDark ? AppConstants.lightSlate : AppConstants.neutralGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Metrics row: Fill percent + Weight + Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${(compartment.fillPercentage * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isWarning ? AppConstants.amberWarning : compartment.accentColor,
                      ),
                    ),
                    if (isWarning) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.amberWarning.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEARING CAPACITY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppConstants.amberWarning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${Formatters.formatWeight(compartment.currentKg)} / ${compartment.maxKg.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: compartment.fillPercentage,
                minHeight: 6,
                backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isWarning ? AppConstants.amberWarning : compartment.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
