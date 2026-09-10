import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/alert_model.dart';
import '../../providers/waste_analytics_provider.dart';
import '../../widgets/alert_tile_widget.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  AlertLevel? _selectedFilter; // null = all

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<WasteAnalyticsProvider>();
    final allAlerts = analyticsProvider.alerts;

    final filteredAlerts = _selectedFilter == null
        ? allAlerts
        : allAlerts.where((a) => a.level == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: const Text(
          'Clinical Safety & Alerts',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              analyticsProvider.clearAcknowledgedAlerts();
            },
            icon: const Icon(Icons.cleaning_services_rounded, size: 16),
            label: const Text('Clear Read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All (${allAlerts.length})', null),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Critical (${allAlerts.where((a) => a.level == AlertLevel.critical).length})',
                  AlertLevel.critical,
                  color: AppConstants.crimsonDanger,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Warnings (${allAlerts.where((a) => a.level == AlertLevel.warning).length})',
                  AlertLevel.warning,
                  color: AppConstants.amberWarning,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Info (${allAlerts.where((a) => a.level == AlertLevel.info).length})',
                  AlertLevel.info,
                  color: AppConstants.medicalTeal,
                ),
              ],
            ),
          ),
          const Divider(),

          // Alerts List
          Expanded(
            child: filteredAlerts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.verified_user_rounded,
                          size: 48,
                          color: AppConstants.statusNominal,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No Active Alerts',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppConstants.clinicalNavy),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All autonomous subsystems operating normally',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAlerts.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final alert = filteredAlerts[index];
                      return AlertTileWidget(
                        alert: alert,
                        onAcknowledge: () {
                          analyticsProvider.acknowledgeAlert(alert.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, AlertLevel? level, {Color? color}) {
    final isSelected = _selectedFilter == level;
    final chipColor = color ?? AppConstants.clinicalNavy;

    return InkWell(
      onTap: () => setState(() => _selectedFilter = level),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : AppConstants.surfaceInteractive,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? chipColor : AppConstants.dividerSubtle,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppConstants.textSecondary,
          ),
        ),
      ),
    );
  }
}
