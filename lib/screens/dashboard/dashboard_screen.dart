import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../models/mission_model.dart';
import '../../providers/mission_provider.dart';
import '../../providers/robot_provider.dart';
import '../../providers/waste_analytics_provider.dart';
import '../../widgets/compartment_bar_widget.dart';
import '../../widgets/robot_status_card.dart';
import '../../widgets/robot_fleet_selector.dart';
import '../alerts/alerts_screen.dart';
import '../collection/request_collection_sheet.dart';
import '../tracking/tracking_screen.dart';
import '../waste/ai_detection_screen.dart';
import '../history/history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = context.watch<RobotProvider>();
    final missionProvider = context.watch<MissionProvider>();
    final wasteProvider = context.watch<WasteAnalyticsProvider>();

    final robot = robotProvider.robot;
    final activeMission = missionProvider.activeMission;

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                    color: AppConstants.clinicalNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppConstants.clinicalNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppConstants.clinicalNavy.withOpacity(0.2)),
                  ),
                  child: Text(
                    robot.id,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.clinicalNavy,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Apollo Apex Hospital • Infection Control Logistics',
              style: const TextStyle(
                fontSize: 11,
                color: AppConstants.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Alerts Bell with Badge
          Stack(
            children: [
              IconButton(
                tooltip: 'Clinical Alerts',
                icon: const Icon(Icons.notifications_outlined, color: AppConstants.clinicalNavy),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  );
                },
              ),
              if (wasteProvider.unreadAlertCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppConstants.crimsonDanger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        '${wasteProvider.unreadAlertCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Persistent Multi-Robot Fleet Selector
            const RobotFleetSelector(),

            const SizedBox(height: 14),

            // Active Mission Alert Banner (if collecting or enRoute)
            if (activeMission != null &&
                activeMission.status != MissionStatus.completed &&
                activeMission.status != MissionStatus.cancelled) ...[
              _buildActiveMissionBanner(context, activeMission, robotProvider),
              const SizedBox(height: 14),
            ],

            // Active Selected Robot Telemetry Hero Card
            RobotStatusCard(
              robot: robot,
              robotProvider: robotProvider,
              onTapDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrackingScreen()),
                );
              },
            ),

            const SizedBox(height: 14),

            // Quick Actions Shortcut Bar
            _buildQuickActionButtons(context),

            const SizedBox(height: 14),

            // Today's Waste Collection Metric Summary Card
            _buildMetricSummaryCard(context, wasteProvider),

            const SizedBox(height: 18),

            // 5-Compartment Status Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5-Stream Chamber Levels (${robot.id})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppConstants.clinicalNavy,
                        ),
                      ),
                      const Text(
                        'CPCB Bio-Medical Rules 2016 Compliant Segregation',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                  child: const Text(
                    'CPCB Ledger',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // The 5 Compartments of the active AMR
            ...robot.compartments.values.map(
              (comp) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CompartmentBarWidget.fromCompartment(
                  compartment: comp,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMissionBanner(
    BuildContext context,
    MissionModel mission,
    RobotProvider robotProvider,
  ) {
    final isEmergency = mission.priority == MissionPriority.emergencyBiologicalSpill;
    final color = isEmergency ? AppConstants.crimsonDanger : AppConstants.medicalTeal;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isEmergency ? AppConstants.crimsonDangerLight : AppConstants.surfacePorcelain,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mission.status == MissionStatus.collecting
                  ? Icons.scanner_rounded
                  : Icons.near_me_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'ACTIVE: ${mission.status.displayName}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: color,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#${mission.missionId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${mission.department} • Target: ${mission.stationId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.clinicalNavy,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
            child: const Text('TRACK', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Row(
      children: [
        // Camera View HUD Shortcut
        Expanded(
          child: _quickActionButton(
            context,
            icon: Icons.camera_alt_outlined,
            label: 'AI Inspection HUD',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // Autonomous Map Shortcut
        Expanded(
          child: _quickActionButton(
            context,
            icon: Icons.map_outlined,
            label: 'Corridor Map',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 10),

        // Request Pickup Shortcut
        Expanded(
          child: _quickActionButton(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Request Pickup',
            isPrimary: true,
            onTap: () => RequestCollectionSheet.show(context),
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppConstants.clinicalNavy : AppConstants.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? AppConstants.clinicalNavy : AppConstants.medicalTeal,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppConstants.clinicalNavy,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: isPrimary ? Colors.white : AppConstants.clinicalNavy,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSummaryCard(
    BuildContext context,
    WasteAnalyticsProvider wasteProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppConstants.cardBorder, width: 1.2),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TODAY'S PROCESSED MEDICAL WASTE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        Formatters.formatWeight(wasteProvider.todayTotalWeightKg),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppConstants.statusNominal.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${wasteProvider.todayWeightDeltaPercent}% vs yest',
                          style: const TextStyle(
                            color: AppConstants.statusNominal,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.medicalTeal.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: AppConstants.medicalTeal,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // 5-Compartment Micro-breakdown Row
          Row(
            children: [
              _microStat('Sharps', '1.85 kg', AppConstants.sharpsBadge),
              _verticalDivider(),
              _microStat('Infectious', '8.60 kg', AppConstants.infectiousBadge),
              _verticalDivider(),
              _microStat('Plastics', '4.20 kg', AppConstants.plasticBadge),
              _verticalDivider(),
              _microStat('Glass', '2.10 kg', AppConstants.glasswareBadge),
              _verticalDivider(),
              _microStat('General', '0.65 kg', AppConstants.unknownBadge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _microStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 22,
      color: AppConstants.dividerSubtle,
    );
  }
}
