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
  })  : title = _getStandardTitle(compartment.id),
        categoryName = _getCategoryDisplayName(compartment.id),
        icon = _getCategoryIcon(compartment.id),
        badgeColor = _getCategoryBadgeColor(compartment.id),
        lightBgColor = _getCategoryLightBg(compartment.id),
        currentKg = compartment.currentWeightKg,
        maxKg = compartment.capacityKg,
        fillPercentage = compartment.fillPercentage,
        isWarning = compartment.fillPercentage >= 80,
        gateStatus = GateStatus.locked;

  static String _getStandardTitle(String id) {
    switch (id.toLowerCase()) {
      case 'sharps':
        return 'Sharps & Needles';
      case 'infectious':
        return 'Infectious Biohazard';
      case 'plastic':
        return 'Plastic / Recyclable';
      case 'glassware':
        return 'Glassware & Vials';
      case 'unknownothers':
      case 'unknown':
        return 'General / Unclassified';
      default:
        return 'Segregated Chamber';
    }
  }

  static String _getCategoryDisplayName(String id) {
    switch (id.toLowerCase()) {
      case 'sharps':
        return AppConstants.sharpsLabel;
      case 'infectious':
        return AppConstants.infectiousLabel;
      case 'plastic':
        return AppConstants.plasticLabel;
      case 'glassware':
        return AppConstants.glasswareLabel;
      case 'unknownothers':
      case 'unknown':
        return AppConstants.unknownLabel;
      default:
        return 'BIOMEDICAL WASTE';
    }
  }

  static Color _getCategoryBadgeColor(String id) {
    switch (id.toLowerCase()) {
      case 'sharps':
        return AppConstants.sharpsBadge;
      case 'infectious':
        return AppConstants.infectiousBadge;
      case 'plastic':
        return AppConstants.plasticBadge;
      case 'glassware':
        return AppConstants.glasswareBadge;
      case 'unknownothers':
      case 'unknown':
        return AppConstants.unknownBadge;
      default:
        return AppConstants.coolSlate;
    }
  }

  static Color _getCategoryLightBg(String id) {
    switch (id.toLowerCase()) {
      case 'sharps':
        return AppConstants.sharpsLightBg;
      case 'infectious':
        return AppConstants.infectiousLightBg;
      case 'plastic':
        return AppConstants.plasticLightBg;
      case 'glassware':
        return AppConstants.glasswareLightBg;
      case 'unknownothers':
      case 'unknown':
        return AppConstants.unknownLightBg;
      default:
        return AppConstants.surfaceInteractive;
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
    final fillRatio = (fillPercentage / 100.0).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: lightBgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isWarning
                ? AppConstants.amberWarning
                : badgeColor.withOpacity(0.40),
            width: isWarning ? 1.5 : 1.0,
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
            // Header: Category Icon + Title + Gate Status Chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: badgeColor.withOpacity(0.35),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppConstants.clinicalNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
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
                        ? AppConstants.amberWarning.withOpacity(0.18)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: gateStatus == GateStatus.actuating
                          ? AppConstants.amberWarning
                          : badgeColor.withOpacity(0.3),
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
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
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
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: isWarning ? AppConstants.amberWarning : AppConstants.textPrimary,
                      ),
                    ),
                    if (isWarning) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.amberWarning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppConstants.amberWarning.withOpacity(0.4),
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'CAPACITY ALERT >80%',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppConstants.amberWarning,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${Formatters.formatWeight(currentKg)} / ${maxKg.toStringAsFixed(0)} kg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Rounded linear progress indicator (minHeight: 8.0, borderRadius: BorderRadius.circular(4))
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fillRatio,
                minHeight: 8.0,
                backgroundColor: Colors.white,
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
