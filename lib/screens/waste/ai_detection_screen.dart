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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
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
                color: isDark ? AppConstants.surfaceSlate : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Item Detection Classification Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: currentItem.category.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: currentItem.category.color),
                          ),
                          child: Icon(
                            currentItem.category.icon,
                            color: currentItem.category.color,
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    currentItem.category.displayName,
                                    style: TextStyle(
                                      color: currentItem.category.accentColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: currentItem.category.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${(currentItem.confidence * 100).toStringAsFixed(1)}% Confidence',
                                      style: TextStyle(
                                        color: currentItem.category.accentColor,
                                        fontSize: 11,
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
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Text(
                              'Load Cell Mass',
                              style: TextStyle(fontSize: 11, color: AppConstants.neutralGrey),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Target Compartment & Protocol Details
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppConstants.borderSlate : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.swap_calls_rounded, size: 18, color: AppConstants.tealAccent),
                              const SizedBox(width: 8),
                              Text(
                                'TARGET: ${currentItem.category.compartmentGateId.toUpperCase()}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: AppConstants.tealAccent,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Actuator Directives: ${currentItem.internalActionDetails}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.fingerprint_rounded, size: 14, color: AppConstants.neutralGrey),
                              const SizedBox(width: 4),
                              Text(
                                'Ledger Proof Hash: ${currentItem.verificationHash ?? "0x0000000000000000"}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontFamily: 'Courier',
                                  color: AppConstants.neutralGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Buttons: Manual Override & Simulated Trigger
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _triggerSimulatedScan,
                            icon: const Icon(Icons.skip_next_rounded),
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
                                    '${currentItem.detectedObject} deposited to ${currentItem.category.shortName} compartment & logged to ledger.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppConstants.tealPrimary,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_rounded),
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
