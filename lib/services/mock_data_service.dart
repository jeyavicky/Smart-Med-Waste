import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/robot_model.dart';
import '../models/waste_item_model.dart';
import '../models/mission_model.dart';
import '../models/compartment_model.dart';
import '../models/alert_model.dart';

/// Comprehensive Mock Data Service providing realistic healthcare seed data
/// and dynamic simulation cycling for Multi-Robot Fleet and 5-Compartment Segregation.
class MockDataService {
  static final MockDataService instance = MockDataService._internal();
  MockDataService._internal();

  /// Creates standard 5-compartment map for a robot
  static Map<String, Compartment> create5Compartments({
    required double sharpsKg,
    required double infectiousKg,
    required double plasticKg,
    required double glasswareKg,
    required double unknownOthersKg,
  }) {
    return {
      'sharps': Compartment(
        id: 'sharps',
        name: 'Sharps & Needles',
        badgeColor: AppConstants.sharpsBadge,
        lightColor: AppConstants.sharpsLightBg,
        currentWeightKg: sharpsKg,
        capacityKg: 5.0,
        fillPercentage: ((sharpsKg / 5.0) * 100).round(),
        isFull: sharpsKg >= 5.0,
      ),
      'infectious': Compartment(
        id: 'infectious',
        name: 'Infectious Biohazard',
        badgeColor: AppConstants.infectiousBadge,
        lightColor: AppConstants.infectiousLightBg,
        currentWeightKg: infectiousKg,
        capacityKg: 10.0,
        fillPercentage: ((infectiousKg / 10.0) * 100).round(),
        isFull: infectiousKg >= 10.0,
      ),
      'plastic': Compartment(
        id: 'plastic',
        name: 'Plastic / Recyclable',
        badgeColor: AppConstants.plasticBadge,
        lightColor: AppConstants.plasticLightBg,
        currentWeightKg: plasticKg,
        capacityKg: 8.0,
        fillPercentage: ((plasticKg / 8.0) * 100).round(),
        isFull: plasticKg >= 8.0,
      ),
      'glassware': Compartment(
        id: 'glassware',
        name: 'Glassware / Cytotoxic',
        badgeColor: AppConstants.glasswareBadge,
        lightColor: AppConstants.glasswareLightBg,
        currentWeightKg: glasswareKg,
        capacityKg: 6.0,
        fillPercentage: ((glasswareKg / 6.0) * 100).round(),
        isFull: glasswareKg >= 6.0,
      ),
      'unknownOthers': Compartment(
        id: 'unknownOthers',
        name: 'Unknown / Others',
        badgeColor: AppConstants.unknownBadge,
        lightColor: AppConstants.unknownLightBg,
        currentWeightKg: unknownOthersKg,
        capacityKg: 5.0,
        fillPercentage: ((unknownOthersKg / 5.0) * 100).round(),
        isFull: unknownOthersKg >= 5.0,
      ),
    };
  }

