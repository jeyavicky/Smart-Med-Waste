import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';
import '../models/compartment_model.dart';
import '../models/robot_model.dart';
import '../models/waste_item_model.dart';

class CompartmentBarWidget extends StatelessWidget {
  final String title;
  final String categoryName;
  final IconData icon;
  final Color badgeColor;
  final Color lightBgColor;
  final double currentKg;
  final double maxKg;
  final int fillPercentage;
  final bool isWarning;
  final GateStatus gateStatus;
  final VoidCallback? onTap;

  CompartmentBarWidget({
    super.key,
    required CompartmentModel compartment,
    this.onTap,
  })  : title = compartment.title,
        categoryName = compartment.category.displayName,
        icon = compartment.category.icon,
        badgeColor = compartment.category.badgeColor,
        lightBgColor = compartment.category.lightBgColor,
        currentKg = compartment.currentKg,
        maxKg = compartment.maxKg,
        fillPercentage = compartment.fillPercentInt,
        isWarning = compartment.isWarning,
        gateStatus = compartment.gateStatus;

  CompartmentBarWidget.fromCompartment({
    super.key,
    required Compartment compartment,
    this.onTap,
  })  : title = compartment.name,
        categoryName = _getCategoryDisplayName(compartment.id),
        icon = _getCategoryIcon(compartment.id),
        badgeColor = compartment.badgeColor,
        lightBgColor = compartment.lightColor,
        currentKg = compartment.currentWeightKg,
        maxKg = compartment.capacityKg,
        fillPercentage = compartment.fillPercentage,
        isWarning = compartment.isWarning,
        gateStatus = GateStatus.locked;

  static String _getCategoryDisplayName(String id) {
    switch (id.toLowerCase()) {
      case 'sharps':
        return 'SHARPS / BLADES';
      case 'infectious':
        return 'INFECTIOUS BIOHAZARD';
      case 'plastic':
        return 'PLASTIC / RECYCLABLE';
      case 'glassware':
        return 'GLASSWARE / CYTOTOXIC';
      case 'unknownothers':
      case 'unknown':
        return 'UNKNOWN / OTHERS';
      default:
        return 'SEGREGATED CHAMBER';
    }
  }

  static IconData _getCategoryIcon(String id) {
    switch (id.toLowerCase()) {
      case 'sharps':
        return Icons.content_cut_rounded;
      case 'infectious':
        return Icons.biotech_rounded;
      case 'plastic':
        return Icons.local_hospital_rounded;
      case 'glassware':
        return Icons.medication_rounded;
      case 'unknownothers':
      case 'unknown':
        return Icons.help_outline_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillRatio = (fillPercentage / 100.0).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : lightBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWarning
                ? AppConstants.amberWarning
                : (isDark ? AppConstants.borderSlate : badgeColor.withOpacity(0.35)),
            width: isWarning ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category Icon + Title + Gate Status Chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: badgeColor.withOpacity(0.4),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: badgeColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? Colors.white : AppConstants.clinicalNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Gate Status Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: gateStatus == GateStatus.actuating
                        ? AppConstants.amberWarning.withOpacity(0.2)
                        : (isDark ? const Color(0xFF131D31) : Colors.white),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: gateStatus == GateStatus.actuating
                          ? AppConstants.amberWarning
                          : badgeColor.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        gateStatus == GateStatus.actuating
                            ? Icons.sync_rounded
                            : Icons.lock_outline_rounded,
                        size: 11,
                        color: gateStatus == GateStatus.actuating
                            ? AppConstants.amberWarning
                            : badgeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        gateStatus == GateStatus.actuating ? 'ACTUATING' : 'SEALED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: gateStatus == GateStatus.actuating
                              ? AppConstants.amberWarning
                              : badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Metrics row: Fill percent + Weight + Warning Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '$fillPercentage%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isWarning ? AppConstants.amberWarning : badgeColor,
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
                  '${Formatters.formatWeight(currentKg)} / ${maxKg.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fillRatio,
                minHeight: 6,
                backgroundColor: isDark
                    ? const Color(0xFF334155)
                    : Colors.white.withOpacity(0.7),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isWarning ? AppConstants.amberWarning : badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
