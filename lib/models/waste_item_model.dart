import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum WasteCategory {
  sharps,
  infectious,
  plastic,
  glassware,
  unknownOthers;

  // Backward-compatibility aliases
  static const WasteCategory sharpsWhite = WasteCategory.sharps;
  static const WasteCategory infectiousYellow = WasteCategory.infectious;
  static const WasteCategory plasticRed = WasteCategory.plastic;
  static const WasteCategory otherBlue = WasteCategory.glassware;
}

extension WasteCategoryExtension on WasteCategory {
  String get displayName {
    switch (this) {
      case WasteCategory.sharps:
        return 'SHARPS / NEEDLES';
      case WasteCategory.infectious:
        return 'INFECTIOUS BIO-WASTE';
      case WasteCategory.plastic:
        return 'NON-CHLORINATED PLASTIC';
      case WasteCategory.glassware:
        return 'GLASSWARE / VIALS';
      case WasteCategory.unknownOthers:
        return 'UNKNOWN / GENERAL RESIDUE';
    }
  }

  String get shortName {
    switch (this) {
      case WasteCategory.sharps:
        return 'Sharps';
      case WasteCategory.infectious:
        return 'Infectious';
      case WasteCategory.plastic:
        return 'Plastic';
      case WasteCategory.glassware:
        return 'Glassware';
      case WasteCategory.unknownOthers:
        return 'Unknown';
    }
  }

  String get compartmentGateId {
    switch (this) {
      case WasteCategory.sharps:
        return 'Gate #1 (Sharps Vault)';
      case WasteCategory.infectious:
        return 'Gate #2 (Infectious Bio-Lock)';
      case WasteCategory.plastic:
        return 'Gate #3 (Plastic Diverter)';
      case WasteCategory.glassware:
        return 'Gate #4 (Glassware Chute)';
      case WasteCategory.unknownOthers:
        return 'Gate #5 (Fallback Vault)';
    }
  }

  Color get color {
    switch (this) {
      case WasteCategory.sharps:
        return AppTheme.sharpsColor;
      case WasteCategory.infectious:
        return AppTheme.infectiousColor;
      case WasteCategory.plastic:
        return AppTheme.plasticColor;
      case WasteCategory.glassware:
        return AppTheme.glasswareColor;
      case WasteCategory.unknownOthers:
        return AppTheme.unknownColor;
    }
  }

  Color get lightBgColor {
    switch (this) {
      case WasteCategory.sharps:
        return AppTheme.sharpsBg;
      case WasteCategory.infectious:
        return AppTheme.infectiousBg;
      case WasteCategory.plastic:
        return AppTheme.plasticBg;
      case WasteCategory.glassware:
        return AppTheme.glasswareBg;
      case WasteCategory.unknownOthers:
        return AppTheme.unknownBg;
    }
  }

  Color get badgeColor => color;
  Color get accentColor => color;

  IconData get icon {
    switch (this) {
      case WasteCategory.sharps:
        return Icons.content_cut_rounded;
      case WasteCategory.infectious:
        return Icons.biotech_rounded;
      case WasteCategory.plastic:
        return Icons.local_hospital_rounded;
      case WasteCategory.glassware:
        return Icons.medication_rounded;
      case WasteCategory.unknownOthers:
        return Icons.help_outline_rounded;
    }
  }
}

class NormalizedRect {
  final double left;
  final double top;
  final double width;
  final double height;

  const NormalizedRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class WasteItemModel {
  final String id;
  final String detectedObject;
  final WasteCategory category;
  final double confidence;
  final double weightKg;
  final DateTime timestamp;
  final String internalActionDetails;
  final NormalizedRect boundingBox;
  final String wardId;
  final String? verificationHash;
  final String operatorId;
  final bool isManualOverride;
  final double riskScore; // 0.0 to 1.0
  final bool isDiverterLocked;

  const WasteItemModel({
    required this.id,
    required this.detectedObject,
    required this.category,
    required this.confidence,
    required this.weightKg,
    required this.timestamp,
    required this.internalActionDetails,
    this.boundingBox = const NormalizedRect(left: 0.22, top: 0.28, width: 0.56, height: 0.44),
    this.wardId = 'ICU-01',
    this.verificationHash,
    this.operatorId = 'OP-042',
    this.isManualOverride = false,
    this.riskScore = 0.85,
    this.isDiverterLocked = true,
  });

  bool get isHighConfidence => confidence >= 0.80;

  WasteItemModel copyWith({
    String? id,
    String? detectedObject,
    WasteCategory? category,
    double? confidence,
    double? weightKg,
    DateTime? timestamp,
    String? internalActionDetails,
    NormalizedRect? boundingBox,
    String? wardId,
    String? verificationHash,
    String? operatorId,
    bool? isManualOverride,
    double? riskScore,
    bool? isDiverterLocked,
  }) {
    return WasteItemModel(
      id: id ?? this.id,
      detectedObject: detectedObject ?? this.detectedObject,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      weightKg: weightKg ?? this.weightKg,
      timestamp: timestamp ?? this.timestamp,
      internalActionDetails: internalActionDetails ?? this.internalActionDetails,
      boundingBox: boundingBox ?? this.boundingBox,
      wardId: wardId ?? this.wardId,
      verificationHash: verificationHash ?? this.verificationHash,
      operatorId: operatorId ?? this.operatorId,
      isManualOverride: isManualOverride ?? this.isManualOverride,
      riskScore: riskScore ?? this.riskScore,
      isDiverterLocked: isDiverterLocked ?? this.isDiverterLocked,
    );
  }
}
