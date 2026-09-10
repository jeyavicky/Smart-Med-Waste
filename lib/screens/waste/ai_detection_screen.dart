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

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isFlashing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final wasteProvider = context.watch<WasteAnalyticsProvider>();
    final currentItem = wasteProvider.currentItem;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnknownFallback = currentItem.category == WasteCategory.unknownOthers || currentItem.confidence < 0.70;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'LIVE AI VISION SCANNER (ONBOARD)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: Colors.white),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFF10B981)),
            ),
            child: const Center(
              child: Text(
                '45 FPS • TensorRT',
                style: TextStyle(
                  color: Color(0xFF10B981),
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
          // Camera Viewfinder Box
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Simulated Camera Video Frame Background (Chamber interior look)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.85,
                        colors: [
                          const Color(0xFF1E293B),
                          const Color(0xFF0F172A),
                          Colors.black.withOpacity(0.95),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(
                          currentItem.category.icon,
                          size: 160,
                          color: currentItem.category.color,
                        ),
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
                    child: Container(color: Colors.white.withOpacity(0.4)),
                  ),

                // Top Sensor Telemetry Floating Bar
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _hudStat('ISO 400', 'EXPOSURE: 1/120s'),
                        _hudStat('FOV: 110°', 'LIDAR: SYNCED'),
                        _hudStat('STERILIZATION', 'UV-C READY'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action & Segregation Result Panel
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.surfaceSlate : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
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
                          border: Border.all(color: AppConstants.unknownBadge.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_rounded, size: 16, color: AppConstants.unknownBadge),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ANTI-CONTAMINATION: Low confidence (<70%) or unclassified item automatically routed to Gate #5 (Unknown/Others Fallback)',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
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
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: currentItem.category.badgeColor),
                          ),
                          child: Icon(
                            currentItem.category.icon,
                            color: currentItem.category.badgeColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentItem.detectedObject,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppConstants.clinicalNavy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    currentItem.category.displayName,
                                    style: TextStyle(
                                      color: currentItem.category.badgeColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: currentItem.category.badgeColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${(currentItem.confidence * 100).toStringAsFixed(1)}% Confidence',
                                      style: TextStyle(
                                        color: currentItem.category.badgeColor,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                                color: isDark ? Colors.white : AppConstants.clinicalNavy,
                              ),
                            ),
                            Text(
                              'Load Cell Mass',
                              style: TextStyle(fontSize: 11, color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 20),

                    // Target Compartment & Protocol Details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D31) : AppConstants.surfaceInteractive,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.swap_calls_rounded, size: 18, color: currentItem.category.badgeColor),
                              const SizedBox(width: 8),
                              Text(
                                'TARGET: ${currentItem.category.compartmentGateId.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                  color: currentItem.category.badgeColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Actuator Directives: ${currentItem.internalActionDetails}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppConstants.lightSlate : AppConstants.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.fingerprint_rounded, size: 14, color: AppConstants.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'CPCB Blockchain Hash: ${currentItem.verificationHash ?? "0x0000000000000000"}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Courier',
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
                            icon: const Icon(Icons.skip_next_rounded, size: 16),
                            label: const Text('SAMPLE NEXT ITEM', style: TextStyle(fontSize: 11.5)),
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
                                    '${currentItem.detectedObject} deposited to ${currentItem.category.shortName} compartment & logged to ledger.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppConstants.clinicalNavy,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded, size: 16),
                            label: const Text('CONFIRM & DIVERT', style: TextStyle(fontSize: 11.5)),
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
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
