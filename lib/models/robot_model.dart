import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum RobotStatus {
  idle,
  navigatingToWard,
  segregatingWaste,
  returningToDisposal,
  dockedCharging,
  emergencyStop,
}

extension RobotStatusExtension on RobotStatus {
  String get displayName {
    switch (this) {
      case RobotStatus.idle:
        return 'IDLE / STANDBY';
      case RobotStatus.navigatingToWard:
        return 'NAVIGATING TO WARD';
      case RobotStatus.segregatingWaste:
        return 'SEGREGATING WASTE';
      case RobotStatus.returningToDisposal:
        return 'RETURNING TO CENTRAL DISPOSAL';
      case RobotStatus.dockedCharging:
        return 'DOCKED & CHARGING';
      case RobotStatus.emergencyStop:
        return 'EMERGENCY STOP (ACTIVE)';
    }
  }

  Color get statusColor {
    switch (this) {
      case RobotStatus.idle:
        return AppConstants.lightSlate;
      case RobotStatus.navigatingToWard:
        return AppConstants.tealAccent;
      case RobotStatus.segregatingWaste:
        return AppConstants.amberWarning;
      case RobotStatus.returningToDisposal:
        return AppConstants.otherColor;
      case RobotStatus.dockedCharging:
        return const Color(0xFF10B981);
      case RobotStatus.emergencyStop:
        return AppConstants.crimsonDanger;
    }
  }

  IconData get icon {
    switch (this) {
      case RobotStatus.idle:
        return Icons.pause_circle_outline;
      case RobotStatus.navigatingToWard:
        return Icons.navigation_outlined;
      case RobotStatus.segregatingWaste:
        return Icons.scanner_outlined;
      case RobotStatus.returningToDisposal:
        return Icons.undo_outlined;
      case RobotStatus.dockedCharging:
        return Icons.battery_charging_full_outlined;
      case RobotStatus.emergencyStop:
        return Icons.dangerous_outlined;
    }
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
  final String id;
  final String name;
  final RobotStatus status;
  final double batteryPercent;
  final double voltage;
  final double currentAmps;
  final double tempCelsius;
  final String currentWard;
  final RobotCoordinates coordinates;
  final SubsystemHealth health;
  final DateTime lastHeartbeat;
  final bool isOnline;

  const RobotModel({
    required this.id,
    required this.name,
    required this.status,
    required this.batteryPercent,
    required this.voltage,
    required this.currentAmps,
    required this.tempCelsius,
    required this.currentWard,
    required this.coordinates,
    required this.health,
    required this.lastHeartbeat,
    this.isOnline = true,
  });

  RobotModel copyWith({
    String? id,
    String? name,
    RobotStatus? status,
    double? batteryPercent,
    double? voltage,
    double? currentAmps,
    double? tempCelsius,
    String? currentWard,
    RobotCoordinates? coordinates,
    SubsystemHealth? health,
    DateTime? lastHeartbeat,
    bool? isOnline,
  }) {
    return RobotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      voltage: voltage ?? this.voltage,
      currentAmps: currentAmps ?? this.currentAmps,
      tempCelsius: tempCelsius ?? this.tempCelsius,
      currentWard: currentWard ?? this.currentWard,
      coordinates: coordinates ?? this.coordinates,
      health: health ?? this.health,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
