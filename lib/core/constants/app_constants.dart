import 'package:flutter/material.dart';

/// Application-wide constants, colors, and thresholds for SmartMedWaste
class AppConstants {
  // Application Info
  static const String appName = 'SmartMedWaste';
  static const String appTagline = 'Autonomous Biomedical Waste Segregation';
  static const String appVersion = 'v1.4.2-SIH26115';

  // Clean Medical Light Mode Palette
  static const Color canvasBg = Color(0xFFF8FAFC); // Slate 50 pure soft canvas
  static const Color cardBg = Color(0xFFFFFFFF); // Clean white card surface
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle 1px clinical border
  static const Color surfaceInteractive = Color(0xFFF1F5F9); // Slate 100 elevated/interactive
  static const Color clinicalNavy = Color(0xFF0F2942); // Primary Clinical Navy
  static const Color medicalTeal = Color(0xFF0D9488); // Functional Medical Teal
  static const Color textPrimary = Color(0xFF1E293B); // Slate 800 body text
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 subtitles/labels
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400 muted text

  // Dark/Legacy Support Aliases
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color surfaceSlate = Color(0xFF1E293B);
  static const Color borderSlate = Color(0xFF334155);
  static const Color tealPrimary = Color(0xFF0D9488);
  static const Color tealAccent = Color(0xFF0D9488); // High contrast clinical teal
  static const Color amberWarning = Color(0xFFD97706); // Caution / fill >85%
  static const Color crimsonDanger = Color(0xFFDC2626); // Biohazard / E-Stop
  static const Color neutralGrey = Color(0xFF64748B);
  static const Color lightSlate = Color(0xFF94A3B8);

  // Standardized 5-Compartment Color System
  // 1. Sharps (Needles, scalpels, glass ampoules)
  static const Color sharpsLightBg = Color(0xFFF8FAFC);
  static const Color sharpsBadge = Color(0xFF475569);
  static const Color sharpsColor = Color(0xFF475569);
  static const Color sharpsAccent = Color(0xFF475569);

  // 2. Infectious (Pathological, soiled dressings, anatomical)
  static const Color infectiousLightBg = Color(0xFFFEF3C7);
  static const Color infectiousBadge = Color(0xFFD97706);
  static const Color infectiousColor = Color(0xFFD97706);
  static const Color infectiousBg = Color(0xFFFEF3C7);

  // 3. Plastic / Recyclable (Tubing, catheters, IV bottles, syringes without needle)
  static const Color plasticLightBg = Color(0xFFFEE2E2);
  static const Color plasticBadge = Color(0xFFDC2626);
  static const Color plasticColor = Color(0xFFDC2626);
  static const Color plasticBg = Color(0xFFFEE2E2);

  // 4. Glassware / Cytotoxic (Medicine vials, ampoules, heavy metals)
  static const Color glasswareLightBg = Color(0xFFDBEAFE);
  static const Color glasswareBadge = Color(0xFF2563EB);
  static const Color glasswareColor = Color(0xFF2563EB);
  static const Color glasswareBg = Color(0xFFDBEAFE);
  static const Color otherColor = Color(0xFF2563EB); // compatibility alias

  // 5. Unknown / Others (Unclassified, general hospital waste, fallback)
  static const Color unknownLightBg = Color(0xFFF3E8FF);
  static const Color unknownBadge = Color(0xFF7E22CE);
  static const Color unknownColor = Color(0xFF7E22CE);
  static const Color unknownBg = Color(0xFFF3E8FF);

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
