import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYTICS & CPCB REGULATORY LEDGER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryTeal),
            tooltip: 'Export CPCB PDF Manifest',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating Regulatory Manifest PDF...')),
              );
              await analytics.exportManifestPdf();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top KPI Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'CPCB COMPLIANCE',
                    value: '${analytics.cpcbComplianceRate}%',
                    subtitle: 'Rule 2016 Audit Pass',
                    icon: Icons.verified_user_rounded,
                    color: AppTheme.sageEmerald,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'AI SEGREGATION',
                    value: '${analytics.aiSegregationAccuracy}%',
                    subtitle: 'YOLO Computer Vision',
                    icon: Icons.psychology_rounded,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5-Compartment Weight Breakdown Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '5-COMPARTMENT WEIGHT ALLOCATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        Text(
                          'Total: ${analytics.totalMonthlyBiomedicalKg} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildCompartmentBar('Sharps (Needles/Blades)', 86.4, 482.6, AppTheme.sharpsColor, AppTheme.sharpsBg),
                    _buildCompartmentBar('Infectious (Yellow Bags)', 194.2, 482.6, AppTheme.infectiousColor, AppTheme.infectiousBg),
                    _buildCompartmentBar('Plastic (Red Non-Chlorinated)', 118.5, 482.6, AppTheme.plasticColor, AppTheme.plasticBg),
                    _buildCompartmentBar('Glassware (Vials/Ampoules)', 58.0, 482.6, AppTheme.glasswareColor, AppTheme.glasswareBg),
                    _buildCompartmentBar('Unknown / Others', 25.5, 482.6, AppTheme.unknownColor, AppTheme.unknownBg),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 7-Day Biomedical Waste Volume Trend
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '7-DAY GENERATION TREND (KG / DAY)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTrendBar('Mon', 62.4, 100),
                          _buildTrendBar('Tue', 71.0, 100),
                          _buildTrendBar('Wed', 58.5, 100),
                          _buildTrendBar('Thu', 79.0, 100),
                          _buildTrendBar('Fri', 68.2, 100),
                          _buildTrendBar('Sat', 84.1, 100),
                          _buildTrendBar('Sun', 59.4, 100),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Regulatory Manifest Generation Action
            Card(
              color: AppTheme.surfacePorcelain,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gavel_rounded, size: 20, color: AppTheme.primaryTeal),
                        const SizedBox(width: 8),
                        const Text(
                          'REGULATORY CPCB MANIFEST EXPORT',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Generate tamper-evident digital consignment form (Form IV) including 5-vault weight ledger, SHA-256 custody hash, and authorized officer signatures.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => analytics.exportManifestPdf(),
                      icon: const Icon(Icons.file_download_rounded, size: 18),
                      label: const Text('EXPORT REGULATORY PDF MANIFEST'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompartmentBar(String name, double kg, double totalKg, Color fg, Color bg) {
    final pct = (kg / totalKg);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg)),
              Text('${kg.toStringAsFixed(1)} kg (${(pct * 100).toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: bg,
            valueColor: AlwaysStoppedAnimation<Color>(fg),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendBar(String day, double value, double maxValue) {
    final heightRatio = (value / maxValue).clamp(0.1, 1.0);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${value.toInt()}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            const SizedBox(height: 4),
            Container(
              height: 75 * heightRatio,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              day,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
