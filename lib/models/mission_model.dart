import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum MissionPriority {
  normal,
  high,
  emergencyBiologicalSpill,
}

extension MissionPriorityExtension on MissionPriority {
  String get displayName {
    switch (this) {
      case MissionPriority.normal:
        return 'NORMAL ROUTINE';
      case MissionPriority.high:
        return 'HIGH PRIORITY';
      case MissionPriority.emergencyBiologicalSpill:
        return 'BIOHAZARD EMERGENCY';
    }
  }

  Color get color {
    switch (this) {
      case MissionPriority.normal:
        return AppConstants.tealAccent;
      case MissionPriority.high:
        return AppConstants.amberWarning;
      case MissionPriority.emergencyBiologicalSpill:
        return AppConstants.crimsonDanger;
    }
  }

  IconData get icon {
    switch (this) {
      case MissionPriority.normal:
        return Icons.check_circle_outline;
      case MissionPriority.high:
        return Icons.priority_high_rounded;
      case MissionPriority.emergencyBiologicalSpill:
        return Icons.warning_amber_rounded;
    }
  }
}

enum MissionStatus {
  pending,
  dispatched,
  navigating,
  collecting,
  returning,
  completed,
  cancelled,
}

extension MissionStatusExtension on MissionStatus {
  String get displayName {
    switch (this) {
      case MissionStatus.pending:
        return 'PENDING DISPATCH';
      case MissionStatus.dispatched:
        return 'DISPATCHED';
      case MissionStatus.navigating:
        return 'IN TRANSIT TO WARD';
      case MissionStatus.collecting:
        return 'COLLECTING & SEGREGATING';
      case MissionStatus.returning:
        return 'RETURNING TO DISPOSAL';
      case MissionStatus.completed:
        return 'COMPLETED';
      case MissionStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get color {
    switch (this) {
      case MissionStatus.pending:
        return AppConstants.lightSlate;
      case MissionStatus.dispatched:
      case MissionStatus.navigating:
        return AppConstants.tealAccent;
      case MissionStatus.collecting:
        return AppConstants.amberWarning;
      case MissionStatus.returning:
        return AppConstants.otherColor;
      case MissionStatus.completed:
        return const Color(0xFF10B981);
      case MissionStatus.cancelled:
        return AppConstants.crimsonDanger;
    }
  }
}

class MissionModel {
  final String missionId;
  final String department;
  final String stationId;
  final MissionPriority priority;
  final MissionStatus status;
  final String requestedBy;
  final DateTime requestedAt;
  final DateTime? completedAt;
  final String notes;
  final List<String> routeWaypoints;
  final double estimatedArrivalMins;

  const MissionModel({
    required this.missionId,
    required this.department,
    required this.stationId,
    required this.priority,
    required this.status,
    required this.requestedBy,
    required this.requestedAt,
    this.completedAt,
    this.notes = '',
    this.routeWaypoints = const ['Dock Bay', 'Corridor A', 'ICU Airlock', 'ICU-01 Station'],
    this.estimatedArrivalMins = 3.5,
  });

  MissionModel copyWith({
    String? missionId,
    String? department,
    String? stationId,
    MissionPriority? priority,
    MissionStatus? status,
    String? requestedBy,
    DateTime? requestedAt,
    DateTime? completedAt,
    String? notes,
    List<String>? routeWaypoints,
    double? estimatedArrivalMins,
  }) {
    return MissionModel(
      missionId: missionId ?? this.missionId,
      department: department ?? this.department,
      stationId: stationId ?? this.stationId,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      requestedBy: requestedBy ?? this.requestedBy,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      routeWaypoints: routeWaypoints ?? this.routeWaypoints,
      estimatedArrivalMins: estimatedArrivalMins ?? this.estimatedArrivalMins,
    );
  }
}
