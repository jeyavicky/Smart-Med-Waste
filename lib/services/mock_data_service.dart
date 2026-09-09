import '../models/robot_model.dart';
import '../models/waste_item_model.dart';
import '../models/mission_model.dart';
import '../models/compartment_model.dart';
import '../models/alert_model.dart';

/// Comprehensive Mock Data Service providing realistic healthcare seed data
/// and dynamic simulation cycling for SIH judging and offline demonstrations.
class MockDataService {
  static final MockDataService instance = MockDataService._internal();
  MockDataService._internal();

  /// Initial Robot telemetry state
  RobotModel getInitialRobot() {
    return RobotModel(
      id: 'SMW-ROBOT-01',
      name: 'MediBot Autonomous Segregator R-01',
      status: RobotStatus.idle,
      batteryPercent: 88.0,
      voltage: 12.2,
      currentAmps: 1.8,
      tempCelsius: 30.5,
      currentWard: 'ICU - Floor 2 (Drop Bay 1)',
      coordinates: const RobotCoordinates(
        x: 120.0,
        y: 85.0,
        headingDegrees: 45.0,
        floor: 'Floor 2 (ICU & Surgical Wing)',
      ),
      health: const SubsystemHealth(
        driveMotors: true,
        lidarDepthSensors: true,
        aiVisionCamera: true,
        loadCells: true,
        internalLocking: true,
      ),
      lastHeartbeat: DateTime.now(),
      isOnline: true,
    );
  }

  /// Initial 4 compartments
  List<CompartmentModel> getInitialCompartments() {
    return const [
      CompartmentModel(
        category: WasteCategory.sharpsWhite,
        title: 'Sharps & Blades',
        codeName: 'COMP-01-WHITE',
        currentKg: 1.85,
        maxKg: 5.00,
        itemCount: 42,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 21.8,
      ),
      CompartmentModel(
        category: WasteCategory.infectiousYellow,
        title: 'Infectious Biohazard',
        codeName: 'COMP-02-YELLOW',
        currentKg: 8.60,
        maxKg: 10.00,
        itemCount: 68,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 22.1,
      ),
      CompartmentModel(
        category: WasteCategory.plasticRed,
        title: 'Contaminated Plastics',
        codeName: 'COMP-03-RED',
        currentKg: 4.20,
        maxKg: 8.00,
        itemCount: 34,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 22.0,
      ),
      CompartmentModel(
        category: WasteCategory.otherBlue,
        title: 'Glassware & Non-Infectious',
        codeName: 'COMP-04-BLUE',
        currentKg: 2.10,
        maxKg: 6.00,
        itemCount: 19,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 21.5,
      ),
    ];
  }

  /// AI Detection items for simulation cycle
  final List<WasteItemModel> mockAiItems = [
    WasteItemModel(
      id: 'ITEM-8812',
      detectedObject: 'Contaminated Nitrile Gloves',
      category: WasteCategory.infectiousYellow,
      confidence: 0.942,
      weightKg: 0.18,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      internalActionDetails: 'UV-C sanitizer misted & Diverter Gate #2 opened ➔ Locked',
      boundingBox: const NormalizedRect(left: 0.22, top: 0.25, width: 0.54, height: 0.46),
      verificationHash: '0x8f2d9c41a0e71b23',
    ),
    WasteItemModel(
      id: 'ITEM-8813',
      detectedObject: 'Surgical Scalpel Blade #11',
      category: WasteCategory.sharpsWhite,
      confidence: 0.989,
      weightKg: 0.04,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      internalActionDetails: 'Magnetic chute active ➔ Deposited to Sharps Vault #1',
      boundingBox: const NormalizedRect(left: 0.35, top: 0.32, width: 0.32, height: 0.38),
      verificationHash: '0x4c19ba88d23e5f01',
    ),
    WasteItemModel(
      id: 'ITEM-8814',
      detectedObject: 'IV Infusion Tubing Set',
      category: WasteCategory.plasticRed,
      confidence: 0.938,
      weightKg: 0.22,
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      internalActionDetails: 'Mechanical wiper pushed item to Red Plastic Chamber #3',
      boundingBox: const NormalizedRect(left: 0.18, top: 0.20, width: 0.62, height: 0.52),
      verificationHash: '0x17ea992f801c34a7',
    ),
    WasteItemModel(
      id: 'ITEM-8815',
      detectedObject: 'Saline Glass Ampoule 10ml',
      category: WasteCategory.otherBlue,
      confidence: 0.954,
      weightKg: 0.06,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      internalActionDetails: 'Padded descent baffle engaged ➔ Soft drop to Blue Bin #4',
      boundingBox: const NormalizedRect(left: 0.38, top: 0.28, width: 0.26, height: 0.44),
      verificationHash: '0xbb3098f1025daec4',
    ),
    WasteItemModel(
      id: 'ITEM-8816',
      detectedObject: 'Disposable Syringe (Without Needle)',
      category: WasteCategory.plasticRed,
      confidence: 0.975,
      weightKg: 0.08,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      internalActionDetails: 'Rotary carousel aligned ➔ Gate #3 opened and sealed',
      boundingBox: const NormalizedRect(left: 0.28, top: 0.26, width: 0.42, height: 0.48),
      verificationHash: '0x7e8823f6d41a9901',
    ),
    WasteItemModel(
      id: 'ITEM-8817',
      detectedObject: 'Blood Collection Vacutainer',
      category: WasteCategory.infectiousYellow,
      confidence: 0.961,
      weightKg: 0.12,
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      internalActionDetails: 'Aerosol containment active & Solenoid Gate #2 engaged',
      boundingBox: const NormalizedRect(left: 0.32, top: 0.22, width: 0.36, height: 0.55),
      verificationHash: '0xd041ea2277bb0198',
    ),
    WasteItemModel(
      id: 'ITEM-8818',
      detectedObject: 'Surgical Hypodermic Needle 21G',
      category: WasteCategory.sharpsWhite,
      confidence: 0.992,
      weightKg: 0.02,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      internalActionDetails: 'Puncture-resistant drop hatch activated ➔ Locked',
      boundingBox: const NormalizedRect(left: 0.40, top: 0.30, width: 0.22, height: 0.40),
      verificationHash: '0xfe31889920bba542',
    ),
  ];