  /// Initial Multi-Robot Fleet (AMRs R01 - R04)
  List<RobotModel> getInitialFleet() {
    return [
      // Robot R01: Active - ICU Wing
      RobotModel(
        id: 'R01',
        name: 'Sanitation Rover 1',
        assignedWard: 'ICU Wing (Floor 2)',
        status: RobotStatus.collecting,
        batteryLevel: 88,
        voltage: 12.2,
        temperatureC: 30.5,
        aiCameraActive: true,
        currentAmps: 2.1,
        coordinates: const RobotCoordinates(
          x: 120.0,
          y: 85.0,
          headingDegrees: 45.0,
          floor: 'Floor 2 (ICU Wing)',
        ),
        compartments: create5Compartments(
          sharpsKg: 1.85,
          infectiousKg: 8.60,
          plasticKg: 4.20,
          glasswareKg: 2.10,
          unknownOthersKg: 0.65,
        ),
      ),

      // Robot R02: Transit - Surgery / OT Block
      RobotModel(
        id: 'R02',
        name: 'Sanitation Rover 2',
        assignedWard: 'Surgery / OT Block (Floor 3)',
        status: RobotStatus.enRoute,
        batteryLevel: 74,
        voltage: 12.0,
        temperatureC: 31.8,
        aiCameraActive: true,
        currentAmps: 3.4,
        coordinates: const RobotCoordinates(
          x: 180.0,
          y: 110.0,
          headingDegrees: 90.0,
          floor: 'Floor 3 (OT Block)',
        ),
        compartments: create5Compartments(
          sharpsKg: 0.90,
          infectiousKg: 4.30,
          plasticKg: 3.10,
          glasswareKg: 1.40,
          unknownOthersKg: 0.40,
        ),
      ),

      // Robot R03: Docked / Charging - Central Waste Bay
      RobotModel(
        id: 'R03',
        name: 'Sanitation Rover 3',
        assignedWard: 'Central Waste Bay (Basement)',
        status: RobotStatus.docked,
        batteryLevel: 96,
        voltage: 13.8,
        temperatureC: 28.4,
        aiCameraActive: false,
        currentAmps: 4.5, // charging current
        coordinates: const RobotCoordinates(
          x: 230.0,
          y: 260.0,
          headingDegrees: 180.0,
          floor: 'Basement Disinfection Hub',
        ),
        compartments: create5Compartments(
          sharpsKg: 0.15,
          infectiousKg: 0.20,
          plasticKg: 0.18,
          glasswareKg: 0.10,
          unknownOthersKg: 0.05,
        ),
      ),

      // Robot R04: Standby - General Ward 3
      RobotModel(
        id: 'R04',
        name: 'Sanitation Rover 4',
        assignedWard: 'General Ward 3 (Floor 1)',
        status: RobotStatus.idle,
        batteryLevel: 82,
        voltage: 12.1,
        temperatureC: 29.8,
        aiCameraActive: true,
        currentAmps: 1.4,
        coordinates: const RobotCoordinates(
          x: 75.0,
          y: 65.0,
          headingDegrees: 0.0,
          floor: 'Floor 1 (General Ward 3)',
        ),
        compartments: create5Compartments(
          sharpsKg: 1.20,
          infectiousKg: 3.80,
          plasticKg: 2.40,
          glasswareKg: 0.80,
          unknownOthersKg: 0.35,
        ),
      ),
    ];
  }

  /// Initial Robot telemetry state (R01 default)
  RobotModel getInitialRobot() => getInitialFleet().first;

  /// Initial 5 Compartments as CompartmentModels for detail dialogs & feeds
  List<CompartmentModel> getInitialCompartments() {
    return [
      const CompartmentModel(
        category: WasteCategory.sharps,
        title: 'Sharps & Needles',
        codeName: 'COMP-01-SHARPS',
        currentKg: 1.85,
        maxKg: 5.00,
        itemCount: 42,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 21.8,
      ),
      const CompartmentModel(
        category: WasteCategory.infectious,
        title: 'Infectious Biohazard',
        codeName: 'COMP-02-INFECTIOUS',
        currentKg: 8.60,
        maxKg: 10.00,
        itemCount: 68,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 22.1,
      ),
      const CompartmentModel(
        category: WasteCategory.plastic,
        title: 'Plastic / Recyclable',
        codeName: 'COMP-03-PLASTIC',
        currentKg: 4.20,
        maxKg: 8.00,
        itemCount: 34,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 22.0,
      ),
      const CompartmentModel(
        category: WasteCategory.glassware,
        title: 'Glassware / Cytotoxic',
        codeName: 'COMP-04-GLASSWARE',
        currentKg: 2.10,
        maxKg: 6.00,
        itemCount: 19,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 21.5,
      ),
      const CompartmentModel(
        category: WasteCategory.unknownOthers,
        title: 'Unknown / Others (Fallback)',
        codeName: 'COMP-05-UNKNOWN',
        currentKg: 0.65,
        maxKg: 5.00,
        itemCount: 6,
        gateStatus: GateStatus.locked,
        sealIntegrityOk: true,
        temperatureCelsius: 22.3,
      ),
    ];
  }

