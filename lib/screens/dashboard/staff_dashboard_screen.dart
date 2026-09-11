import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/mission_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mission_provider.dart';
import '../../providers/robot_provider.dart';
import '../../providers/waste_analytics_provider.dart';
import '../../widgets/compartment_bar_widget.dart';
import '../../widgets/robot_status_card.dart';
import '../alerts/alerts_screen.dart';
import '../collection/request_collection_sheet.dart';
import '../history/history_screen.dart';
import '../tracking/tracking_screen.dart';
import '../waste/ai_detection_screen.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final robotProvider = context.watch<RobotProvider>();
    final missionProvider = context.watch<MissionProvider>();
    final wasteProvider = context.watch<WasteAnalyticsProvider>();

    final user = authProvider.currentUser;
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
                  'Staff Ward Portal',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: AppConstants.clinicalNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppConstants.medicalTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'WARD STAFF',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppConstants.medicalTeal,
                    ),
                  ),
                ),
              ],
            ),
            if (user != null)
              Text(
                '${user.department} • ${user.name}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppConstants.textSecondary,
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
            // Prominent Ward Pickup Action
            ElevatedButton.icon(
              onPressed: () => RequestCollectionSheet.show(context),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
              label: const Text(
                'DISPATCH ROBOT / REQUEST WARD PICKUP',
                style: TextStyle(letterSpacing: 0.5, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppConstants.clinicalNavy,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 14),

            // Active Mission Alert Banner (if collecting or enRoute)
            if (activeMission != null &&
                activeMission.status != MissionStatus.completed &&
                activeMission.status != MissionStatus.cancelled) ...[
              _buildActiveMissionBanner(context, activeMission, robotProvider),
              const SizedBox(height: 14),
            ],

            // Ward Staff Quick Operations Grid
            const Text(
              'Ward Waste Operations',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppConstants.clinicalNavy,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildOperationCard(
                    context,
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Scan Waste / AI HUD',
                    subtitle: 'AI camera classification',
                    color: AppConstants.medicalTeal,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOperationCard(
                    context,
                    icon: Icons.near_me_rounded,
                    title: 'Live AMR Tracker',
                    subtitle: 'Corridor SLAM navigation',
                    color: AppConstants.clinicalNavy,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TrackingScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildOperationCard(
                    context,
                    icon: Icons.warning_amber_rounded,
                    title: 'Report Spill / Hazard',
                    subtitle: 'Cytotoxic / blood spill alert',
                    color: AppConstants.crimsonDanger,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AlertsScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildOperationCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Ward CPCB Ledger',
                    subtitle: 'Disposal audit manifest',
                    color: AppConstants.statusNominal,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Assigned Robot Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assigned AMR Telemetry',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppConstants.clinicalNavy,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TrackingScreen()),
                    );
                  },
                  child: const Text('FULL TELEMETRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            RobotStatusCard(
              robot: robot,
              robotProvider: robotProvider,
              onTapDetails: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrackingScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            // Waste Chamber Fullness
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chamber Segregation Fullness (${robot.id})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppConstants.clinicalNavy,
                        ),
                      ),
                      const Text(
                        'Tap any chamber to inspect with AI Vision Camera',
                        style: TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiDetectionScreen()),
                    );
                  },
                  child: const Text(
                    'AI CAMERA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 5 Compartment Bars with functional onTap
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

  Widget _buildOperationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.cardBg,
          borderRadius: BorderRadius.circular(10),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppConstants.clinicalNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppConstants.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    final robot = robotProvider.robot;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.clinicalNavy,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSIT IN PROGRESS • ${robot.id}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'En Route to ${mission.department} (${mission.stationId})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
            child: const Text('TRACK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
