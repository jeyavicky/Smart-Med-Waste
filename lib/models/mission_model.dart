import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

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
        return AppTheme.accentTeal;
      case MissionPriority.high:
        return AppTheme.infectiousColor;
      case MissionPriority.emergencyBiologicalSpill:
        return AppTheme.plasticColor;
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

/// 11-Step Mission Lifecycle:
/// PENDING ➔ ASSIGNED ➔ DISPATCHED ➔ EN_ROUTE ➔ ARRIVED ➔
/// COLLECTING ➔ ANALYZING ➔ SEGREGATING ➔ RETURNING ➔ DISPOSAL ➔ COMPLETED
enum MissionLifecycleStatus {
  pending,
  assigned,
  dispatched,
  enRoute,
  arrived,
  collecting,
  analyzing,
  segregating,
  returning,
  disposal,
  completed,
  cancelled;

  // Backward compatibility aliases
  static const MissionLifecycleStatus navigating = MissionLifecycleStatus.enRoute;
}

typedef MissionStatus = MissionLifecycleStatus;

extension MissionStatusExtension on MissionLifecycleStatus {
  String get displayName {
    switch (this) {
      case MissionLifecycleStatus.pending:
        return 'PENDING';
      case MissionLifecycleStatus.assigned:
        return 'ASSIGNED';
      case MissionLifecycleStatus.dispatched:
        return 'DISPATCHED';
      case MissionLifecycleStatus.enRoute:
        return 'EN ROUTE';
      case MissionLifecycleStatus.arrived:
        return 'ARRIVED AT WARD';
      case MissionLifecycleStatus.collecting:
        return 'COLLECTING';
      case MissionLifecycleStatus.analyzing:
        return 'ANALYZING (AI)';
      case MissionLifecycleStatus.segregating:
        return 'SEGREGATING';
      case MissionLifecycleStatus.returning:
        return 'RETURNING';
      case MissionLifecycleStatus.disposal:
        return 'DISPOSAL BAY';
      case MissionLifecycleStatus.completed:
        return 'COMPLETED';
      case MissionLifecycleStatus.cancelled:
        return 'CANCELLED';
    }
  }

  int get stepIndex {
    switch (this) {
      case MissionLifecycleStatus.pending:
        return 0;
      case MissionLifecycleStatus.assigned:
        return 1;
      case MissionLifecycleStatus.dispatched:
        return 2;
      case MissionLifecycleStatus.enRoute:
        return 3;
      case MissionLifecycleStatus.arrived:
        return 4;
      case MissionLifecycleStatus.collecting:
        return 5;
      case MissionLifecycleStatus.analyzing:
        return 6;
      case MissionLifecycleStatus.segregating:
        return 7;
      case MissionLifecycleStatus.returning:
        return 8;
      case MissionLifecycleStatus.disposal:
        return 9;
      case MissionLifecycleStatus.completed:
        return 10;
      case MissionLifecycleStatus.cancelled:
        return -1;
    }
  }

  Color get color {
    switch (this) {
      case MissionLifecycleStatus.pending:
        return AppTheme.textMuted;
      case MissionLifecycleStatus.assigned:
      case MissionLifecycleStatus.dispatched:
      case MissionLifecycleStatus.enRoute:
      case MissionLifecycleStatus.arrived:
        return AppTheme.accentTeal;
      case MissionLifecycleStatus.collecting:
      case MissionLifecycleStatus.analyzing:
      case MissionLifecycleStatus.segregating:
        return AppTheme.infectiousColor;
      case MissionLifecycleStatus.returning:
      case MissionLifecycleStatus.disposal:
        return AppTheme.glasswareColor;
      case MissionLifecycleStatus.completed:
        return AppTheme.sageEmerald;
      case MissionLifecycleStatus.cancelled:
        return AppTheme.plasticColor;
    }
  }
}

class MissionModel {
  final String missionId;
  final String department;
  final String stationId;
  final String? assignedRobotId;
  final MissionPriority priority;
  final MissionLifecycleStatus status;
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
    this.assignedRobotId = 'R01',
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
    String? assignedRobotId,
    MissionPriority? priority,
    MissionLifecycleStatus? status,
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
      assignedRobotId: assignedRobotId ?? this.assignedRobotId,
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

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      missionId: json['missionId'] as String,
      department: json['department'] as String,
      stationId: json['stationId'] as String,
      assignedRobotId: json['assignedRobotId'] as String?,
      priority: MissionPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => MissionPriority.normal,
      ),
      status: MissionLifecycleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MissionLifecycleStatus.pending,
      ),
      requestedBy: json['requestedBy'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
      routeWaypoints: (json['routeWaypoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Dock Bay', 'Corridor A', 'ICU Airlock', 'ICU-01 Station'],
      estimatedArrivalMins:
          (json['estimatedArrivalMins'] as num?)?.toDouble() ?? 3.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'department': department,
      'stationId': stationId,
      'assignedRobotId': assignedRobotId,
      'priority': priority.name,
      'status': status.name,
      'requestedBy': requestedBy,
      'requestedAt': requestedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'routeWaypoints': routeWaypoints,
      'estimatedArrivalMins': estimatedArrivalMins,
    };
  }
}
