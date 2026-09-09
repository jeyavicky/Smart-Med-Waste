import 'package:intl/intl.dart';

/// Formatting utilities for clinical metrics, weights, dates, and tokens
class Formatters {
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm:ss');
  static final DateFormat _dateOnlyFormat = DateFormat('dd MMM yyyy');

  /// Formats a DateTime to "08 Sep 2026, 14:32"
  static String formatDateTime(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }

  /// Formats a DateTime to "14:32:05"
  static String formatTimeOnly(DateTime dateTime) {
    return _timeOnlyFormat.format(dateTime);
  }

  /// Formats a DateTime to "08 Sep 2026"
  static String formatDateOnly(DateTime dateTime) {
    return _dateOnlyFormat.format(dateTime);
  }

  /// Formats weight in kg (e.g., "12.4 kg" or "320 g")
  static String formatWeight(double weightKg) {
    if (weightKg < 1.0 && weightKg > 0) {
      final grams = (weightKg * 1000).round();
      return '$grams g';
    }
    return '${weightKg.toStringAsFixed(2)} kg';
  }

  /// Formats battery percentage (e.g., "86%")
  static String formatBattery(double percent) {
    return '${percent.clamp(0, 100).toStringAsFixed(0)}%';
  }

  /// Formats voltage (e.g., "11.8 V")
  static String formatVoltage(double volts) {
    return '${volts.toStringAsFixed(1)} V';
  }

  /// Formats current (e.g., "2.4 A")
  static String formatCurrent(double amps) {
    return '${amps.toStringAsFixed(1)} A';
  }

  /// Formats temperature (e.g., "31.2 °C")
  static String formatTemperature(double celsius) {
    return '${celsius.toStringAsFixed(1)} °C';
  }

  /// Formats estimated runtime based on battery percentage (e.g., "4h 15m")
  static String formatRuntimeEstimate(double batteryPercent) {
    // Assuming 100% = 6 hours (360 mins)
    final totalMinutes = ((batteryPercent / 100.0) * 360).round();
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) {
      return '$mins mins';
    }
    return '${hours}h ${mins}m';
  }

  /// Truncates verification token for display (e.g., "0x8f2d...c41a")
  static String formatToken(String token) {
    if (token.length <= 12) return token;
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }

  /// Formats relative time (e.g., "2m ago", "Just now")
  static String formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
