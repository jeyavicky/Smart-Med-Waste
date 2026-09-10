import 'package:flutter/material.dart';

/// Clinical Logistics and Infection Control Mobile Portal Constants
/// Compliant with Material 3 and WCAG 2.1 AA accessibility standards.
class AppConstants {
  // Application Info
  static const String appName = 'SmartMedWaste';
  static const String appTagline = 'Autonomous Biomedical Waste Segregation';
  static const String appVersion = 'v1.4.2-SIH26115';

  // 1. Color Architecture (High-Contrast, Light Clinical Surface)
  static const Color canvasBg = Color(0xFFF8FAFC); // Clean Medical Neutral (Slate 50)
  static const Color cardBg = Color(0xFFFFFFFF); // Pure Crisp White surface
  static const Color cardBorder = Color(0xFFE2E8F0); // Subtle 1px clinical surface border
  static const Color surfaceInteractive = Color(0xFFF1F5F9); // Slate 100 elevated/interactive
  static const Color clinicalNavy = Color(0xFF0F2942); // Primary / Authority Brand
  static const Color medicalTeal = Color(0xFF0D9488); // Secondary Clinical Teal
  static const Color coolSlate = Color(0xFF64748B); // Secondary Cool Slate
  static const Color dividerSubtle = Color(0xFFCBD5E1); // Subtle / Dividers

  // Text Contrast
  static const Color textPrimary = Color(0xFF0F172A); // Deep Charcoal (critical data & headers)
  static const Color textSecondary = Color(0xFF475569); // Neutral Muted (metadata, subtitles, labels)
  static const Color textBody = Color(0xFF1E293B); // Slate 800 Card Titles & Metric Labels
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400 helper text

  // Verification & Status Accents
  static const Color statusNominal = Color(0xFF059669); // Green verification ticks / healthy
  static const Color amberWarning = Color(0xFFD97706); // Caution / fill >80%
  static const Color crimsonDanger = Color(0xFFDC2626); // Biohazard / E-Stop
  static const Color crimsonDangerLight = Color(0xFFFEF2F2); // Subtle red background

  // Compatibility / Support Aliases
  static const Color darkSlate = Color(0xFF0F172A);
  static const Color surfaceSlate = Color(0xFFFFFFFF); // Redirect to crisp white
  static const Color borderSlate = Color(0xFFE2E8F0); // Redirect to crisp border
  static const Color tealPrimary = Color(0xFF0F2942); // Primary authority navy
  static const Color tealAccent = Color(0xFF0D9488); // Clinical teal
  static const Color neutralGrey = Color(0xFF64748B);
  static const Color lightSlate = Color(0xFF475569);

  // 2. Standardized 5-Stream Biomedical Waste Palette (CPCB Standard)
  // 1. Sharps / Blades (Translucent/White stream)
  static const Color sharpsLightBg = Color(0xFFF1F5F9);
  static const Color sharpsBadge = Color(0xFF475569);
  static const Color sharpsColor = Color(0xFF475569);
  static const Color sharpsAccent = Color(0xFF475569);
  static const String sharpsLabel = 'SHARPS / BLADES';

  // 2. Infectious / Pathological (Yellow stream)
  static const Color infectiousLightBg = Color(0xFFFEF3C7);
  static const Color infectiousBadge = Color(0xFFD97706);
  static const Color infectiousColor = Color(0xFFD97706);
  static const Color infectiousBg = Color(0xFFFEF3C7);
  static const String infectiousLabel = 'INFECTIOUS / PATHOLOGICAL';

  // 3. Contaminated Plastics / Recyclables (Red stream)
  static const Color plasticLightBg = Color(0xFFFEE2E2);
  static const Color plasticBadge = Color(0xFFDC2626);
  static const Color plasticColor = Color(0xFFDC2626);
  static const Color plasticBg = Color(0xFFFEE2E2);
  static const String plasticLabel = 'CONTAMINATED PLASTICS';

  // 4. Glassware & Vials / Cytotoxic (Blue stream)
  static const Color glasswareLightBg = Color(0xFFDBEAFE);
  static const Color glasswareBadge = Color(0xFF2563EB);
  static const Color glasswareColor = Color(0xFF2563EB);
  static const Color glasswareBg = Color(0xFFDBEAFE);
  static const Color otherColor = Color(0xFF2563EB);
  static const String glasswareLabel = 'GLASSWARE & VIALS';

  // 5. General / Unclassified (Unknown / Others stream)
  static const Color unknownLightBg = Color(0xFFF3E8FF);
  static const Color unknownBadge = Color(0xFF7E22CE);
  static const Color unknownColor = Color(0xFF7E22CE);
  static const Color unknownBg = Color(0xFFF3E8FF);
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
