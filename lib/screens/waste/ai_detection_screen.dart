import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/waste_item_model.dart';
import '../../providers/waste_analytics_provider.dart';
import '../../widgets/custom_hud_overlay.dart';

class AiDetectionScreen extends StatefulWidget {
  const AiDetectionScreen({super.key});

  @override
  State<AiDetectionScreen> createState() => _AiDetectionScreenState();
}

class _AiDetectionScreenState extends State<AiDetectionScreen> {
  bool _isFlashing = false;

  void _triggerSimulatedScan() {
    setState(() => _isFlashing = true);
    final provider = context.read<WasteAnalyticsProvider>();
    provider.simulateNextItem();

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _isFlashing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wasteProvider = context.watch<WasteAnalyticsProvider>();
    final currentItem = wasteProvider.currentItem;
    final isUnknownFallback = currentItem.category == WasteCategory.unknownOthers || currentItem.confidence < 0.70;

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppConstants.statusNominal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CLINICAL AI INSPECTION PORTAL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: AppConstants.clinicalNavy,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppConstants.clinicalNavy.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppConstants.clinicalNavy.withOpacity(0.2)),
            ),
            child: const Center(
              child: Text(
                '45 FPS • TensorRT Edge',
                style: TextStyle(
                  color: AppConstants.clinicalNavy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Clinical Camera Inspection Viewport Box
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A), // Certified dark high-contrast optical chamber
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppConstants.cardBorder, width: 1.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    // Simulated Item Backdrop
                    Positioned.fill(
                      child: Center(
                        child: Opacity(
                          opacity: 0.12,
                          child: Icon(
                            currentItem.category.icon,
                            size: 150,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // HUD Targeting Overlay
                    Positioned.fill(
                      child: CustomHudOverlay(item: currentItem),
                    ),

                    // Shutter flash effect
                    if (_isFlashing)
                      Positioned.fill(
                        child: Container(color: Colors.white.withOpacity(0.35)),
                      ),

                    // Top Sensor Telemetry Floating Bar
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _hudStat('OPTICAL', 'SONY IMX335 5MP'),
                            _hudStat('LIDAR DEPTH', 'ACTIVE SLAM'),
                            _hudStat('UV-C DECONTAM', 'ARMED'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action & Segregation Result Panel
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                border: Border.all(color: AppConstants.cardBorder, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Fallback Alert Notice if Low-Confidence / Unknown
                    if (isUnknownFallback) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppConstants.unknownLightBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppConstants.unknownBadge.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, size: 16, color: AppConstants.unknownBadge),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'ANTI-CONTAMINATION: Unclassified/Low-Confidence item (<70%) automatically diverted to Gate #5 (General / Unclassified Vault)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.unknownBadge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Item Detection Classification Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: currentItem.category.lightBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: currentItem.category.badgeColor, width: 1.0),
                          ),
                          child: Icon(
                            currentItem.category.icon,
                            color: currentItem.category.badgeColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentItem.detectedObject,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppConstants.clinicalNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    currentItem.category.displayName,
                                    style: TextStyle(
                                      color: currentItem.category.badgeColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10.5,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: currentItem.category.badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${(currentItem.confidence * 100).toStringAsFixed(1)}% Conf',
                                      style: TextStyle(
                                        color: currentItem.category.badgeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.formatWeight(currentItem.weightKg),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                            const Text(
                              'Load Cell Mass',
                              style: TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Target Compartment & Protocol Details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.surfacePorcelain,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppConstants.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.swap_calls_rounded, size: 16, color: currentItem.category.badgeColor),
                              const SizedBox(width: 6),
                              Text(
                                'TARGET: ${currentItem.category.compartmentGateId.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: currentItem.category.badgeColor,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Actuator Directives: ${currentItem.internalActionDetails}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppConstants.textBody,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.fingerprint_rounded, size: 13, color: AppConstants.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'CPCB Blockchain Verification: ${currentItem.verificationHash ?? "0x0000000000000000"}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                  color: AppConstants.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons: Manual Override & Simulated Trigger
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _triggerSimulatedScan,
                            icon: const Icon(Icons.skip_next_rounded, size: 18),
                            label: const Text('SAMPLE NEXT ITEM'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              wasteProvider.simulateNextItem();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${currentItem.detectedObject} deposited to ${currentItem.category.shortName} chamber & logged to CPCB manifest.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppConstants.clinicalNavy,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: const Text('CONFIRM & DIVERT'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