  /// AI Detection items for simulation cycle across 5 categories
  final List<WasteItemModel> mockAiItems = [
    WasteItemModel(
      id: 'ITEM-8812',
      detectedObject: 'Contaminated Nitrile Gloves',
      category: WasteCategory.infectious,
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
      category: WasteCategory.sharps,
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
      category: WasteCategory.plastic,
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
      category: WasteCategory.glassware,
      confidence: 0.954,
      weightKg: 0.06,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      internalActionDetails: 'Padded descent baffle engaged ➔ Soft drop to Glass Chamber #4',
      boundingBox: const NormalizedRect(left: 0.38, top: 0.28, width: 0.26, height: 0.44),
      verificationHash: '0xbb3098f1025daec4',
    ),
    WasteItemModel(
      id: 'ITEM-8816',
      detectedObject: 'Unrecognized Foil Packaging / Non-Biomedical',
      category: WasteCategory.unknownOthers,
      confidence: 0.584,
      weightKg: 0.09,
      timestamp: DateTime.now().subtract(const Duration(minutes: 14)),
      internalActionDetails: 'Confidence <70% ➔ Diverted to Gate #5 (Unknown/Others Fallback)',
      boundingBox: const NormalizedRect(left: 0.30, top: 0.28, width: 0.40, height: 0.45),
      verificationHash: '0xa419de0023e117bc',
    ),
    WasteItemModel(
      id: 'ITEM-8817',
      detectedObject: 'Disposable Syringe (Without Needle)',
      category: WasteCategory.plastic,
      confidence: 0.975,
      weightKg: 0.08,
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      internalActionDetails: 'Rotary carousel aligned ➔ Gate #3 opened and sealed',
      boundingBox: const NormalizedRect(left: 0.28, top: 0.26, width: 0.42, height: 0.48),
      verificationHash: '0x7e8823f6d41a9901',
    ),
    WasteItemModel(
      id: 'ITEM-8818',
      detectedObject: 'Blood Collection Vacutainer',
      category: WasteCategory.infectious,
      confidence: 0.961,
      weightKg: 0.12,
      timestamp: DateTime.now().subtract(const Duration(minutes: 22)),
      internalActionDetails: 'Aerosol containment active & Solenoid Gate #2 engaged',
      boundingBox: const NormalizedRect(left: 0.32, top: 0.22, width: 0.36, height: 0.55),
      verificationHash: '0xd041ea2277bb0198',
    ),
    WasteItemModel(
      id: 'ITEM-8819',
      detectedObject: 'Surgical Hypodermic Needle 21G',
      category: WasteCategory.sharps,
      confidence: 0.992,
      weightKg: 0.02,
      timestamp: DateTime.now().subtract(const Duration(minutes: 26)),
      internalActionDetails: 'Puncture-resistant drop hatch activated ➔ Locked',
      boundingBox: const NormalizedRect(left: 0.40, top: 0.30, width: 0.22, height: 0.40),
      verificationHash: '0xfe31889920bba542',
    ),
    WasteItemModel(
      id: 'ITEM-8820',
      detectedObject: 'Cytotoxic Medicine Glass Vial',
      category: WasteCategory.glassware,
      confidence: 0.948,
      weightKg: 0.11,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      internalActionDetails: 'Heavy metal containment sealed ➔ Gate #4 Locked',
      boundingBox: const NormalizedRect(left: 0.36, top: 0.26, width: 0.28, height: 0.48),
      verificationHash: '0x334acb11902eb921',
    ),
  ];

