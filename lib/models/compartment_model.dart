import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'waste_item_model.dart';

enum GateStatus {
  locked,
  actuating,
  open,
}

class CompartmentModel {
  final WasteCategory category;
  final String title;
  final String codeName;
  final double currentKg;
  final double maxKg;
  final int itemCount;
  final GateStatus gateStatus;
  final bool sealIntegrityOk;
  final double temperatureCelsius;

  const CompartmentModel({
    required this.category,
    required this.title,
    required this.codeName,
    required this.currentKg,
    required this.maxKg,
    this.itemCount = 0,
    this.gateStatus = GateStatus.locked,
    this.sealIntegrityOk = true,
    this.temperatureCelsius = 22.4,
  });

  double get fillPercentage => (currentKg / maxKg).clamp(0.0, 1.0);

  bool get isFull => currentKg >= maxKg;

  bool get isWarning => fillPercentage >= AppConstants.compartmentWarningThreshold;

  Color get color => category.color;
  Color get accentColor => category.accentColor;

  CompartmentModel copyWith({
    WasteCategory? category,
    String? title,
    String? codeName,
    double? currentKg,
    double? maxKg,
    int? itemCount,
    GateStatus? gateStatus,
    bool? sealIntegrityOk,
    double? temperatureCelsius,
  }) {
    return CompartmentModel(
      category: category ?? this.category,
      title: title ?? this.title,
      codeName: codeName ?? this.codeName,
      currentKg: currentKg ?? this.currentKg,
      maxKg: maxKg ?? this.maxKg,
      itemCount: itemCount ?? this.itemCount,
      gateStatus: gateStatus ?? this.gateStatus,
      sealIntegrityOk: sealIntegrityOk ?? this.sealIntegrityOk,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    );
  }
}
