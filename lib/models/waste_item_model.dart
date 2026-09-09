import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

enum WasteCategory {
  sharpsWhite,
  infectiousYellow,
  plasticRed,
  otherBlue,
}

extension WasteCategoryExtension on WasteCategory {
  String get displayName {
    switch (this) {
      case WasteCategory.sharpsWhite:
        return 'SHARPS / WHITE';
      case WasteCategory.infectiousYellow:
        return 'INFECTIOUS / YELLOW';
      case WasteCategory.plasticRed:
        return 'PLASTIC / RED';
      case WasteCategory.otherBlue:
        return 'OTHER / BLUE';
    }
  }

  String get shortName {
    switch (this) {
      case WasteCategory.sharpsWhite:
        return 'Sharps';
      case WasteCategory.infectiousYellow:
        return 'Infectious';
      case WasteCategory.plasticRed:
        return 'Plastic';
      case WasteCategory.otherBlue:
        return 'Other';
    }
  }

  String get compartmentGateId {
    switch (this) {
      case WasteCategory.sharpsWhite:
        return 'Gate #1 (Sharps Sealed)';
      case WasteCategory.infectiousYellow:
        return 'Gate #2 (Biohazard Bio-Lock)';
      case WasteCategory.plasticRed:
        return 'Gate #3 (Plastic Diverter)';
      case WasteCategory.otherBlue:
        return 'Gate #4 (General Glass/Other)';
    }
  }

  Color get color {
    switch (this) {
      case WasteCategory.sharpsWhite:
        return AppConstants.sharpsColor;
      case WasteCategory.infectiousYellow:
        return AppConstants.infectiousColor;
      case WasteCategory.plasticRed:
        return AppConstants.plasticColor;
      case WasteCategory.otherBlue:
        return AppConstants.otherColor;
    }
  }

  Color get accentColor {
    switch (this) {
      case WasteCategory.sharpsWhite:
        return AppConstants.sharpsAccent;
      case WasteCategory.infectiousYellow:
        return const Color(0xFFFDE047);
      case WasteCategory.plasticRed:
        return const Color(0xFFF87171);
      case WasteCategory.otherBlue:
        return const Color(0xFF60A5FA);
    }
  }

  IconData get icon {
    switch (this) {
      case WasteCategory.sharpsWhite:
        return Icons.content_cut_rounded;
      case WasteCategory.infectiousYellow:
        return Icons.biotech_rounded;
      case WasteCategory.plasticRed:
        return Icons.local_hospital_rounded;
      case WasteCategory.otherBlue:
        return Icons.recycling_rounded;
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