  /// Realistic CPCB (Central Pollution Control Board) Compliance History Records
  List<Map<String, dynamic>> getInitialHistoricalLedger() {
    final now = DateTime.now();
    return [
      {
        'id': 'CW-1024',
        'ward': 'ICU Wing (Floor 2)',
        'timestamp': now.subtract(const Duration(hours: 1, minutes: 15)),
        'totalWeightKg': 3.42,
        'itemCount': 18,
        'breakdown': {
          'sharpsKg': 0.32,
          'infectiousKg': 2.10,
          'plasticKg': 0.70,
          'glasswareKg': 0.20,
          'unknownOthersKg': 0.10,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Autoclave Facility (Unit 1)',
        'token': '0x8f2d9c41a0e71b23c914e672901aef55',
        'robotId': 'R01',
        'operator': 'Nurse Sunita K. (ID #442)',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9901)',
      },
      {
        'id': 'CW-1023',
        'ward': 'Surgery / OT Block (Floor 3)',
        'timestamp': now.subtract(const Duration(hours: 3, minutes: 40)),
        'totalWeightKg': 5.80,
        'itemCount': 31,
        'breakdown': {
          'sharpsKg': 0.85,
          'infectiousKg': 3.20,
          'plasticKg': 1.30,
          'glasswareKg': 0.35,
          'unknownOthersKg': 0.10,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Incineration Vault (Chamber B)',
        'token': '0x37a892bcf40188dc22780e4198fa01cc',
        'robotId': 'R02',
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
          'plasticKg': 0.86,
          'glasswareKg': 0.30,
          'unknownOthersKg': 0.10,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Microwave Disinfection Hub',
        'token': '0x49da107298bc330198efaa092147bb31',
        'robotId': 'R01',
        'operator': 'Staff Brother Anil P.',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9872)',
      },
      {
        'id': 'CW-1021',
        'ward': 'General Ward 3 (Floor 1)',
        'timestamp': now.subtract(const Duration(hours: 9, minutes: 25)),
        'totalWeightKg': 2.90,
        'itemCount': 16,
        'breakdown': {
          'sharpsKg': 0.12,
          'infectiousKg': 1.30,
          'plasticKg': 1.10,
          'glasswareKg': 0.28,
          'unknownOthersKg': 0.10,
        },
        'status': 'VERIFIED & DUMPED',
        'facility': 'Central Autoclave Facility (Unit 2)',
        'token': '0x9924baef1092cc7718223940bbd01490',
        'robotId': 'R04',
        'operator': 'Nurse Meena Sharma',
        'complianceStatus': 'CPCB Compliant (Barcode #CPCB-2026-9854)',
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
        title: 'R01 Infectious Compartment at 86% Capacity',
        message: 'Infectious biohazard waste has reached 8.60 kg of 10.0 kg limit. Schedule a central dump soon.',
        timestamp: now.subtract(const Duration(minutes: 18)),
        isAcknowledged: false,
        relatedSubsystem: 'R01 Load Cell #2',
      ),
      AlertModel(
        id: 'ALT-102',
        level: AlertLevel.info,
        title: 'Unknown Waste Filter Engaged on R01',
        message: 'Low-confidence non-biomedical packaging routed to Fallback Chamber #5 to prevent batch contamination.',
        timestamp: now.subtract(const Duration(minutes: 32)),
        isAcknowledged: true,
        relatedSubsystem: 'AI Perception Chute',
      ),
      AlertModel(
        id: 'ALT-103',
        level: AlertLevel.info,
        title: 'Fleet Heartbeat Sync Completed',
        message: '4 AMR nodes active: R01 (ICU), R02 (OT), R03 (Charging Bay), R04 (GenWard 3).',
        timestamp: now.subtract(const Duration(minutes: 45)),
        isAcknowledged: true,
        relatedSubsystem: 'Fleet Orchestrator',
      ),
      AlertModel(
        id: 'ALT-104',
        level: AlertLevel.critical,
        title: 'Hermetic Gate Interlock Active on R02',
        message: 'Negative pressure differential maintained inside surgery transit block.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        isAcknowledged: true,
        relatedSubsystem: 'Sterilization Chamber',
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
      status: MissionStatus.collecting,
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
    return [11.2, 14.8, 12.4, 16.1, 13.9, 15.2, 16.75];
  }

  /// Category distribution totals across 5 categories
  Map<WasteCategory, double> getCategoryDistributionTotals() {
    return {
      WasteCategory.sharps: 3.94,
      WasteCategory.infectious: 19.60,
      WasteCategory.plastic: 9.68,
      WasteCategory.glassware: 3.67,
      WasteCategory.unknownOthers: 1.50,
    };
  }
}