  /// Realistic CPCB (Central Pollution Control Board) Compliance History Records
  List<Map<String, dynamic>> getInitialHistoricalLedger() {
    final now = DateTime.now();
    return [
      {
        'id': 'CW-1024',
        'ward': 'ICU-01 (Intensive Care)',
        'timestamp': now.subtract(const Duration(hours: 1, minutes: 15)),
        'totalWeightKg': 3.42,
        'itemCount': 18,
        'breakdown': {
          'sharpsKg': 0.32,
          'infectiousKg': 2.10,
          'plasticKg': 0.85,
          'otherKg': 0.15,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Autoclave Facility (Unit 1)',
        'token': '0x8f2d9c41a0e71b23c914e672901aef55',
        'robotId': 'SMW-ROBOT-01',
        'operator': 'Nurse Sunita K. (ID #442)',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9901)',
      },
      {
        'id': 'CW-1023',
        'ward': 'OT-03 (Operation Theatre)',
        'timestamp': now.subtract(const Duration(hours: 3, minutes: 40)),
        'totalWeightKg': 5.80,
        'itemCount': 31,
        'breakdown': {
          'sharpsKg': 0.85,
          'infectiousKg': 3.20,
          'plasticKg': 1.45,
          'otherKg': 0.30,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Incineration Vault (Chamber B)',
        'token': '0x37a892bcf40188dc22780e4198fa01cc',
        'robotId': 'SMW-ROBOT-01',
        'operator': 'Dr. Ramanujam (OT Head)',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9889)',
      },
      {
        'id': 'CW-1022',
        'ward': 'Emergency & Trauma (Bay 4)',
        'timestamp': now.subtract(const Duration(hours: 6, minutes: 10)),
        'totalWeightKg': 4.15,
        'itemCount': 24,
        'breakdown': {
          'sharpsKg': 0.44,
          'infectiousKg': 2.45,
          'plasticKg': 0.96,
          'otherKg': 0.30,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Microwave Disinfection Hub',
        'token': '0x49da107298bc330198efaa092147bb31',
        'robotId': 'SMW-ROBOT-01',
        'operator': 'Staff Brother Anil P.',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9872)',
      },
      {
        'id': 'CW-1021',
        'ward': 'General Ward A (West)',
        'timestamp': now.subtract(const Duration(hours: 9, minutes: 25)),
        'totalWeightKg': 2.90,
        'itemCount': 16,
        'breakdown': {
          'sharpsKg': 0.12,
          'infectiousKg': 1.30,
          'plasticKg': 1.18,
          'otherKg': 0.30,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Autoclave Facility (Unit 2)',
        'token': '0x9924baef1092cc7718223940bbd01490',
        'robotId': 'SMW-ROBOT-01',
        'operator': 'Nurse Meena Sharma',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9854)',
      },
      {
        'id': 'CW-1020',
        'ward': 'Pathology Lab & Diagnostics',
        'timestamp': now.subtract(const Duration(hours: 14, minutes: 05)),
        'totalWeightKg': 2.15,
        'itemCount': 14,
        'breakdown': {
          'sharpsKg': 0.28,
          'infectiousKg': 1.10,
          'plasticKg': 0.45,
          'otherKg': 0.32,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Autoclave Facility (Unit 1)',
        'token': '0x10b784ae90cd552199fba203498ac612',
        'robotId': 'SMW-ROBOT-01',
        'operator': 'Technician Rajesh V.',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9840)',
      },
      {
        'id': 'CW-1019',
        'ward': 'Pediatrics Ward 2',
        'timestamp': now.subtract(const Duration(hours: 19, minutes: 30)),
        'totalWeightKg': 1.75,
        'itemCount': 11,
        'breakdown': {
          'sharpsKg': 0.08,
          'infectiousKg': 0.85,
          'plasticKg': 0.62,
          'otherKg': 0.20,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Microwave Disinfection Hub',
        'token': '0x88cc2491bba092837482910fedca3102',
        'robotId': 'SMW-ROBOT-01',
        'operator': 'Nurse Priya Nair',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9828)',
      },
    ];
  }

