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
    final compartments = wasteProvider.compartments;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(AppConstants.appName),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppConstants.tealPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ICU WING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.tealAccent,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Apollo Apex Hospital • Fleet Node R-01',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                fontWeight: FontWeight.w500,
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
                icon: const Icon(Icons.notifications_outlined),
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
                          fontWeight: FontWeight.w800,
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
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Active Mission Alert Banner (if in transit or collecting)
            if (activeMission != null &&
                activeMission.status != MissionStatus.completed &&
                activeMission.status != MissionStatus.cancelled) ...[
              _buildActiveMissionBanner(context, activeMission, robotProvider, missionProvider, isDark),
              const SizedBox(height: 16),
            ],

            // Robot Hero Card
            RobotStatusCard(
              robot: robot,
              robotProvider: robotProvider,
              onTapDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrackingScreen()),
                );
              },
            ),

            const SizedBox(height: 16),

            // Quick Actions Shortcut Bar
            _buildQuickActionButtons(context, robotProvider, isDark),

            const SizedBox(height: 16),

            // Today's Waste Collection Metric Summary Card
            _buildMetricSummaryCard(context, wasteProvider, isDark),

            const SizedBox(height: 20),

            // 4 Compartment Status Bars Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Live Compartment Fill Levels',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      'Real-time strain gauge weight sensors (±1g)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                  child: const Text('CPCB Ledger', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // The 4 Compartments
            ...compartments.map(
              (comp) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CompartmentBarWidget(
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
    MissionProvider missionProvider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mission.priority == MissionPriority.emergencyBiologicalSpill
            ? AppConstants.crimsonDanger.withOpacity(0.18)
            : AppConstants.tealPrimary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mission.priority == MissionPriority.emergencyBiologicalSpill
              ? AppConstants.crimsonDanger
              : AppConstants.tealAccent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (mission.priority == MissionPriority.emergencyBiologicalSpill
                      ? AppConstants.crimsonDanger
                      : AppConstants.tealAccent)
                  .withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              mission.status == MissionStatus.collecting
                  ? Icons.scanner_rounded
                  : Icons.near_me_rounded,
              color: mission.priority == MissionPriority.emergencyBiologicalSpill
                  ? AppConstants.crimsonDanger
                  : AppConstants.tealAccent,
              size: 20,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: mission.status.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#${mission.missionId}',
                      style: const TextStyle(fontSize: 11, color: AppConstants.lightSlate),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${mission.department} • Destination: ${mission.stationId}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
            child: const Text('TRACK', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context, RobotProvider robotProvider, bool isDark) {
    return Row(
      children: [
        // Camera View HUD Shortcut
        Expanded(
          child: _quickActionButton(
            context,
            icon: Icons.camera_alt_rounded,
            label: 'AI Camera HUD',
            color: AppConstants.tealAccent,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
              );
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),

        // Autonomous Map Shortcut
        Expanded(
          child: _quickActionButton(
            context,
            icon: Icons.map_rounded,
            label: 'Corridor Map',
            color: const Color(0xFF38BDF8),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TrackingScreen()),
              );
            },
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),

        // Request Pickup Shortcut
        Expanded(
          child: _quickActionButton(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Request Pickup',
            color: AppConstants.amberWarning,
            onTap: () => RequestCollectionSheet.show(context),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSummaryCard(
    BuildContext context,
    WasteAnalyticsProvider wasteProvider,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceSlate : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
        ),
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
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppConstants.neutralGrey,
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
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+${wasteProvider.todayWeightDeltaPercent}% vs yest',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
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
                  color: AppConstants.tealPrimary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: AppConstants.tealAccent,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // Micro-breakdown across 4 categories
          Row(
            children: [
              _microStat('Sharps', '1.85 kg', AppConstants.sharpsAccent),
              _verticalDivider(),
              _microStat('Infectious', '8.60 kg', AppConstants.infectiousColor),
              _verticalDivider(),
              _microStat('Plastic', '4.20 kg', AppConstants.plasticColor),
              _verticalDivider(),
              _microStat('Other', '2.10 kg', AppConstants.otherColor),
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
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppConstants.borderSlate,
    );
  }
}
