import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/alert_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../services/offline_sync_service.dart';
import '../auth/login_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SYSTEM CENTER & PREFERENCES'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryTeal,
          tabs: const [
            Tab(icon: Icon(Icons.notifications_active_rounded, size: 18), text: 'Alert Center'),
            Tab(icon: Icon(Icons.sync_rounded, size: 18), text: 'Offline Sync'),
            Tab(icon: Icon(Icons.manage_accounts_rounded, size: 18), text: 'Profile & Ops'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertCenterTab(context),
          _buildOfflineSyncTab(context),
          _buildProfileTab(context),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: Central Notification / Alert Center
  // ==========================================
  Widget _buildAlertCenterTab(BuildContext context) {
    // Grouped into Critical, Warnings, and Info
    final criticalAlerts = [
      AlertModel(
        id: 'ALT-101',
        level: AlertLevel.critical,
        title: 'Sharps Vault Capacity ≥ 90%',
        message: 'Rover R04 Sharps Compartment at 98% (9.8 kg / 10 kg). Immediate bay discharge required.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        relatedSubsystem: 'R04 - Compartments',
      ),
      AlertModel(
        id: 'ALT-102',
        level: AlertLevel.critical,
        title: 'Emergency E-Stop Disconnect',
        message: 'Rover R01 emergency bumper sensor triggered at Corridor B airlock junction.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 42)),
        relatedSubsystem: 'R01 - Drive Motors',
      ),
    ];

    final warningAlerts = [
      AlertModel(
        id: 'ALT-201',
        level: AlertLevel.warning,
        title: 'Low Battery Level (< 20%)',
        message: 'Rover R04 telemetry reports 18% remaining charge. Scheduled auto-docking initiated.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        relatedSubsystem: 'R04 - Power Unit',
      ),
    ];

    final infoAlerts = [
      AlertModel(
        id: 'ALT-301',
        level: AlertLevel.info,
        title: 'Collection Mission Completed',
        message: 'Rover R02 completed pickup at Surgery OT-03. All 5 gates bio-sealed.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
        relatedSubsystem: 'Missions Engine',
      ),
      AlertModel(
        id: 'ALT-302',
        level: AlertLevel.info,
        title: 'Offline Queue Synchronized',
        message: '12 cached clinical records pushed to PostgreSQL backend successfully.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        relatedSubsystem: 'Cloud Gateway',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Critical Section
        _buildAlertSectionHeader(
          context,
          'CRITICAL ALERTS (COMPARTMENT ≥ 90% & OFFLINE ROVER)',
          criticalAlerts.length,
          AppTheme.plasticColor,
        ),
        ...criticalAlerts.map((a) => _buildAlertCard(a)),
        const SizedBox(height: 16),

        // Warning Section
        _buildAlertSectionHeader(
          context,
          'SYSTEM WARNINGS (LOW BATTERY & SENSORS)',
          warningAlerts.length,
          AppTheme.infectiousColor,
        ),
        ...warningAlerts.map((a) => _buildAlertCard(a)),
        const SizedBox(height: 16),

        // Info Section
        _buildAlertSectionHeader(
          context,
          'INFORMATIONAL (COMPLETED & AUDITS)',
          infoAlerts.length,
          AppTheme.accentTeal,
        ),
        ...infoAlerts.map((a) => _buildAlertCard(a)),
      ],
    );
  }

  Widget _buildAlertSectionHeader(BuildContext context, String title, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    final timeStr = DateFormat('HH:mm').format(alert.timestamp);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(alert.level.icon, size: 20, color: alert.level.color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textMain),
                      ),
                      Text(timeStr, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subsystem: ${alert.relatedSubsystem}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primaryTeal),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: Offline-First Synchronization Center
  // ==========================================
  Widget _buildOfflineSyncTab(BuildContext context) {
    final syncService = OfflineSyncService();

    return AnimatedBuilder(
      animation: syncService,
      builder: (context, _) {
        final isOnline = syncService.isOnline;
        final pending = syncService.pendingCount;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Network Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.sageEmerald.withOpacity(0.1) : AppTheme.plasticColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOnline ? AppTheme.sageEmerald : AppTheme.plasticColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    size: 24,
                    color: isOnline ? AppTheme.sageEmerald : AppTheme.plasticColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOnline ? 'CONNECTION STATUS: ONLINE' : 'CONNECTION STATUS: OFFLINE CACHE MODE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isOnline ? AppTheme.sageEmerald : AppTheme.plasticColor,
                          ),
                        ),
                        Text(
                          isOnline
                              ? 'Direct real-time WebSocket link to hospital MQTT broker active.'
                              : 'Submissions & QR scans are queued in local SQLite cache and auto-sync on reconnect.',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isOnline,
                    activeColor: AppTheme.sageEmerald,
                    onChanged: (val) {
                      syncService.toggleNetworkMode();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Queue Metrics
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PENDING SYNC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                          const SizedBox(height: 6),
                          Text('$pending Items', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryTeal)),
                          const Text('Awaiting uplink', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL SYNCHRONIZED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
                          const SizedBox(height: 6),
                          Text('${syncService.totalSyncedCount} Items', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.sageEmerald)),
                          const Text('Verified in PostgreSQL', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Manual Trigger Button
            ElevatedButton.icon(
              onPressed: pending == 0 || !isOnline
                  ? null
                  : () async {
                      final count = await syncService.syncPendingQueue();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Successfully synchronized $count items to server!')),
                        );
                      }
                    },
              icon: const Icon(Icons.cloud_upload_rounded, size: 18),
              label: const Text('FORCE SYNC PENDING QUEUE'),
            ),
            const SizedBox(height: 16),

            // Cached Queue Items
            Text(
              'LOCAL CACHE QUEUE ($pending)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            if (pending == 0)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text('All local items are fully synchronized.', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ),
                ),
              )
            else
              ...syncService.pendingQueue.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.hourglass_top_rounded, color: AppTheme.infectiousColor),
                    title: Text('${item.itemType.toUpperCase()}: ${item.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    subtitle: Text('Queued: ${DateFormat("HH:mm:ss").format(item.queuedAt)}', style: const TextStyle(fontSize: 10)),
                    trailing: const Text('Pending', style: TextStyle(color: AppTheme.infectiousColor, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 3: User Profile & Regulatory Manifests
  // ==========================================
  Widget _buildProfileTab(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final analytics = context.watch<AnalyticsProvider>();
    final user = auth.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // User Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryTeal,
                  child: Text(
                    user != null && user.name.isNotEmpty ? user.name[0] : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Clinical User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textMain)),
                      const SizedBox(height: 2),
                      Text('${user?.department ?? "Operations"} • ${user?.email ?? ""}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                      const SizedBox(height: 4),
                      Text('Hospital ID: ${user?.hospitalId ?? "HOSP_CH_01"}', style: const TextStyle(fontSize: 11, color: AppTheme.primaryTeal, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Regulatory Digital Manifests List
        Text(
          'REGULATORY BMW MANIFESTS (${analytics.manifests.length})',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 8),
        ...analytics.manifests.map((m) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.description_rounded, color: AppTheme.primaryTeal),
              title: Text(m.manifestNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('${m.hospitalName}\nBags: ${m.totalBags} • Weight: ${m.totalWeightKg} kg • CPCB Valid', style: const TextStyle(fontSize: 11)),
              trailing: IconButton(
                icon: const Icon(Icons.download_rounded, color: AppTheme.primaryTeal),
                onPressed: () => analytics.exportManifestPdf(m),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),

        // Logout Button
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.plasticColor),
            foregroundColor: AppTheme.plasticColor,
          ),
          onPressed: () {
            auth.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('LOGOUT & TERMINATE JWT SESSION'),
        ),
      ],
    );
  }
}
