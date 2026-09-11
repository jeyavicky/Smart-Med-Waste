import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fleet_provider.dart';
import '../../providers/mission_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../models/mission_model.dart';
import '../../models/robot_model.dart';
import '../collection/request_collection_sheet.dart';

class HomeScreen extends StatelessWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SMART MED-WASTE',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 1.0,
                    fontSize: 16,
                  ),
            ),
            Text(
              user != null ? '${user.name} • ${user.department}' : 'Clinical Operations Hub',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? AppTheme.primaryTeal.withOpacity(0.1) : AppTheme.accentTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAdmin ? AppTheme.primaryTeal : AppTheme.accentTeal,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings_rounded : Icons.medical_services_rounded,
                  size: 14,
                  color: isAdmin ? AppTheme.primaryTeal : AppTheme.accentTeal,
                ),
                const SizedBox(width: 4),
                Text(
                  isAdmin ? 'ADMIN' : 'STAFF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isAdmin ? AppTheme.primaryTeal : AppTheme.accentTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isAdmin) _buildAdminDashboard(context) else _buildStaffDashboard(context),
              const SizedBox(height: 20),
              _buildActiveMissionCard(context),
              const SizedBox(height: 20),
              _buildFleetOverviewStrip(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final fleet = context.watch<FleetProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Admin KPI Metrics Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'FLEET ACTIVE',
                value: '${fleet.robotList.where((r) => r.status != RobotStatus.offline).length} / 4',
                subtitle: 'AMR Rovers Online',
                icon: Icons.precision_manufacturing_rounded,
                accentColor: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'CPCB COMPLIANCE',
                value: '${analytics.cpcbComplianceRate}%',
                subtitle: 'ISO/CPCB 2026',
                icon: Icons.verified_user_rounded,
                accentColor: AppTheme.sageEmerald,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'TOTAL DISPOSAL',
                value: '${analytics.totalMonthlyBiomedicalKg} kg',
                subtitle: 'Current Month',
                icon: Icons.delete_sweep_rounded,
                accentColor: AppTheme.accentTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'AI SEGREGATION',
                value: '${analytics.aiSegregationAccuracy}%',
                subtitle: 'Zero Cross-Contam',
                icon: Icons.psychology_rounded,
                accentColor: AppTheme.glasswareColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Admin Actions Bar
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FLEET CONTROLS & COMPLIANCE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onNavigateTab?.call(1), // Robots tab
                      icon: const Icon(Icons.hub_rounded, size: 16),
                      label: const Text('Live Fleet Tracking'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => analytics.exportManifestPdf(),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('Export CPCB Manifest'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        fleet.triggerEmergencyStop('R01');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('E-Stop Toggled for R01')),
                        );
                      },
                      icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.plasticColor),
                      label: const Text('E-Stop R01', style: TextStyle(color: AppTheme.plasticColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Staff Action Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.accentTeal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'CLINICAL WARD PORTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const Icon(Icons.local_hospital_rounded, color: Colors.white70, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Request Rover Collection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dispatch autonomous rover with smart multi-bin allocation for immediate hazardous segregation.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryTeal,
                ),
                onPressed: () => _openRequestCollection(context),
                icon: const Icon(Icons.add_task_rounded, size: 18),
                label: const Text('DISPATCH COLLECTION ROVER'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Staff Quick Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigateTab?.call(2), // Waste Tab
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: const Text('AI Vision Inspect'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onNavigateTab?.call(2), // Waste Tab
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: const Text('Trace Bag QR'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
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
                    letterSpacing: 0.6,
                    color: AppTheme.textMuted,
                  ),
                ),
                Icon(icon, size: 18, color: accentColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMissionCard(BuildContext context) {
    final missionProv = context.watch<MissionProvider>();
    final mission = missionProv.activeMission;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CURRENT MISSION LIFECYCLE (11-STEP)',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textMuted,
                      ),
                ),
                if (mission != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: mission.status.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: mission.status.color, width: 1),
                    ),
                    child: Text(
                      mission.status.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: mission.status.color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (mission != null) ...[
              Text(
                '${mission.department} • ${mission.stationId}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textMain),
              ),
              const SizedBox(height: 4),
              Text(
                'Assigned AMR: Rover ${mission.assignedRobotId ?? "R01"} • ETA ~${mission.estimatedArrivalMins} min',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 12),

              // 11-Step Progress Bar
              LinearProgressIndicator(
                value: (mission.status.stepIndex + 1) / 11.0,
                backgroundColor: AppTheme.surfacePorcelain,
                valueColor: AlwaysStoppedAnimation<Color>(mission.status.color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step ${mission.status.stepIndex + 1} of 11: ${mission.status.displayName}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMain),
                  ),
                  Text(
                    '${(((mission.status.stepIndex + 1) / 11.0) * 100).round()}%',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'No active collection mission in progress.',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFleetOverviewStrip(BuildContext context) {
    final fleet = context.watch<FleetProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ROBOT FLEET STATUS (R01–R04)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                  ),
            ),
            TextButton(
              onPressed: () => onNavigateTab?.call(1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: fleet.robotList.map((r) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderSubtle, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      r.id,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryTeal),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.battery_charging_full_rounded,
                          size: 13,
                          color: r.batteryLevel > 20 ? AppTheme.sageEmerald : AppTheme.plasticColor,
                        ),
                        Text(
                          '${r.batteryLevel}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openRequestCollection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RequestCollectionSheet(),
    );
  }
}
