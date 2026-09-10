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

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Waste Segregation & Compartments',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
            ),
            Text(
              'Active Node: ${robot.name} (${robot.id})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'CPCB Traceability Ledger',
            icon: const Icon(Icons.receipt_long_outlined, color: AppConstants.clinicalNavy),
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

          const SizedBox(height: 14),

          // Launch Live AI Vision Banner
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppConstants.clinicalNavy,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 22,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Camera feed, targeting reticle & 5-way mechanical diverters',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Anti-Contamination Feature Callout Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppConstants.unknownLightBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppConstants.unknownBadge.withOpacity(0.35),
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Anti-Contamination Chamber #5 Active',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.unknownBadge,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Low-confidence or non-biomedical unrecognized items are diverted into Chamber #5 (General / Unclassified), preventing contamination of standard biomedical waste streams.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppConstants.textBody,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppConstants.clinicalNavy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Strain gauge load cells calibrated • Hermetic bio-seal on ${robot.id}',
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
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => wasteProvider.resetCompartments(),
                icon: const Icon(Icons.restore_from_trash_outlined, size: 15),
                label: const Text('EMPTY AT BAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),

          const SizedBox(height: 10),

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
              const Text(
                'Recent AI Segregation Logs',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.clinicalNavy,
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
                  color: AppConstants.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppConstants.cardBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
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
                        color: item.category.lightBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: item.category.badgeColor.withOpacity(0.3)),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppConstants.clinicalNavy,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category.displayName} • ${Formatters.formatRelativeTime(item.timestamp)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppConstants.textSecondary,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: -0.3,
                            color: AppConstants.textPrimary,
                          ),
                        ),
                        Text(
                          '${(item.confidence * 100).toStringAsFixed(0)}% conf',
                          style: TextStyle(
                            fontSize: 10,
                            color: item.confidence >= 0.70 ? AppConstants.statusNominal : AppConstants.amberWarning,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showCompartmentDetailDialog(BuildContext context, Compartment comp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfacePorcelain,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppConstants.cardBorder, width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: comp.badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppConstants.clinicalNavy, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                comp.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogRow('Chamber Stream', comp.id.toUpperCase()),
            _dialogRow('Current Load', '${Formatters.formatWeight(comp.currentWeightKg)} / ${comp.capacityKg} kg'),
            _dialogRow('Fill Ratio', '${comp.fillPercentage}%'),
            _dialogRow('Hermetic Bio-Seal', 'SECURE (Differential Pressure Active)'),
            _dialogRow('Disinfection Subsystem', 'UV-C 254nm Tube Active'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.clinicalNavy,
              minimumSize: const Size(0, 40),
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
              style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
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
