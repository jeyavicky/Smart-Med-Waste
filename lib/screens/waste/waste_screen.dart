import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/waste_item_model.dart';
import '../../providers/waste_provider.dart';
import '../../providers/auth_provider.dart';

class WasteScreen extends StatefulWidget {
  const WasteScreen({super.key});

  @override
  State<WasteScreen> createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('WASTE SEGREGATION & TRACEABILITY'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryTeal,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryTeal,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt_rounded, size: 18), text: 'AI Vision Viewfinder'),
            Tab(icon: Icon(Icons.qr_code_2_rounded, size: 18), text: 'QR Bag Traceability'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAiVisionTab(context),
          _buildQrTraceabilityTab(context),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: AI Vision Viewfinder & Safety Fallback
  // ==========================================
  Widget _buildAiVisionTab(BuildContext context) {
    final waste = context.watch<WasteProvider>();
    final current = waste.currentDetection;
    final isProcessing = waste.isProcessingVision;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Camera Viewfinder Simulation Box
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF16252D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Viewfinder Crosshairs & Grid Background
                  CustomPaint(
                    painter: _ViewfinderOverlayPainter(),
                  ),

                  // Center Detection Target Box
                  if (current != null)
                    Center(
                      child: Container(
                        width: 180,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: current.isHighConfidence
                                ? AppTheme.sageEmerald
                                : AppTheme.infectiousColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: (current.isHighConfidence
                                  ? AppTheme.sageEmerald
                                  : AppTheme.infectiousColor)
                              .withOpacity(0.08),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            color: current.isHighConfidence
                                ? AppTheme.sageEmerald
                                : AppTheme.infectiousColor,
                            child: Text(
                              '${current.category.shortName.toUpperCase()} ${(current.confidence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Loading Indicator
                  if (isProcessing)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.accentTeal),
                      ),
                    ),

                  // Top HUD bar
                  Positioned(
                    top: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'YOLO v8 BIO-OPTIC SENSOR • 30 FPS',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'WARD: ${waste.activeWardId}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Trigger Action
                  Positioned(
                    bottom: 12,
                    right: 12,
                    left: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          onPressed: isProcessing
                              ? null
                              : () => waste.simulateYoloDetection(),
                          icon: const Icon(Icons.videocam_rounded, size: 16),
                          label: const Text('CAPTURE & ANALYZE ITEM'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Inference Result & Diverter Lock Card
          if (current != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            current.detectedObject,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: current.category.lightBgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: current.category.color, width: 1),
                          ),
                          child: Text(
                            current.category.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: current.category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatPill('Confidence', '${(current.confidence * 100).toStringAsFixed(1)}%',
                            current.isHighConfidence ? AppTheme.sageEmerald : AppTheme.plasticColor),
                        const SizedBox(width: 8),
                        _buildStatPill('Risk Score', '${(current.riskScore * 100).toStringAsFixed(0)}/100', AppTheme.textMain),
                        const SizedBox(width: 8),
                        _buildStatPill('Net Weight', '${current.weightKg.toStringAsFixed(2)} kg', AppTheme.primaryTeal),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Confidence Threshold Logic Card
                    if (current.isHighConfidence) ...[
                      // Automatic Diverter Mechanical Gate Lock (>= 80%)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.sageEmerald.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.sageEmerald, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_rounded, size: 20, color: AppTheme.sageEmerald),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DIVERTER MECHANICAL GATE LOCKED',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.sageEmerald,
                                    ),
                                  ),
                                  Text(
                                    'Confidence ≥ 80%. Actuator routed waste directly to ${current.category.compartmentGateId}.',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Low-Confidence Warning (< 80%) + Human-In-The-Loop Fallback
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.plasticColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.plasticColor, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_rounded, size: 20, color: AppTheme.plasticColor),
                                const SizedBox(width: 8),
                                const Text(
                                  'LOW CONFIDENCE WARNING (< 80%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.plasticColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Optical certainty below clinical threshold. Diverter lock halted. Tap manual override chip to confirm destination:',
                              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 10),

                            // Manual Override Chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                _buildOverrideChip(context, WasteCategory.sharps, '[SHARPS]'),
                                _buildOverrideChip(context, WasteCategory.infectious, '[INFECTIOUS]'),
                                _buildOverrideChip(context, WasteCategory.plastic, '[PLASTIC]'),
                                _buildOverrideChip(context, WasteCategory.glassware, '[GLASSWARE]'),
                                _buildOverrideChip(context, WasteCategory.unknownOthers, '[UNKNOWN]'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // 3. Detection Audit Logs
          Text(
            'DETECTION AUDIT LOGS (TIMESTAMP & OPERATOR)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 10),
          ...waste.detectionHistory.map((item) {
            final timeStr = DateFormat('HH:mm:ss').format(item.timestamp);
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.category.lightBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.category.icon, size: 16, color: item.category.color),
                ),
                title: Text(item.detectedObject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  '${item.id} • ${item.wardId} • ${item.operatorId} • $timeStr\n${item.internalActionDetails}',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Text(
                  '${(item.confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.isHighConfidence ? AppTheme.sageEmerald : AppTheme.plasticColor,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfacePorcelain,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildOverrideChip(BuildContext context, WasteCategory category, String label) {
    final waste = context.read<WasteProvider>();
    final auth = context.read<AuthProvider>();
    final opId = auth.currentUser?.name ?? 'Staff Incharge';

    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      backgroundColor: category.lightBgColor,
      side: BorderSide(color: category.color, width: 1),
      labelStyle: TextStyle(color: category.color),
      onPressed: () {
        waste.applyManualOverride(
          correctedCategory: category,
          operatorId: opId,
          reason: 'Manual staff clinical verification',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gate locked: Manual Override set to ${category.shortName}'),
            backgroundColor: category.color,
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: QR Bag Traceability & Generation
  // ==========================================
  Widget _buildQrTraceabilityTab(BuildContext context) {
    final waste = context.watch<WasteProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIGITAL BAG TRACEABILITY (BAG-YYYY-XXXXX)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Generate encrypted QR barcodes affixed to biomedical waste bags for regulatory CPCB manifest audits and carrier chain-of-custody.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showGenerateQrModal(context),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                        label: const Text('GENERATE NEW BAG QR'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _simulateScanQr(context),
                        icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                        label: const Text('SCAN BAG CODE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Active QR Bags List
          Text(
            'ACTIVE TRACED BAGS (${waste.bagQrList.length})',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 10),
          ...waste.bagQrList.map((bag) {
            final timeStr = DateFormat('dd MMM, HH:mm').format(bag.generatedAt);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Render QR Code Widget
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.borderSubtle, width: 1),
                      ),
                      child: QrImageView(
                        data: bag.toQrString(),
                        version: QrVersions.auto,
                        size: 72.0,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bag.bagId,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMain,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${bag.category} • ${bag.weightKg} kg',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ward: ${bag.ward} • Mission: ${bag.missionId}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          Text(
                            'Officer: ${bag.generatedBy} • $timeStr',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showGenerateQrModal(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String ward = 'ICU Wing Floor 2';
    String category = 'Infectious';
    double weight = 2.5;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Generate Waste Bag QR Code'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: ward,
                  decoration: const InputDecoration(labelText: 'Ward / Department'),
                  items: const [
                    DropdownMenuItem(value: 'ICU Wing Floor 2', child: Text('ICU Wing Floor 2')),
                    DropdownMenuItem(value: 'Surgery OT Floor 3', child: Text('Surgery OT Floor 3')),
                    DropdownMenuItem(value: 'Pathology Lab Floor 1', child: Text('Pathology Lab Floor 1')),
                  ],
                  onChanged: (v) => ward = v ?? ward,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Waste Category'),
                  items: const [
                    DropdownMenuItem(value: 'Sharps', child: Text('Sharps')),
                    DropdownMenuItem(value: 'Infectious', child: Text('Infectious')),
                    DropdownMenuItem(value: 'Plastic', child: Text('Plastic')),
                    DropdownMenuItem(value: 'Glassware', child: Text('Glassware')),
                    DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
                  ],
                  onChanged: (v) => category = v ?? category,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: '2.5',
                  decoration: const InputDecoration(labelText: 'Estimated Weight (kg)'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => weight = double.tryParse(v) ?? 2.5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final auth = context.read<AuthProvider>();
                final waste = context.read<WasteProvider>();
                final bag = waste.generateNewBagQr(
                  ward: ward,
                  category: category,
                  weightKg: weight,
                  missionId: 'MSN-2026-REG',
                  generatedBy: auth.currentUser?.name ?? 'Staff Incharge',
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Generated ${bag.bagId} successfully!')),
                );
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  void _simulateScanQr(BuildContext context) {
    final waste = context.read<WasteProvider>();
    final auth = context.read<AuthProvider>();
    final bag = waste.processScannedQr(
      '{"id":"BAG-2026-99120","ward":"Surgery OT-01","cat":"Sharps","wt":1.9,"msn":"MSN-2026-88"}',
      scannedBy: auth.currentUser?.name ?? 'Staff Incharge',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR Code Scanned & Logged: ${bag.bagId} (${bag.category})')),
    );
  }
}

class _ViewfinderOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white10
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Four corner brackets
    final corner = Paint()
      ..color = AppTheme.accentTeal
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const len = 20.0;
    // Top Left
    canvas.drawLine(const Offset(16, 26), const Offset(16 + len, 26), corner);
    canvas.drawLine(const Offset(16, 26), const Offset(16, 26 + len), corner);
    // Top Right
    canvas.drawLine(Offset(size.width - 16, 26), Offset(size.width - 16 - len, 26), corner);
    canvas.drawLine(Offset(size.width - 16, 26), Offset(size.width - 16, 26 + len), corner);
    // Bottom Left
    canvas.drawLine(Offset(16, size.height - 26), Offset(16 + len, size.height - 26), corner);
    canvas.drawLine(Offset(16, size.height - 26), Offset(16, size.height - 26 - len), corner);
    // Bottom Right
    canvas.drawLine(Offset(size.width - 16, size.height - 26), Offset(size.width - 16 - len, size.height - 26), corner);
    canvas.drawLine(Offset(size.width - 16, size.height - 26), Offset(size.width - 16, size.height - 26 - len), corner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
