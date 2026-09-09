import 'package:flutter/material.dart';

/// Application-wide constants, colors, and thresholds for SmartMedWaste
class AppConstants {
  // Application Info
  static const String appName = 'SmartMedWaste';
  static const String appTagline = 'Autonomous Biomedical Waste Segregation';
  static const String appVersion = 'v1.4.2-SIH26115';

  // Primary Clinical Palette
  static const Color darkSlate = Color(0xFF0F172A); // Background dark
  static const Color surfaceSlate = Color(0xFF1E293B); // Elevated card
  static const Color borderSlate = Color(0xFF334155); // Borders
  static const Color tealPrimary = Color(0xFF0D9488); // Primary action / safe
  static const Color tealAccent = Color(0xFF14B8A6); // Bright teal accent
  static const Color amberWarning = Color(0xFFF59E0B); // Caution / fill >85%
  static const Color crimsonDanger = Color(0xFFEF4444); // Biohazard / E-Stop
  static const Color neutralGrey = Color(0xFF64748B); // Secondary text
  static const Color lightSlate = Color(0xFF94A3B8); // Muted text

  // 4 Standard Biomedical Waste Compartment Categories
  // 1. Sharps / White Translucent (Needles, scalpels, blades)
  static const Color sharpsColor = Color(0xFFE2E8F0);
  static const Color sharpsAccent = Color(0xFF06B6D4);

  // 2. Infectious / Yellow (Contaminated swabs, bandages, anatomical items)
  static const Color infectiousColor = Color(0xFFEAB308);
  static const Color infectiousBg = Color(0xFF854D0E);

  // 3. Plastic / Red (Catheters, tubing, IV sets, syringes without needles)
  static const Color plasticColor = Color(0xFFEF4444);
  static const Color plasticBg = Color(0xFF991B1B);

  // 4. Other / Blue/Black (Glassware, general clinical, non-infectious)
  static const Color otherColor = Color(0xFF3B82F6);
  static const Color otherBg = Color(0xFF1E3A8A);

  // Thresholds
  static const double compartmentWarningThreshold = 0.85; // 85% full warning
  static const double batteryWarningThreshold = 20.0; // 20% battery alert
  static const double batteryCriticalThreshold = 10.0; // 10% critical

  // Departments
  static const List<String> hospitalDepartments = [
    'ICU - Intensive Care',
    'OT-03 - Operation Theatre',
    'General Ward A',
    'Emergency & Trauma (ER)',
    'Pediatrics Ward 2',
    'Pathology Lab & Diagnostics',
  ];

  // Collection Stations
  static const List<String> collectionStations = [
    'ICU-01 Station',
    'ICU-02 Station',
    'OT-03 Sterile Airlock',
    'GenWard-A West Bin',
    'ER-Bay 04 Rapid Drop',
    'PathLab Sample Disposal',
  ];

  // Priorities
  static const List<String> missionPriorities = [
    'Normal Routine',
    'High Priority',
    'Emergency Biological Spill',
  ];
}
