import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import 'waste_item_model.dart';
import 'robot_model.dart';

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

  int get fillPercentInt => (fillPercentage * 100).round();

  bool get isFull => currentKg >= maxKg;

  bool get isWarning => fillPercentage >= AppConstants.compartmentWarningThreshold;

  Color get color => category.color;
  Color get accentColor => category.accentColor;
  Color get badgeColor => category.badgeColor;
  Color get lightColor => category.lightBgColor;

  Compartment toCompartment() {
    return Compartment(
      id: codeName,
      name: title,
      badgeColor: badgeColor,
      lightColor: lightColor,
      currentWeightKg: currentKg,
      capacityKg: maxKg,
      fillPercentage: fillPercentInt,
      isFull: isFull,
    );
  }

  static CompartmentModel fromCompartment(
    Compartment c, {
    WasteCategory? category,
    GateStatus gateStatus = GateStatus.locked,
    int itemCount = 0,
    double tempC = 22.4,
  }) {
    WasteCategory cat = category ?? WasteCategory.unknownOthers;
    if (c.id.toLowerCase().contains('sharp') || c.name.toLowerCase().contains('sharp')) {
      cat = WasteCategory.sharps;
    } else if (c.id.toLowerCase().contains('infect') || c.name.toLowerCase().contains('infect')) {
      cat = WasteCategory.infectious;
    } else if (c.id.toLowerCase().contains('plas') || c.name.toLowerCase().contains('plas')) {
      cat = WasteCategory.plastic;
    } else if (c.id.toLowerCase().contains('glass') || c.name.toLowerCase().contains('glass')) {
      cat = WasteCategory.glassware;
    }

    return CompartmentModel(
      category: cat,
      title: c.name,
      codeName: c.id,
      currentKg: c.currentWeightKg,
      maxKg: c.capacityKg,
      itemCount: itemCount,
      gateStatus: gateStatus,
      temperatureCelsius: tempC,
    );
  }

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