  /// Initial Seed Alerts
  List<AlertModel> getInitialAlerts() {
    final now = DateTime.now();
    return [
      AlertModel(
        id: 'ALT-101',
        level: AlertLevel.warning,
        title: 'Compartment 2 (Yellow) Reached 86% Capacity',
        message: 'Infectious biohazard waste has reached 8.60 kg of 10.0 kg limit. Schedule a central dump soon.',
        timestamp: now.subtract(const Duration(minutes: 18)),
        isAcknowledged: false,
        relatedSubsystem: 'Compartment Sensor (Load Cell #2)',
      ),
      AlertModel(
        id: 'ALT-102',
        level: AlertLevel.info,
        title: 'LiDAR & Vision AI Calibration Completed',
        message: 'Spatial SLAM map updated with ICU Corridor B temporary obstruction clearance.',
        timestamp: now.subtract(const Duration(minutes: 42)),
        isAcknowledged: true,
        relatedSubsystem: 'Perception (Ouster LiDAR)',
      ),
      AlertModel(
        id: 'ALT-103',
        level: AlertLevel.critical,
        title: 'Biohazard Gate Interlock Seal Verified',
        message: 'Negative pressure differential maintained inside Infectious compartment; UV-C lamp operating at nominal 254nm.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        isAcknowledged: true,
        relatedSubsystem: 'Sterilization Chamber',
      ),
      AlertModel(
        id: 'ALT-104',
        level: AlertLevel.info,
        title: 'Battery Cell Balancing Optimal',
        message: 'LiFePO4 4S battery pack cells balanced at 3.32V per cell. Temp 30.5°C.',
        timestamp: now.subtract(const Duration(hours: 4)),
        isAcknowledged: true,
        relatedSubsystem: 'Power & BMS',
      ),
    ];
  }

  /// Active default mission
  MissionModel getInitialMission() {
    return MissionModel(
      missionId: 'MIS-2026-089',
      department: 'ICU - Intensive Care',
      stationId: 'ICU-01 Station',
      priority: MissionPriority.high,
      status: RobotStatus.idle == RobotStatus.idle ? MissionStatus.pending : MissionStatus.navigating,
      requestedBy: 'Nurse Sunita K. (ICU Floor Incharge)',
      requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      notes: 'Contaminated surgical sets and dressings ready for segregated pickup.',
      routeWaypoints: const [
        'Central Bay A',
        'Main Corridor North',
        'ICU Airlock Door 1',
        'ICU-01 Station',
      ],
      estimatedArrivalMins: 2.8,
    );
  }

  /// Daily Generation analytics points for chart
  List<double> getDailyGenerationTrend() {
    return [11.2, 14.8, 12.4, 16.1, 13.9, 15.2, 16.75]; // Last 7 days total kg
  }

  /// Category distribution totals (Sharps, Infectious, Plastic, Other)
  Map<WasteCategory, double> getCategoryDistributionTotals() {
    return {
      WasteCategory.sharpsWhite: 1.85 + 2.09, // ~3.94 kg
      WasteCategory.infectiousYellow: 8.60 + 11.00, // ~19.60 kg
      WasteCategory.plasticRed: 4.20 + 5.48, // ~9.68 kg
      WasteCategory.otherBlue: 2.10 + 1.57, // ~3.67 kg
    };
  }
}
