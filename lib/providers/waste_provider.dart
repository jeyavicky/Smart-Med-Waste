import 'dart:math';
import 'package:flutter/material.dart';
import '../models/waste_item_model.dart';
import '../models/bag_qr_model.dart';
import '../services/api_service.dart';
import '../services/offline_sync_service.dart';

class WasteProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final OfflineSyncService _offlineService = OfflineSyncService();

  List<WasteItemModel> _detectionHistory = [];
  List<BagQrModel> _bagQrList = [];
  WasteItemModel? _currentDetection;
  bool _isProcessingVision = false;
  String _activeWardId = 'ICU-01';

  List<WasteItemModel> get detectionHistory => List.unmodifiable(_detectionHistory);
  List<BagQrModel> get bagQrList => List.unmodifiable(_bagQrList);
  WasteItemModel? get currentDetection => _currentDetection;
  bool get isProcessingVision => _isProcessingVision;
  String get activeWardId => _activeWardId;

  WasteProvider() {
    _seedInitialData();
  }

  void setActiveWard(String ward) {
    _activeWardId = ward;
    notifyListeners();
  }

  void _seedInitialData() {
    final now = DateTime.now();
    _detectionHistory = [
      WasteItemModel(
        id: 'DET-10291',
        detectedObject: 'Used BD 5ml Syringe with Needle',
        category: WasteCategory.sharps,
        confidence: 0.94,
        weightKg: 0.08,
        timestamp: now.subtract(const Duration(minutes: 12)),
        internalActionDetails: 'AUTO-LOCKED: Gate #1 (Sharps Vault)',
        wardId: 'ICU-01',
        operatorId: 'OP-Sunita',
        riskScore: 0.95,
        isDiverterLocked: true,
      ),
      WasteItemModel(
        id: 'DET-10292',
        detectedObject: 'Surgical Gauze with Blood Stain',
        category: WasteCategory.infectious,
        confidence: 0.88,
        weightKg: 0.32,
        timestamp: now.subtract(const Duration(minutes: 8)),
        internalActionDetails: 'AUTO-LOCKED: Gate #2 (Infectious Bio-Lock)',
        wardId: 'Surgery OT-03',
        operatorId: 'OP-Rajesh',
        riskScore: 0.90,
        isDiverterLocked: true,
      ),
      WasteItemModel(
        id: 'DET-10293',
        detectedObject: 'Unlabeled Saline Plastic Container',
        category: WasteCategory.unknownOthers,
        confidence: 0.64,
        weightKg: 0.45,
        timestamp: now.subtract(const Duration(minutes: 3)),
        internalActionDetails: 'FLAGGED: Low Confidence (< 80%). Overridden to Plastic',
        wardId: 'ICU-01',
        operatorId: 'OP-Sunita',
        riskScore: 0.40,
        isManualOverride: true,
        isDiverterLocked: true,
      ),
    ];

    _bagQrList = [
      BagQrModel(
        bagId: 'BAG-2026-08142',
        ward: 'ICU Wing Floor 2',
        category: 'Infectious',
        weightKg: 3.4,
        missionId: 'MSN-2026-101',
        generatedAt: now.subtract(const Duration(hours: 1)),
        generatedBy: 'Sunita Kapoor',
      ),
      BagQrModel(
        bagId: 'BAG-2026-08143',
        ward: 'Surgery OT Floor 3',
        category: 'Sharps',
        weightKg: 1.8,
        missionId: 'MSN-2026-102',
        generatedAt: now.subtract(const Duration(minutes: 30)),
        generatedBy: 'Rajesh Kumar',
      ),
    ];

    _currentDetection = _detectionHistory.first;
  }

  /// Runs simulated YOLO AI Vision detection on an item
  Future<void> simulateYoloDetection({
    String? objectName,
    WasteCategory? category,
    double? confidence,
    double? weight,
  }) async {
    _isProcessingVision = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final objects = [
      ('Surgical Scalpel & Blades', WasteCategory.sharps, 0.96, 0.12),
      ('Bio-Hazard Contaminated Swabs', WasteCategory.infectious, 0.89, 0.28),
      ('Polypropylene Infusion Tubing', WasteCategory.plastic, 0.84, 0.35),
      ('Antibiotic Glass Ampoule', WasteCategory.glassware, 0.91, 0.15),
      ('Crushed Ambiguous Packing', WasteCategory.unknownOthers, 0.62, 0.22), // Low confidence trigger
    ];

    final pick = objects[Random().nextInt(objects.length)];
    final selectedObj = objectName ?? pick.$1;
    final selectedCat = category ?? pick.$2;
    final selectedConf = confidence ?? pick.$3;
    final selectedWt = weight ?? pick.$4;

    final item = await _apiService.inferWasteItem(
      detectedObject: selectedObj,
      category: selectedCat,
      confidence: selectedConf,
      weightKg: selectedWt,
      wardId: _activeWardId,
      operatorId: 'OP-Active',
    );

    _currentDetection = item;
    _detectionHistory.insert(0, item);
    _isProcessingVision = false;
    notifyListeners();

    // Cache locally / sync via OfflineSyncService
    _offlineService.queueWasteItem(item);
  }

  /// Human-In-The-Loop: Applies manual override if confidence was < 80% or correction needed
  void applyManualOverride({
    required WasteCategory correctedCategory,
    required String operatorId,
    String reason = 'Staff manual inspection override',
  }) {
    if (_currentDetection == null) return;

    final updated = _currentDetection!.copyWith(
      category: correctedCategory,
      isManualOverride: true,
      internalActionDetails: 'OVERRIDDEN BY $operatorId ➔ ${correctedCategory.compartmentGateId} ($reason)',
      isDiverterLocked: true,
    );

    _currentDetection = updated;
    final idx = _detectionHistory.indexWhere((item) => item.id == updated.id);
    if (idx != -1) {
      _detectionHistory[idx] = updated;
    }
    notifyListeners();

    _offlineService.queueWasteItem(updated);
  }

  /// Generates a new unique Bag QR Code
  BagQrModel generateNewBagQr({
    required String ward,
    required String category,
    required double weightKg,
    required String missionId,
    required String generatedBy,
  }) {
    final bagId = 'BAG-${DateTime.now().year}-${Random().nextInt(90000) + 10000}';
    final bag = BagQrModel(
      bagId: bagId,
      ward: ward,
      category: category,
      weightKg: weightKg,
      missionId: missionId,
      generatedAt: DateTime.now(),
      generatedBy: generatedBy,
    );

    _bagQrList.insert(0, bag);
    notifyListeners();

    _offlineService.queueBagQr(bag);
    return bag;
  }

  /// Processes scanned QR string
  BagQrModel processScannedQr(String qrContent, {String scannedBy = 'Staff'}) {
    final parsed = BagQrModel.fromQrString(qrContent, generatedBy: scannedBy);
    final existingIdx = _bagQrList.indexWhere((b) => b.bagId == parsed.bagId);
    if (existingIdx != -1) {
      _bagQrList[existingIdx] = parsed;
    } else {
      _bagQrList.insert(0, parsed);
    }
    notifyListeners();

    _offlineService.queueBagQr(parsed);
    return parsed;
  }
}
