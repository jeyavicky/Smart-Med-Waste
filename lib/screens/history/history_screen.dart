import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../providers/waste_analytics_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<WasteAnalyticsProvider>();
    final entries = analyticsProvider.filteredLedger;

    return Scaffold(
      backgroundColor: AppConstants.canvasBg,
      appBar: AppBar(
        backgroundColor: AppConstants.cardBg,
        title: const Text(
          'CPCB Regulatory Traceability Ledger',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppConstants.clinicalNavy),
        ),
        actions: [
          IconButton(
            tooltip: 'Export CPCB Audit Report',
            icon: const Icon(Icons.file_download_outlined, color: AppConstants.clinicalNavy),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CPCB Audit CSV & Form-IV Manifest exported to Downloads.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppConstants.clinicalNavy,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Compliance Badge Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppConstants.surfaceInteractive,
            child: Row(
              children: const [
                Icon(Icons.verified_rounded, color: AppConstants.statusNominal, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bio-Medical Waste Management Rules 2016 Compliant • Barcode Verification Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.clinicalNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Collection ID, Ward or Facility...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppConstants.coolSlate),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              analyticsProvider.setSearchFilter('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) => analyticsProvider.setSearchFilter(val),
                ),
                const SizedBox(height: 10),

                // Ward Filter Segmented Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All Wards',
                      'ICU',
                      'OT-03',
                      'Emergency',
                      'General Ward',
                      'Pathology',
                    ].map((ward) {
                      final isSelected = analyticsProvider.selectedWardFilter == ward;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => analyticsProvider.setSelectedWardFilter(ward),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppConstants.clinicalNavy
                                  : AppConstants.surfaceInteractive,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppConstants.clinicalNavy
                                    : AppConstants.dividerSubtle,
                              ),
                            ),
                            child: Text(
                              ward,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppConstants.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Audit Ledger List - Manifest cards
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long_rounded, size: 44, color: AppConstants.coolSlate),
                        SizedBox(height: 10),
                        Text(
                          'No Matching Collection Records',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppConstants.clinicalNavy,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Try clearing search filters',
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
                    itemCount: entries.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      return _buildLedgerManifestCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerManifestCard(BuildContext context, Map<String, dynamic> item) {
    final breakdown = (item['breakdown'] as Map<String, dynamic>?) ?? {};

    final double sharps = (breakdown['sharpsKg'] as num?)?.toDouble() ?? 0.0;
    final double infectious = (breakdown['infectiousKg'] as num?)?.toDouble() ?? 0.0;
    final double plastic = (breakdown['plasticKg'] as num?)?.toDouble() ?? 0.0;
    final double glassware = (breakdown['glasswareKg'] as num?)?.toDouble() ?? 0.0;
    final double others = ((breakdown['unknownOthersKg'] ?? breakdown['otherKg']) as num?)?.toDouble() ?? 0.0;

    return InkWell(
      onTap: () => _showAuditDetailsDialog(context, item),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConstants.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppConstants.cardBorder, width: 1.0),
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
            // Header: Collection ID + Ward + Verified Chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppConstants.clinicalNavy.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppConstants.clinicalNavy.withOpacity(0.2)),
                  ),
                  child: Text(
                    '#${item['id']}',
                    style: const TextStyle(
                      color: AppConstants.clinicalNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['ward'] ?? 'Hospital Ward',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppConstants.clinicalNavy,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppConstants.statusNominal.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['status'] ?? 'VERIFIED',
                    style: const TextStyle(
                      color: AppConstants.statusNominal,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Timestamp + Total Weight + Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppConstants.coolSlate),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.formatDateTime(item['timestamp']),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${Formatters.formatWeight(item['totalWeightKg'])} (${item['itemCount']} items)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    letterSpacing: -0.3,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),

            // Standardized 5-Compartment Breakdown Mini Badges per CPCB standard
            Row(
              children: [
                _categoryChip('Sharps', sharps, AppConstants.sharpsLightBg, AppConstants.sharpsBadge),
                const SizedBox(width: 4),
                _categoryChip('Infectious', infectious, AppConstants.infectiousLightBg, AppConstants.infectiousBadge),
                const SizedBox(width: 4),
                _categoryChip('Plastics', plastic, AppConstants.plasticLightBg, AppConstants.plasticBadge),
                const SizedBox(width: 4),
                _categoryChip('Glass', glassware, AppConstants.glasswareLightBg, AppConstants.glasswareBadge),
                const SizedBox(width: 4),
                _categoryChip('General', others, AppConstants.unknownLightBg, AppConstants.unknownBadge),
              ],
            ),

            const SizedBox(height: 10),

            // Robot ID & Verification Token
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 13, color: AppConstants.coolSlate),
                    const SizedBox(width: 4),
                    Text(
                      'AMR ${item['robotId'] ?? 'R01'} • ${Formatters.formatToken(item['token'])}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.qr_code_2_rounded, size: 18, color: AppConstants.clinicalNavy),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, num? kg, Color bg, Color border) {
    final double safeKg = (kg ?? 0.0).toDouble();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: border),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${safeKg.toStringAsFixed(2)}kg',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: AppConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuditDetailsDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppConstants.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: AppConstants.statusNominal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Collection #${item['id']} Manifest',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.clinicalNavy,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Ward / Dept', item['ward'] ?? 'N/A'),
              _detailRow('Collection Bay', item['facility'] ?? 'N/A'),
              _detailRow('Assigned AMR', item['robotId'] ?? 'R01'),
              _detailRow('Total Weight', Formatters.formatWeight(item['totalWeightKg'])),
              _detailRow('Item Count', '${item['itemCount']} items'),
              _detailRow('Blockchain Hash', item['token'] ?? 'N/A', isMono: true),
              _detailRow('Compliance Rule', 'CPCB Schedule I / BMW 2016'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.w700, color: AppConstants.clinicalNavy)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppConstants.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: isMono ? 'monospace' : null,
                color: AppConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
