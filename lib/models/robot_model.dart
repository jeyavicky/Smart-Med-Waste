import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum RobotStatus {
  idle,
  enRoute,
  collecting,
  discharging,
  docked,
  offline;

  // Backward compatibility aliases
  static const RobotStatus navigatingToWard = RobotStatus.enRoute;
  static const RobotStatus segregatingWaste = RobotStatus.collecting;
  static const RobotStatus returningToDisposal = RobotStatus.discharging;
  static const RobotStatus dockedCharging = RobotStatus.docked;
  static const RobotStatus emergencyStop = RobotStatus.offline;
}

extension RobotStatusExtension on RobotStatus {
  String get displayName {
    switch (this) {
      case RobotStatus.idle:
        return 'IDLE / STANDBY';
      case RobotStatus.enRoute:
        return 'TRANSIT / EN ROUTE';
      case RobotStatus.collecting:
        return 'COLLECTING WASTE';
      case RobotStatus.discharging:
        return 'DISCHARGING AT BAY';
      case RobotStatus.docked:
        return 'DOCKED & CHARGING';
      case RobotStatus.offline:
        return 'OFFLINE / E-STOP';
    }
  }

  Color get statusColor {
    switch (this) {
      case RobotStatus.idle:
        return AppConstants.textSecondary;
      case RobotStatus.enRoute:
        return AppConstants.medicalTeal;
      case RobotStatus.collecting:
        return AppConstants.amberWarning;
      case RobotStatus.discharging:
        return const Color(0xFF2563EB);
      case RobotStatus.docked:
        return const Color(0xFF10B981);
      case RobotStatus.offline:
        return AppConstants.crimsonDanger;
    }
  }

  IconData get icon {
    switch (this) {
      case RobotStatus.idle:
        return Icons.pause_circle_outline;
      case RobotStatus.enRoute:
        return Icons.navigation_outlined;
      case RobotStatus.collecting:
        return Icons.scanner_outlined;
      case RobotStatus.discharging:
        return Icons.restore_from_trash_outlined;
      case RobotStatus.docked:
        return Icons.battery_charging_full_outlined;
      case RobotStatus.offline:
        return Icons.dangerous_outlined;
    }
  }
}

class Compartment {
  final String id;
  final String name;
  final Color badgeColor;
  final Color lightColor;
  final double currentWeightKg;
  final double capacityKg;
  final int fillPercentage;
  final bool isFull;

  Compartment({
    required this.id,
    required this.name,
    required this.badgeColor,
    required this.lightColor,
    required this.currentWeightKg,
    required this.capacityKg,
    required this.fillPercentage,
    required this.isFull,
  });

  double get fillRatio => (fillPercentage / 100.0).clamp(0.0, 1.0);
  bool get isWarning => fillPercentage >= 85;

  Compartment copyWith({
    String? id,
    String? name,
    Color? badgeColor,
    Color? lightColor,
    double? currentWeightKg,
    double? capacityKg,
    int? fillPercentage,
    bool? isFull,
  }) {
    return Compartment(
      id: id ?? this.id,
      name: name ?? this.name,
      badgeColor: badgeColor ?? this.badgeColor,
      lightColor: lightColor ?? this.lightColor,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      capacityKg: capacityKg ?? this.capacityKg,
      fillPercentage: fillPercentage ?? this.fillPercentage,
      isFull: isFull ?? this.isFull,
    );
  }
}

class RobotCoordinates {
  final double x;
  final double y;
  final double headingDegrees;
  final String floor;

  const RobotCoordinates({
    required this.x,
    required this.y,
    required this.headingDegrees,
    this.floor = 'Floor 2 (ICU Wing)',
  });

  RobotCoordinates copyWith({
    double? x,
    double? y,
    double? headingDegrees,
    String? floor,
  }) {
    return RobotCoordinates(
      x: x ?? this.x,
      y: y ?? this.y,
      headingDegrees: headingDegrees ?? this.headingDegrees,
      floor: floor ?? this.floor,
    );
  }
}

class SubsystemHealth {
  final bool driveMotors;
  final bool lidarDepthSensors;
  final bool aiVisionCamera;
  final bool loadCells;
  final bool internalLocking;

  const SubsystemHealth({
    this.driveMotors = true,
    this.lidarDepthSensors = true,
    this.aiVisionCamera = true,
    this.loadCells = true,
    this.internalLocking = true,
  });

  bool get isAllHealthy =>
      driveMotors &&
      lidarDepthSensors &&
      aiVisionCamera &&
      loadCells &&
      internalLocking;

  SubsystemHealth copyWith({
    bool? driveMotors,
    bool? lidarDepthSensors,
    bool? aiVisionCamera,
    bool? loadCells,
    bool? internalLocking,
  }) {
    return SubsystemHealth(
      driveMotors: driveMotors ?? this.driveMotors,
      lidarDepthSensors: lidarDepthSensors ?? this.lidarDepthSensors,
      aiVisionCamera: aiVisionCamera ?? this.aiVisionCamera,
      loadCells: loadCells ?? this.loadCells,
      internalLocking: internalLocking ?? this.internalLocking,
    );
  }
}

class RobotModel {
  final String id; // e.g., 'R01'
  final String name; // 'Sanitation Rover 1'
  final String assignedWard;
  final RobotStatus status;
  final int batteryLevel; // percentage
  final double voltage;
  final double temperatureC;
  final Map<String, Compartment> compartments; // 5 compartments
  final bool aiCameraActive;

  // Supplementary telemetry & diagnostics
  final double currentAmps;
  final RobotCoordinates coordinates;
  final SubsystemHealth health;
  final DateTime lastHeartbeat;
  final bool isOnline;

  RobotModel({
    required this.id,
    required this.name,
    required this.assignedWard,
    required this.status,
    required this.batteryLevel,
    required this.voltage,
    required this.temperatureC,
    required this.compartments,
    required this.aiCameraActive,
    this.currentAmps = 1.8,
    this.coordinates = const RobotCoordinates(x: 120.0, y: 85.0, headingDegrees: 45.0),
    this.health = const SubsystemHealth(),
    DateTime? lastHeartbeat,
    bool? isOnline,
  })  : lastHeartbeat = lastHeartbeat ?? DateTime.now(),
        isOnline = isOnline ?? (status != RobotStatus.offline);

  // Backward-compatibility getters
  double get batteryPercent => batteryLevel.toDouble();
  String get currentWard => assignedWard;
  double get tempCelsius => temperatureC;

  double get totalCurrentKg =>
      compartments.values.fold(0.0, (sum, c) => sum + c.currentWeightKg);

  double get totalCapacityKg =>
      compartments.values.fold(0.0, (sum, c) => sum + c.capacityKg);

  RobotModel copyWith({
    String? id,
    String? name,
    String? assignedWard,
    RobotStatus? status,
    int? batteryLevel,
    double? voltage,
    double? temperatureC,
    Map<String, Compartment>? compartments,
    bool? aiCameraActive,
    double? currentAmps,
    RobotCoordinates? coordinates,
    SubsystemHealth? health,
    DateTime? lastHeartbeat,
    bool? isOnline,
  }) {
    return RobotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      assignedWard: assignedWard ?? this.assignedWard,
      status: status ?? this.status,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      voltage: voltage ?? this.voltage,
      temperatureC: temperatureC ?? this.temperatureC,
      compartments: compartments ?? this.compartments,
      aiCameraActive: aiCameraActive ?? this.aiCameraActive,
      currentAmps: currentAmps ?? this.currentAmps,
      coordinates: coordinates ?? this.coordinates,
      health: health ?? this.health,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
