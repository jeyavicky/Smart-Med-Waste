import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/waste_item_model.dart';
import '../../providers/waste_analytics_provider.dart';
import '../../widgets/compartment_bar_widget.dart';
import 'ai_detection_screen.dart';
import '../history/history_screen.dart';

class WasteScreen extends StatelessWidget {
  const WasteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wasteProvider = context.watch<WasteAnalyticsProvider>();
    final compartments = wasteProvider.compartments;
    final recentItems = wasteProvider.detectedItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Segregation & Compartments'),
        actions: [
          IconButton(
            tooltip: 'CPCB Traceability Ledger',
            icon: const Icon(Icons.receipt_long_rounded, color: AppConstants.tealAccent),
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
                  colors: [Color(0xFF0F766E), AppConstants.tealPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.tealPrimary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Open Onboard AI Vision HUD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Inspect real-time camera feed, targeting reticle & mechanical divert gating',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
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

          const SizedBox(height: 20),

          // 4 Sealed Compartments Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '4 Standard Biomedical Compartments',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Load cells calibrated • Hermetic bio-seal active',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => wasteProvider.resetCompartments(),
                icon: const Icon(Icons.restore_from_trash_rounded, size: 16),
                label: const Text('EMPTY AT DOCK', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 4 Compartment Bars
          ...compartments.map(
            (comp) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CompartmentBarWidget(
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
                child: const Text('View All Ledger', style: TextStyle(fontSize: 12)),
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
                    color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.category.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.category.icon, color: item.category.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.detectedObject,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category.displayName} • ${Formatters.formatRelativeTime(item.timestamp)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
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
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          '${(item.confidence * 100).toStringAsFixed(0)}% conf',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w600,
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

  void _showCompartmentDetailDialog(BuildContext context, dynamic comp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.surfaceSlate,
        title: Row(
          children: [
            Icon(comp.category.icon, color: comp.color),
            const SizedBox(width: 10),
            Text(comp.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compartment ID: ${comp.codeName}'),
            const SizedBox(height: 6),
            Text('Current Weight: ${Formatters.formatWeight(comp.currentKg)} of ${comp.maxKg} kg limit'),
            const SizedBox(height: 6),
            Text('Item Count: ${comp.itemCount} deposits'),
            const SizedBox(height: 6),
            Text('Internal Temperature: ${comp.temperatureCelsius} °C'),
            const SizedBox(height: 6),
            const Text('Hermetic Bio-Seal: SECURE (Negative Pressure Active)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
