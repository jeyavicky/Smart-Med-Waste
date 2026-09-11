import 'package:flutter/material.dart';
import '../models/manifest_model.dart';
import '../services/api_service.dart';
import '../services/pdf_export_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final PdfExportService _pdfService = PdfExportService();

  List<ManifestModel> _manifests = [];
  bool _isLoading = false;
  String _selectedTimeframe = 'Weekly';

  List<ManifestModel> get manifests => List.unmodifiable(_manifests);
  bool get isLoading => _isLoading;
  String get selectedTimeframe => _selectedTimeframe;

  // Key KPI Metrics
  double get totalMonthlyBiomedicalKg => 482.6;
  double get cpcbComplianceRate => 99.2; // 99.2% compliance
  double get aiSegregationAccuracy => 97.8; // 97.8%
  double get totalBagsProcessed => 214;

  // 5-Compartment Weight Distribution (kg)
  Map<String, double> get compartmentWeightsKg => {
        'Sharps': 86.4,
        'Infectious': 194.2,
        'Plastic': 118.5,
        'Glassware': 58.0,
        'Unknown/Others': 25.5,
      };

  // Daily Trend (Mon - Sun)
  List<double> get dailyKgTrend => [62.4, 71.0, 58.5, 79.0, 68.2, 84.1, 59.4];

  AnalyticsProvider() {
    _loadInitialManifests();
  }

  Future<void> _loadInitialManifests() async {
    _isLoading = true;
    notifyListeners();
    try {
      _manifests = await _apiService.getManifests();
    } catch (_) {
      _manifests = [ManifestModel.mockDefault()];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    notifyListeners();
  }

  /// Triggers PDF export of the latest or selected manifest
  Future<void> exportManifestPdf([ManifestModel? manifest]) async {
    final target = manifest ?? (_manifests.isNotEmpty ? _manifests.first : ManifestModel.mockDefault());
    await _pdfService.previewOrPrintManifest(target);
  }
}
