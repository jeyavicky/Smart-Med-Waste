import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../models/robot_model.dart';
import '../services/mock_data_service.dart';
import '../services/mqtt_service.dart';
import '../core/constants/api_constants.dart';
import 'robot_provider.dart';

class MissionProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService.instance;
  final MqttService _mqttService = SimulatedMqttService.instance;

  MissionModel? _activeMission;
  final List<MissionModel> _missionHistory = [];
  Timer? _missionLifecycleTimer;

  MissionProvider() {
    _activeMission = _dataService.getInitialMission();
    _missionHistory.add(_activeMission!);
  }

  MissionModel? get activeMission => _activeMission;
  List<MissionModel> get missionHistory => List.unmodifiable(_missionHistory);

  bool get hasActiveMission =>
      _activeMission != null &&
      _activeMission!.status != MissionStatus.completed &&
      _activeMission!.status != MissionStatus.cancelled;

  /// Initiates a new pickup request from clinical staff
  Future<bool> requestPickup({
    required String department,
    required String stationId,
    required MissionPriority priority,
    required String notes,
    required RobotProvider robotProvider,
  }) async {
    final missionId = 'MIS-2026-${(100 + _missionHistory.length)}';
    final newMission = MissionModel(
      missionId: missionId,
      department: department,
      stationId: stationId,
      priority: priority,
      status: MissionStatus.dispatched,
      requestedBy: 'Nurse Station Incharge (Staff ID #204)',
      requestedAt: DateTime.now(),
      notes: notes,
      routeWaypoints: [
        'Dock Bay Alpha',
        'Corridor B East',
        'Ward Airlock',
        stationId,
      ],
      estimatedArrivalMins: priority == MissionPriority.emergencyBiologicalSpill ? 1.2 : 3.0,
    );

    _activeMission = newMission;
    _missionHistory.insert(0, newMission);

    // Publish MQTT dispatch handshake
    await _mqttService.publish(ApiConstants.topicMissionCreate, {
      'missionId': missionId,
      'department': department,
      'stationId': stationId,
      'priority': priority.name,
      'notes': notes,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Update robot status
    robotProvider.updateStatus(RobotStatus.navigatingToWard, wardName: stationId);
    notifyListeners();

    // Start simulated progression cycle
    _startSimulatedProgression(robotProvider);

    return true;
  }

  /// Automatically progresses the mission through realistic hospital transit states
  void _startSimulatedProgression(RobotProvider robotProvider) {
    _missionLifecycleTimer?.cancel();

    // Stage 1: Arrived at ward, segregating (after 4s)
    _missionLifecycleTimer = Timer(const Duration(seconds: 4), () {
      if (_activeMission == null || _activeMission!.status == MissionStatus.cancelled) return;

      _activeMission = _activeMission!.copyWith(status: MissionStatus.collecting);
      robotProvider.updateStatus(RobotStatus.segregatingWaste);
      notifyListeners();

      // Stage 2: Waste segregated, returning to central disposal (after 5s)
      _missionLifecycleTimer = Timer(const Duration(seconds: 5), () {
        if (_activeMission == null || _activeMission!.status == MissionStatus.cancelled) return;

        _activeMission = _activeMission!.copyWith(status: MissionStatus.returning);
        robotProvider.updateStatus(
          RobotStatus.returningToDisposal,
          wardName: 'Basement Central Facility',
        );
        notifyListeners();

        // Stage 3: Completed deposit at central autoclave/incinerator (after 5s)
        _missionLifecycleTimer = Timer(const Duration(seconds: 5), () {
          if (_activeMission == null || _activeMission!.status == MissionStatus.cancelled) return;

          _activeMission = _activeMission!.copyWith(
            status: MissionStatus.completed,
            completedAt: DateTime.now(),
          );
          robotProvider.updateStatus(
            RobotStatus.idle,
            wardName: 'Dock Bay Alpha (Floor 2)',
          );
          notifyListeners();
        });
      });
    });
  }

  /// Cancels the current active mission
  void cancelActiveMission(RobotProvider robotProvider) {
    _missionLifecycleTimer?.cancel();
    if (_activeMission != null) {
      _activeMission = _activeMission!.copyWith(status: MissionStatus.cancelled);
      robotProvider.updateStatus(RobotStatus.idle);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _missionLifecycleTimer?.cancel();
    super.dispose();
  }
}
