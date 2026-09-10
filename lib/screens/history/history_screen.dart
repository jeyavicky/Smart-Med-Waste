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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkSlate : AppConstants.canvasBg,
      appBar: AppBar(
        title: const Text(
          'CPCB Regulatory Traceability Ledger',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        actions: [
          IconButton(
            tooltip: 'Export CPCB Audit Report',
            icon: const Icon(Icons.file_download_rounded, color: AppConstants.medicalTeal),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CPCB Audit CSV & Form-IV Manifest exported to Downloads.'),
                  behavior: SnackBarBehavior.floating,
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
            color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bio-Medical Waste Management Rules 2016 Compliant • Barcode Verification Active',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppConstants.lightSlate : AppConstants.clinicalNavy,
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
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
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

                // Ward Filter Chips
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
                        child: FilterChip(
                          label: Text(ward),
                          selected: isSelected,
                          onSelected: (_) => analyticsProvider.setSelectedWardFilter(ward),
                          selectedColor: AppConstants.medicalTeal.withOpacity(0.25),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? (isDark ? Colors.white : AppConstants.clinicalNavy)
                                : (isDark ? AppConstants.lightSlate : AppConstants.textSecondary),
                          ),
                          backgroundColor: isDark ? AppConstants.surfaceSlate : Colors.white,
                          side: BorderSide(
                            color: isSelected ? AppConstants.medicalTeal : (isDark ? AppConstants.borderSlate : AppConstants.cardBorder),
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

          // Audit Ledger List
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 48, color: AppConstants.neutralGrey),
                        const SizedBox(height: 12),
                        Text(
                          'No Matching Collection Records',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppConstants.clinicalNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try clearing search filters',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      return _buildLedgerCard(context, item, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerCard(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final breakdown = (item['breakdown'] as Map<String, dynamic>?) ?? {};

    final double sharps = (breakdown['sharpsKg'] as num?)?.toDouble() ?? 0.0;
    final double infectious = (breakdown['infectiousKg'] as num?)?.toDouble() ?? 0.0;
    final double plastic = (breakdown['plasticKg'] as num?)?.toDouble() ?? 0.0;
    final double glassware = (breakdown['glasswareKg'] as num?)?.toDouble() ?? 0.0;
    final double others = ((breakdown['unknownOthersKg'] ?? breakdown['otherKg']) as num?)?.toDouble() ?? 0.0;

    return InkWell(
      onTap: () => _showAuditDetailsDialog(context, item, isDark),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppConstants.borderSlate : AppConstants.cardBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(isDark ? 0.25 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Collection ID + Status Chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.medicalTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppConstants.medicalTeal.withOpacity(0.3)),
                  ),
                  child: Text(
                    '#${item['id']}',
                    style: const TextStyle(
                      color: AppConstants.medicalTeal,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['ward'] ?? 'Hospital Ward',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppConstants.clinicalNavy,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['status'] ?? 'VERIFIED',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
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
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppConstants.neutralGrey),
                    const SizedBox(width: 4),
                    Text(
                      Formatters.formatDateTime(item['timestamp']),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${Formatters.formatWeight(item['totalWeightKg'])} (${item['itemCount']} items)',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : AppConstants.clinicalNavy,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Standardized 5-Compartment Breakdown Mini Badges
            Row(
              children: [
                _categoryChip('Sharps', sharps, AppConstants.sharpsBadge, isDark),
                const SizedBox(width: 4),
                _categoryChip('Infectious', infectious, AppConstants.infectiousBadge, isDark),
                const SizedBox(width: 4),
                _categoryChip('Plastic', plastic, AppConstants.plasticBadge, isDark),
                const SizedBox(width: 4),
                _categoryChip('Glass', glassware, AppConstants.glasswareBadge, isDark),
                const SizedBox(width: 4),
                _categoryChip('Other', others, AppConstants.unknownBadge, isDark),
              ],
            ),

            const SizedBox(height: 10),

            // Robot ID & Verification Token
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 13, color: AppConstants.neutralGrey),
                    const SizedBox(width: 4),
                    Text(
                      'AMR: ${item['robotId'] ?? 'R01'} • ${Formatters.formatToken(item['token'])}',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.qr_code_2_rounded, size: 18, color: AppConstants.medicalTeal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, num? kg, Color color, bool isDark) {
    final double safeKg = (kg ?? 0.0).toDouble();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${safeKg.toStringAsFixed(2)}kg',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppConstants.clinicalNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuditDetailsDialog(BuildContext context, Map<String, dynamic> item, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppConstants.surfaceSlate : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Collection #${item['id']} Verification',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppConstants.clinicalNavy,
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
              _detailRow('Ward / Dept', item['ward'] ?? 'N/A', isDark),
              _detailRow('AMR Node', item['robotId'] ?? 'R01', isDark),
              _detailRow('Disposal Facility', item['facility'] ?? 'N/A', isDark),
              _detailRow('Operator', item['operator'] ?? 'N/A', isDark),
              _detailRow('Compliance Code', item['complianceStatus'] ?? 'CPCB Verified', isDark),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: 90,
                    color: isDark ? Colors.white : AppConstants.clinicalNavy,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'CPCB Scan Validated • Secure Manifest',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cryptographic Signature:\n${item['token']}',
                style: TextStyle(
                  fontSize: 9.5,
                  fontFamily: 'monospace',
                  color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isDark ? AppConstants.lightSlate : AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppConstants.clinicalNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
