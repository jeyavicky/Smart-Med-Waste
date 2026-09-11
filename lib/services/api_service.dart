import 'dart:convert';
import '../models/app_user_model.dart';
import '../models/mission_model.dart';
import '../models/waste_item_model.dart';
import '../models/manifest_model.dart';
import 'mock_database_service.dart';

/// Simulated FastAPI REST Client interfacing with PostgreSQL backend and YOLO AI engine
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static bool enableNetworkDelays = true;

  final MockDatabaseService _db = MockDatabaseService();
  String? _authToken;

  String? get authToken => _authToken;
  bool get isAuthenticated => _authToken != null;

  /// POST /auth/login -> returns JWT token and AppUserModel
  Future<AppUserModel> login({
    required String identifier, // Email or Phone
    required String password,
  }) async {
    if (enableNetworkDelays) {
      await Future.delayed(const Duration(milliseconds: 350)); // Network latency
    }

    final users = _db.getAllUsers();
    final clean = identifier.trim().toLowerCase();

    final user = users.firstWhere(
      (u) =>
          u.email.toLowerCase() == clean ||
          u.phone.replaceAll(' ', '') == clean.replaceAll(' ', ''),
      orElse: () => throw Exception('Authentication failed: Invalid credentials.'),
    );

    if (!user.isActive) {
      throw Exception('Account inactive: Contact Hospital Fleet Administrator.');
    }

    // Generate simulated JWT: header.payload.signature
    final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})));
    final payload = base64Url.encode(utf8.encode(jsonEncode({
      'sub': user.uid,
      'role': user.roleString,
      'name': user.name,
      'dept': user.department,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    })));
    final signature = 'simulated_hmac_sig_${user.uid.hashCode}';
    final jwt = '$header.$payload.$signature';

    _authToken = jwt;
    return user.copyWith(token: jwt, lastLogin: DateTime.now());
  }

  void logout() {
    _authToken = null;
  }

  /// POST /missions/request -> dispatches new waste pickup request
  Future<MissionModel> requestCollection({
    required String department,
    required String stationId,
    required MissionPriority priority,
    required String requestedBy,
    String notes = '',
  }) async {
    if (enableNetworkDelays) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    final missionId = 'MSN-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';
    return MissionModel(
      missionId: missionId,
      department: department,
      stationId: stationId,
      priority: priority,
      status: MissionLifecycleStatus.pending,
      requestedBy: requestedBy,
      requestedAt: DateTime.now(),
      notes: notes,
    );
  }

  /// POST /waste/detect-ai -> simulated YOLO engine inference
  Future<WasteItemModel> inferWasteItem({
    required String detectedObject,
    required WasteCategory category,
    required double confidence,
    required double weightKg,
    required String wardId,
    required String operatorId,
    bool isManualOverride = false,
  }) async {
    if (enableNetworkDelays) {
      await Future.delayed(const Duration(milliseconds: 150));
    }
    final id = 'DET-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final isHigh = confidence >= 0.80;
    return WasteItemModel(
      id: id,
      detectedObject: detectedObject,
      category: category,
      confidence: confidence,
      weightKg: weightKg,
      timestamp: DateTime.now(),
      internalActionDetails: isHigh
          ? 'AUTO-LOCKED: ${category.compartmentGateId}'
          : 'FLAGGED FOR HUMAN VERIFICATION: Low Confidence (< 80%)',
      wardId: wardId,
      operatorId: operatorId,
      isManualOverride: isManualOverride,
      riskScore: category == WasteCategory.infectious || category == WasteCategory.sharps ? 0.92 : 0.45,
      isDiverterLocked: isHigh,
    );
  }

  /// GET /manifests -> fetch regulatory manifests
  Future<List<ManifestModel>> getManifests() async {
    if (enableNetworkDelays) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return [
      ManifestModel.mockDefault(),
      ManifestModel(
        manifestNumber: 'BMW-2026-0890',
        hospitalName: 'Apollo Clinical Health Systems - Main Surgical Block',
        cpcbRegNumber: 'CPCB-BMW-2026/TN/7721',
        generatedDate: DateTime.now().subtract(const Duration(days: 1)),
        authorizedOfficer: 'Dr. Ramanujam MD',
        carrierFacility: 'EcoMed Bio-Hazard Remediation Facility Inc.',
        vehicleRegNumber: 'KA-04-MB-8821',
        categoryWeightsKg: {
          'Sharps': 11.2,
          'Infectious': 28.0,
          'Plastic': 14.5,
          'Glassware': 6.8,
          'Unknown/Others': 2.3,
        },
        totalWeightKg: 62.8,
        totalBags: 29,
        digitalSignatureHash: 'SHA256:4a8b7c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b',
        isDisposalConfirmed: true,
        confirmedAt: DateTime.now().subtract(const Duration(hours: 22)),
      ),
    ];
  }
}
