import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

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
        return 'SHARPS (NEEDLES & BLADES)';
      case WasteCategory.infectious:
        return 'INFECTIOUS BIOHAZARD';
      case WasteCategory.plastic:
        return 'PLASTIC / RECYCLABLE';
      case WasteCategory.glassware:
        return 'GLASSWARE / CYTOTOXIC';
      case WasteCategory.unknownOthers:
        return 'UNKNOWN / OTHERS (FALLBACK)';
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
        return 'Unknown/Other';
    }
  }

  String get compartmentGateId {
    switch (this) {
      case WasteCategory.sharps:
        return 'Gate #1 (Sharps Vault)';
      case WasteCategory.infectious:
        return 'Gate #2 (Biohazard Bio-Lock)';
      case WasteCategory.plastic:
        return 'Gate #3 (Plastic Diverter)';
      case WasteCategory.glassware:
        return 'Gate #4 (Glassware Chute)';
      case WasteCategory.unknownOthers:
        return 'Gate #5 (Fallback Containment)';
    }
  }

  Color get color {
    switch (this) {
      case WasteCategory.sharps:
        return AppConstants.sharpsBadge;
      case WasteCategory.infectious:
        return AppConstants.infectiousBadge;
      case WasteCategory.plastic:
        return AppConstants.plasticBadge;
      case WasteCategory.glassware:
        return AppConstants.glasswareBadge;
      case WasteCategory.unknownOthers:
        return AppConstants.unknownBadge;
    }
  }

  Color get lightBgColor {
    switch (this) {
      case WasteCategory.sharps:
        return AppConstants.sharpsLightBg;
      case WasteCategory.infectious:
        return AppConstants.infectiousLightBg;
      case WasteCategory.plastic:
        return AppConstants.plasticLightBg;
      case WasteCategory.glassware:
        return AppConstants.glasswareLightBg;
      case WasteCategory.unknownOthers:
        return AppConstants.unknownLightBg;
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
  });

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
    );
  }
}
