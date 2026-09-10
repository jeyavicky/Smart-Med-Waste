import 'package:flutter/material.dart';

/// Clinical Logistics and Infection Control Mobile Portal Constants
/// Compliant with Material 3 and WCAG 2.1 AA accessibility standards.
class AppConstants {
  // Application Info
  static const String appName = 'SmartMedWaste';
  static const String appTagline = 'Autonomous Biomedical Waste Segregation';
  static const String appVersion = 'v1.4.2-SIH26115';

  // 1. Modern Nordic Health-Tech Palette (Sage, Muted Slate & Soft Frost)
  static const Color canvasBg = Color(0xFFF0F4F8); // Soft Ice Grey / Frost Canvas
  static const Color cardBg = Color(0xFFE6ECEF); // Soft Mint Surface Tint
  static const Color surfacePorcelain = Color(0xFFEBF1F5); // Muted Porcelain
  static const Color elevatedContainer = Color(0xFFF7FAFC); // Clean Pearl White
  static const Color cardBorder = Color(0xFFD2DCE5); // Subtle Deep Slate Accent (1.2px)
  static const Color surfaceInteractive = Color(0xFFEBF1F5); // Interactive porcelain surface
  static const Color primaryBrand = Color(0xFF0A4D52); // Deep Forest Teal
  static const Color secondaryInteractive = Color(0xFF1B7A82); // Nordic Cyan
  static const Color accentAction = Color(0xFF2E856E); // Soft Emerald / Sage
  static const Color clinicalNavy = Color(0xFF0A4D52); // Primary Brand Alias
  static const Color medicalTeal = Color(0xFF1B7A82); // Secondary Nordic Cyan Alias
  static const Color coolSlate = Color(0xFF4F6470); // Deep Steel Grey
  static const Color dividerSubtle = Color(0xFFD2DCE5); // Subtle Borders & Dividers

  // Text Contrast (Graphite Dark Slate & Deep Steel Grey)
  static const Color textPrimary = Color(0xFF16252D); // Graphite Dark Slate (headers & primary data)
  static const Color textSecondary = Color(0xFF4F6470); // Deep Steel Grey (subtitles, metadata, labels)
  static const Color textBody = Color(0xFF16252D); // Dark Slate Body
  static const Color textMuted = Color(0xFF4F6470); // Deep Steel Grey Muted

  // Verification & Status Accents
  static const Color statusNominal = Color(0xFF2E856E); // Soft Emerald / Sage verification ticks
  static const Color amberWarning = Color(0xFFB7791F); // Caution / fill >80%
  static const Color crimsonDanger = Color(0xFFC53030); // Biohazard / E-Stop
  static const Color crimsonDangerLight = Color(0xFFFFE8E6); // Soft red background

  // Compatibility / Support Aliases
  static const Color darkSlate = Color(0xFF16252D);
  static const Color surfaceSlate = Color(0xFFE6ECEF);
  static const Color borderSlate = Color(0xFFD2DCE5);
  static const Color tealPrimary = Color(0xFF0A4D52);
  static const Color tealAccent = Color(0xFF1B7A82);
  static const Color neutralGrey = Color(0xFF4F6470);
  static const Color lightSlate = Color(0xFF4F6470);

  // 2. Standard 5-Bin Compartment Harmony (Softened Clinical Contrast)
  // 1. Sharps / Blades: Card #E8EDF2 | Accent/Badge #37474F
  static const Color sharpsLightBg = Color(0xFFE8EDF2);
  static const Color sharpsBadge = Color(0xFF37474F);
  static const Color sharpsColor = Color(0xFF37474F);
  static const Color sharpsAccent = Color(0xFF37474F);
  static const String sharpsLabel = 'SHARPS / BLADES';

  // 2. Infectious / Pathological: Card #FFF3CD | Accent/Badge #B7791F
  static const Color infectiousLightBg = Color(0xFFFFF3CD);
  static const Color infectiousBadge = Color(0xFFB7791F);
  static const Color infectiousColor = Color(0xFFB7791F);
  static const Color infectiousBg = Color(0xFFFFF3CD);
  static const String infectiousLabel = 'INFECTIOUS / PATHOLOGICAL';

  // 3. Contaminated Plastics / Recyclables: Card #FFE8E6 | Accent/Badge #C53030
  static const Color plasticLightBg = Color(0xFFFFE8E6);
  static const Color plasticBadge = Color(0xFFC53030);
  static const Color plasticColor = Color(0xFFC53030);
  static const Color plasticBg = Color(0xFFFFE8E6);
  static const String plasticLabel = 'CONTAMINATED PLASTICS';

  // 4. Glassware & Vials: Card #E1EEFF | Accent/Badge #2B6CB0
  static const Color glasswareLightBg = Color(0xFFE1EEFF);
  static const Color glasswareBadge = Color(0xFF2B6CB0);
  static const Color glasswareColor = Color(0xFF2B6CB0);
  static const Color glasswareBg = Color(0xFFE1EEFF);
  static const Color otherColor = Color(0xFF2B6CB0);
  static const String glasswareLabel = 'GLASSWARE & VIALS';

  // 5. Unknown / Others: Card #EFE7FA | Accent/Badge #6B46C1
  static const Color unknownLightBg = Color(0xFFEFE7FA);
  static const Color unknownBadge = Color(0xFF6B46C1);
  static const Color unknownColor = Color(0xFF6B46C1);
  static const Color unknownBg = Color(0xFFEFE7FA);
  static const String unknownLabel = 'GENERAL / UNCLASSIFIED';

  // Thresholds
  static const double compartmentWarningThreshold = 0.80; // 80% full warning threshold
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
