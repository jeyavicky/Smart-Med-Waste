import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum AlertLevel {
  critical,
  warning,
  info,
}

extension AlertLevelExtension on AlertLevel {
  String get displayName {
    switch (this) {
      case AlertLevel.critical:
        return 'CRITICAL';
      case AlertLevel.warning:
        return 'WARNING';
      case AlertLevel.info:
        return 'INFO';
    }
  }

  Color get color {
    switch (this) {
      case AlertLevel.critical:
        return AppConstants.crimsonDanger;
      case AlertLevel.warning:
        return AppConstants.amberWarning;
      case AlertLevel.info:
        return AppConstants.tealAccent;
    }
  }

  IconData get icon {
    switch (this) {
      case AlertLevel.critical:
        return Icons.error_rounded;
      case AlertLevel.warning:
        return Icons.warning_rounded;
      case AlertLevel.info:
        return Icons.info_outline_rounded;
    }
  }
}

class AlertModel {
  final String id;
  final AlertLevel level;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isAcknowledged;
  final String relatedSubsystem;

  const AlertModel({
    required this.id,
    required this.level,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isAcknowledged = false,
    this.relatedSubsystem = 'General',
  });

  AlertModel copyWith({
    String? id,
    AlertLevel? level,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isAcknowledged,
    String? relatedSubsystem,
  }) {
    return AlertModel(
      id: id ?? this.id,
      level: level ?? this.level,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isAcknowledged: isAcknowledged ?? this.isAcknowledged,
      relatedSubsystem: relatedSubsystem ?? this.relatedSubsystem,
    );
  }
}
