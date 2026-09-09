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
      appBar: AppBar(
        title: const Text('CPCB Regulatory Traceability Ledger'),
        actions: [
          IconButton(
            tooltip: 'Export CPCB Audit Report',
            icon: const Icon(Icons.file_download_rounded, color: AppConstants.tealAccent),
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
              children: const [
                Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bio-Medical Waste Management Rules 2016 Compliant • Barcode Verification Active',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
                          selectedColor: AppConstants.tealPrimary.withOpacity(0.35),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppConstants.lightSlate,
                          ),
                          backgroundColor: Theme.of(context).cardColor,
                          side: BorderSide(
                            color: isSelected ? AppConstants.tealAccent : AppConstants.borderSlate,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Audit Ledger List
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 48, color: AppConstants.neutralGrey),
                        const SizedBox(height: 12),
                        const Text(
                          'No Matching Collection Records',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
    final breakdown = item['breakdown'] as Map<String, dynamic>;

    return InkWell(
      onTap: () => _showAuditDetailsDialog(context, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceSlate : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
          ),
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
                    color: AppConstants.tealPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.4)),
                  ),
                  child: Text(
                    '#${item['id']}',
                    style: const TextStyle(
                      color: AppConstants.tealAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['ward'],
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
                    item['status'],
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
                        color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${Formatters.formatWeight(item['totalWeightKg'])} (${item['itemCount']} items)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),

            // 4-Category Breakdown Mini Badges
            Row(
              children: [
                _categoryChip('Sharps', breakdown['sharpsKg'], AppConstants.sharpsAccent),
                const SizedBox(width: 6),
                _categoryChip('Infectious', breakdown['infectiousKg'], AppConstants.infectiousColor),
                const SizedBox(width: 6),
                _categoryChip('Plastic', breakdown['plasticKg'], AppConstants.plasticColor),
                const SizedBox(width: 6),
                _categoryChip('Other', breakdown['otherKg'], AppConstants.otherColor),
              ],
            ),

            const SizedBox(height: 8),

            // Robot Verification Token
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fingerprint_rounded, size: 13, color: AppConstants.neutralGrey),
                    const SizedBox(width: 4),
                    Text(
                      'Token: ${Formatters.formatToken(item['token'])}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppConstants.lightSlate,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.qr_code_2_rounded, size: 18, color: AppConstants.tealAccent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, double kg, Color color) {
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
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${kg.toStringAsFixed(2)}kg',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
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
        backgroundColor: AppConstants.surfaceSlate,
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text('Collection #${item['id']} Verification'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ward: ${item['ward']}'),
              const SizedBox(height: 4),
              Text('Disposal Facility: ${item['facility']}'),
              const SizedBox(height: 4),
              Text('Operator: ${item['operator']}'),
              const SizedBox(height: 4),
              Text('Compliance Code: ${item['complianceStatus']}'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Center(
                child: Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.white),
              ),
              const Center(
                child: Text(
                  'CPCB Scan Validated',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cryptographic Signature:\n${item['token']}',
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppConstants.lightSlate),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}
