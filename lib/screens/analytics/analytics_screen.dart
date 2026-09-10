import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/waste_analytics_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<WasteAnalyticsProvider>();

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: const Text(
          'Waste Generation & Compliance Analytics',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top KPI Scores Row
          Row(
            children: [
              Expanded(
                child: _kpiCard(
                  title: 'CPCB COMPLIANCE',
                  value: '${analytics.cpcbComplianceScore}%',
                  subtitle: 'Bio-rules 2016 audited',
                  icon: Icons.verified_user_rounded,
                  color: AppConstants.statusNominal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _kpiCard(
                  title: 'AI SEGREGATION ACCURACY',
                  value: '${analytics.segregationAccuracy}%',
                  subtitle: 'Computer Vision 45 FPS',
                  icon: Icons.auto_awesome_rounded,
                  color: AppConstants.medicalTeal,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Daily Generation 7-Day Trend Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppConstants.cardBorder, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Daily Waste Generation (Past 7 Days)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppConstants.clinicalNavy),
                        ),
                        Text(
                          'Total: 101.4 kg • Peak: 16.75 kg (Today)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.statusNominal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '+8.4% Today',
                        style: TextStyle(
                          color: AppConstants.statusNominal,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Custom Canvas Bar Chart
                SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _DailyTrendChartPainter(
                      dataPoints: const [11.2, 14.8, 12.4, 16.1, 13.9, 15.2, 16.75],
                      days: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Today'],
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 5-Category Biomedical Waste Distribution
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppConstants.cardBorder, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biomedical Waste Category Share (Cumulative)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppConstants.clinicalNavy),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Automated color-coded segregation across 5 sealed internal chambers',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppConstants.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                _categoryShareRow('Infectious / Pathological (Yellow)', 19.60, 0.51, AppConstants.infectiousBadge),
                _categoryShareRow('Contaminated Plastics (Red)', 9.68, 0.25, AppConstants.plasticBadge),
                _categoryShareRow('Sharps / Blades (White)', 3.94, 0.10, AppConstants.sharpsBadge),
                _categoryShareRow('Glassware & Vials (Blue)', 3.67, 0.10, AppConstants.glasswareBadge),
                _categoryShareRow('General / Unclassified (Fallback)', 1.50, 0.04, AppConstants.unknownBadge),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Treatment Facility Routing Breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppConstants.cardBorder, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hospital Central Treatment Disposal Ratio',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppConstants.clinicalNavy),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 68,
                      child: Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppConstants.clinicalNavy,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                        ),
                        child: const Center(
                          child: Text(
                            '68% Autoclave / Hydroclave',
                            style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 32,
                      child: Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppConstants.amberWarning,
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                        ),
                        child: const Center(
                          child: Text(
                            '32% Incinerator',
                            style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'By segregating at source via AI vision, incineration is minimized by 41%, significantly reducing hazardous dioxin emissions and meeting CPCB 2016 standards.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppConstants.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConstants.cardBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 0.6, color: AppConstants.clinicalNavy),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryShareRow(String label, double kg, double ratio, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.textBody),
              ),
              Text(
                '${Formatters.formatWeight(kg)} (${(ratio * 100).toStringAsFixed(0)}%)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8.0,
              backgroundColor: AppConstants.surfaceInteractive,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Canvas Painter for the 7-day daily trend bar chart
class _DailyTrendChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<String> days;

  _DailyTrendChartPainter({
    required this.dataPoints,
    required this.days,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double bottomMargin = 24.0;
    final chartHeight = size.height - bottomMargin;
    const maxVal = 20.0; // 20kg max scale

    // Draw baseline
    final baselinePaint = Paint()
      ..color = AppConstants.dividerSubtle
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, chartHeight), Offset(size.width, chartHeight), baselinePaint);

    final numBars = dataPoints.length;
    final totalBarArea = size.width / numBars;
    final barWidth = totalBarArea * 0.45;

    for (int i = 0; i < numBars; i++) {
      final val = dataPoints[i];
      final barHeight = (val / maxVal) * (chartHeight - 20);
      final x = (i * totalBarArea) + (totalBarArea - barWidth) / 2;
      final y = chartHeight - barHeight;

      final isLast = i == numBars - 1;

      // Draw bar with rounded top
      final barPaint = Paint()
        ..color = isLast ? AppConstants.clinicalNavy : AppConstants.dividerSubtle
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        barPaint,
      );

      // Value label on top of bar
      final valPainter = TextPainter(
        text: TextSpan(
          text: '${val.toStringAsFixed(1)}k',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isLast ? AppConstants.clinicalNavy : AppConstants.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      valPainter.paint(canvas, Offset(x + (barWidth - valPainter.width) / 2, y - 14));

      // Day label below baseline
      final dayPainter = TextPainter(
        text: TextSpan(
          text: days[i],
          style: TextStyle(
            fontSize: 10,
            fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            color: isLast ? AppConstants.clinicalNavy : AppConstants.textSecondary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      dayPainter.paint(canvas, Offset(x + (barWidth - dayPainter.width) / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _DailyTrendChartPainter oldDelegate) {
    return false;
  }
}
