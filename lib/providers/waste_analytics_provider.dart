import 'dart:async';
import 'package:flutter/material.dart';
import '../models/compartment_model.dart';
import '../models/waste_item_model.dart';
import '../models/alert_model.dart';
import '../services/mock_data_service.dart';
import '../services/notification_service.dart';

class WasteAnalyticsProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService.instance;

  late List<CompartmentModel> _compartments;
  late List<WasteItemModel> _detectedItems;
  late WasteItemModel _currentItem;
  late List<Map<String, dynamic>> _historicalLedger;
  late List<AlertModel> _alerts;

  int _simulatedItemIndex = 0;
  String _searchFilterQuery = '';
  String _selectedWardFilter = 'All Wards';

  WasteAnalyticsProvider() {
    _compartments = _dataService.getInitialCompartments();
    _detectedItems = List.from(_dataService.mockAiItems);
    _currentItem = _detectedItems.first;
    _historicalLedger = _dataService.getInitialHistoricalLedger();
    _alerts = _dataService.getInitialAlerts();
  }

  List<CompartmentModel> get compartments => _compartments;
  WasteItemModel get currentItem => _currentItem;
  List<WasteItemModel> get detectedItems => List.unmodifiable(_detectedItems);
  List<AlertModel> get alerts => List.unmodifiable(_alerts);
  String get searchFilterQuery => _searchFilterQuery;
  String get selectedWardFilter => _selectedWardFilter;

  int get unreadAlertCount => _alerts.where((a) => !a.isAcknowledged).length;

  /// Total waste currently inside robot compartments
  double get totalCurrentKg =>
      _compartments.fold(0.0, (sum, comp) => sum + comp.currentKg);

  /// Total waste processed today across all collections
  double get todayTotalWeightKg => 16.75; // kg
  double get todayWeightDeltaPercent => 8.4; // +8.4% vs yesterday
  double get cpcbComplianceScore => 98.4; // 98.4%
  double get segregationAccuracy => 96.7; // 96.7%

  /// Filtered historical ledger records
  List<Map<String, dynamic>> get filteredLedger {
    return _historicalLedger.where((entry) {
      final matchesSearch = _searchFilterQuery.isEmpty ||
          (entry['id'] as String).toLowerCase().contains(_searchFilterQuery.toLowerCase()) ||
          (entry['ward'] as String).toLowerCase().contains(_searchFilterQuery.toLowerCase()) ||
          (entry['facility'] as String).toLowerCase().contains(_searchFilterQuery.toLowerCase());

      final matchesWard = _selectedWardFilter == 'All Wards' ||
          (entry['ward'] as String).contains(_selectedWardFilter.split(' ').first);

      return matchesSearch && matchesWard;
    }).toList();
  }

  void setSearchFilter(String query) {
    _searchFilterQuery = query;
    notifyListeners();
  }

  void setSelectedWardFilter(String ward) {
    _selectedWardFilter = ward;
    notifyListeners();
  }

  /// Cycles next AI item detection in the HUD overlay to showcase live judging
  void simulateNextItem() {
    _simulatedItemIndex = (_simulatedItemIndex + 1) % _dataService.mockAiItems.length;
    final nextTemplate = _dataService.mockAiItems[_simulatedItemIndex];

    // Create unique timestamped item instance
    final newItem = nextTemplate.copyWith(
      id: 'ITEM-${8820 + _detectedItems.length}',
      timestamp: DateTime.now(),
      verificationHash: '0x${(DateTime.now().millisecondsSinceEpoch * 7).toRadixString(16).padLeft(16, '0')}',
    );

    _currentItem = newItem;
    _detectedItems.insert(0, newItem);

    // Update the corresponding compartment
    final compIndex = _compartments.indexWhere((c) => c.category == newItem.category);
    if (compIndex != -1) {
      final oldComp = _compartments[compIndex];
      final updatedKg = (oldComp.currentKg + newItem.weightKg).clamp(0.0, oldComp.maxKg);
      
      // Set to actuating gate briefly
      _compartments[compIndex] = oldComp.copyWith(
        currentKg: updatedKg,
        itemCount: oldComp.itemCount + 1,
        gateStatus: GateStatus.actuating,
      );
      notifyListeners();

      // Lock gate after short delay
      Timer(const Duration(milliseconds: 900), () {
        _compartments[compIndex] = _compartments[compIndex].copyWith(
          gateStatus: GateStatus.locked,
        );

        // Check if exceeded threshold
        if (_compartments[compIndex].isWarning) {
          final alert = AlertModel(
            id: 'ALT-${DateTime.now().millisecondsSinceEpoch}',
            level: AlertLevel.warning,
            title: '${_compartments[compIndex].title} >85% Full',
            message: 'Bin level reached ${_compartments[compIndex].currentKg.toStringAsFixed(1)} kg. Evacuation recommended.',
            timestamp: DateTime.now(),
          );
          addAlert(alert);
          NotificationService.showAlertBanner(alert);
        }

        notifyListeners();
      });
    }

    notifyListeners();
  }

  /// Acknowledges an alert
  void acknowledgeAlert(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isAcknowledged: true);
      notifyListeners();
    }
  }

  /// Adds a new alert to the queue
  void addAlert(AlertModel alert) {
    _alerts.insert(0, alert);
    notifyListeners();
  }

  /// Clears all acknowledged alerts
  void clearAcknowledgedAlerts() {
    _alerts.removeWhere((a) => a.isAcknowledged);
    notifyListeners();
  }

  /// Empties compartments after dumping at central disposal facility
  void resetCompartments() {
    _compartments = _compartments.map((c) {
      return c.copyWith(
        currentKg: 0.20, // Minimal tare weight
        itemCount: 0,
        gateStatus: GateStatus.locked,
      );
    }).toList();
    NotificationService.showToast('All compartments emptied at Central Facility.');
    notifyListeners();
  }
}
