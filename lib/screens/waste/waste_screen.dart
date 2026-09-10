import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/robot_model.dart';
import '../../models/waste_item_model.dart';
import '../../providers/robot_provider.dart';
import '../../providers/waste_analytics_provider.dart';
import '../../widgets/compartment_bar_widget.dart';
import '../../widgets/robot_fleet_selector.dart';
import 'ai_detection_screen.dart';
import '../history/history_screen.dart';

class WasteScreen extends StatelessWidget {
  const WasteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final wasteProvider = context.watch<WasteAnalyticsProvider>();
    final robot = robotProvider.robot;
    final recentItems = wasteProvider.detectedItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Waste Segregation & Compartments',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            Text(
              'Active Node: ${robot.name} (${robot.id})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'CPCB Traceability Ledger',
            icon: const Icon(Icons.receipt_long_rounded, color: AppConstants.medicalTeal),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Persistent Multi-Robot Fleet Selector
          const RobotFleetSelector(),

          const SizedBox(height: 16),

          // Launch Live AI Vision Banner
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.clinicalNavy, Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.clinicalNavy.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.medicalTeal.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Open Onboard AI Vision HUD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Inspect real-time camera feed, targeting reticle & 5-way mechanical gating',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Anti-Contamination Feature Callout Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceSlate : const Color(0xFFF3E8FF).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppConstants.unknownBadge.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.unknownBadge.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppConstants.unknownBadge,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anti-Contamination Chamber #5 Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.unknownBadge,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Low-confidence or non-biomedical unrecognized items are diverted into the Unknown / Others compartment, preventing contamination of standard biomedical waste streams.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppConstants.lightSlate : AppConstants.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 5 Sealed Compartments Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5 Standard Biomedical Compartments',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppConstants.clinicalNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Load cells calibrated • Hermetic bio-seal active on ${robot.id}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => wasteProvider.resetCompartments(),
                icon: const Icon(Icons.restore_from_trash_rounded, size: 16),
                label: const Text('EMPTY AT DOCK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 5 Compartment Bars of selected AMR
          ...robot.compartments.values.map(
            (comp) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CompartmentBarWidget.fromCompartment(
                compartment: comp,
                onTap: () {
                  _showCompartmentDetailDialog(context, comp);
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Segregation Activity Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent AI Segregation Logs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppConstants.clinicalNavy,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                child: const Text('View All Ledger', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Recent items list
          ...recentItems.take(5).map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.surfaceSlate : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.category.badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.category.icon, color: item.category.badgeColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.detectedObject,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? Colors.white : AppConstants.clinicalNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category.displayName} • ${Formatters.formatRelativeTime(item.timestamp)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatWeight(item.weightKg),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: isDark ? Colors.white : AppConstants.clinicalNavy,
                          ),
                        ),
                        Text(
                          '${(item.confidence * 100).toStringAsFixed(0)}% conf',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.confidence >= 0.7 ? const Color(0xFF10B981) : AppConstants.amberWarning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showCompartmentDetailDialog(BuildContext context, Compartment comp) {
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: comp.badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.inventory_2_rounded, color: comp.badgeColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                comp.name,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppConstants.clinicalNavy),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow('Chamber ID', comp.id.toUpperCase()),
            _dialogRow('Current Load', '${Formatters.formatWeight(comp.currentWeightKg)} / ${comp.capacityKg} kg'),
            _dialogRow('Fill Percentage', '${comp.fillPercentage}%'),
            _dialogRow('Hermetic Bio-Seal', 'SECURE (Negative Pressure Differential)'),
            _dialogRow('Internal Sterilizer', 'UV-C 254nm Tube Active'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.medicalTeal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('DISMISS', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppConstants.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
