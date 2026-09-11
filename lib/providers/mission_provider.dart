import 'dart:async';
import 'package:flutter/material.dart';
import '../models/mission_model.dart';
import '../models/robot_model.dart';
import '../services/mock_data_service.dart';
import '../services/websocket_service.dart';
import 'robot_provider.dart';

class MissionProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService.instance;
  final WebSocketService _wsService = WebSocketService();

  MissionModel? _activeMission;
  final List<MissionModel> _missionHistory = [];
  Timer? _lifecycleTicker;

  MissionProvider() {
    _activeMission = _dataService.getInitialMission();
    _missionHistory.add(_activeMission!);
  }

  MissionModel? get activeMission => _activeMission;
  List<MissionModel> get missionHistory => List.unmodifiable(_missionHistory);

  bool get hasActiveMission =>
      _activeMission != null &&
      _activeMission!.status != MissionLifecycleStatus.completed &&
      _activeMission!.status != MissionLifecycleStatus.cancelled;

  /// Requests a collection mission and initiates 11-step lifecycle
  Future<bool> requestPickup({
    required String department,
    required String stationId,
    required MissionPriority priority,
    required String notes,
    required RobotProvider robotProvider,
    String assignedRobotId = 'R01',
  }) async {
    final missionId = 'MSN-${DateTime.now().year}-${(100 + _missionHistory.length)}';
    final mission = MissionModel(
      missionId: missionId,
      department: department,
      stationId: stationId,
      assignedRobotId: assignedRobotId,
      priority: priority,
      status: MissionLifecycleStatus.pending,
      requestedBy: 'Clinical Ward Officer',
      requestedAt: DateTime.now(),
      notes: notes,
      routeWaypoints: [
        'Docking Bay',
        'Corridor West',
        'Bio-Airlock 2',
        stationId,
        'Basement Elevator',
        'Central Disposal Bay',
      ],
      estimatedArrivalMins: priority == MissionPriority.emergencyBiologicalSpill ? 1.0 : 3.0,
    );

    _activeMission = mission;
    _missionHistory.insert(0, mission);
    notifyListeners();

    // Start 11-Step Lifecycle progression
    _runFullLifecycle(robotProvider, assignedRobotId, stationId);
    return true;
  }

  void _runFullLifecycle(RobotProvider robotProvider, String robotId, String destination) {
    _lifecycleTicker?.cancel();

    // 11 stages sequence:
    // PENDING (0s) -> ASSIGNED (1.5s) -> DISPATCHED (3s) -> EN_ROUTE (5s) ->
    // ARRIVED (8s) -> COLLECTING (11s) -> ANALYZING (14s) -> SEGREGATING (17s) ->
    // RETURNING (20s) -> DISPOSAL (23s) -> COMPLETED (26s)

    final stages = [
      (MissionLifecycleStatus.assigned, 1500, 'Assigned to Rover $robotId'),
      (MissionLifecycleStatus.dispatched, 1500, 'Dispatched from docking bay'),
      (MissionLifecycleStatus.enRoute, 2000, 'En route to $destination'),
      (MissionLifecycleStatus.arrived, 3000, 'Arrived at $destination'),
      (MissionLifecycleStatus.collecting, 3000, 'Collecting biomedical bags'),
      (MissionLifecycleStatus.analyzing, 3000, 'Analyzing with YOLO AI Vision'),
      (MissionLifecycleStatus.segregating, 3000, 'Segregating into internal vaults'),
      (MissionLifecycleStatus.returning, 3000, 'Returning to Central Bay'),
      (MissionLifecycleStatus.disposal, 3000, 'Discharging at Disposal Bay'),
      (MissionLifecycleStatus.completed, 3000, 'Mission successfully completed'),
    ];

    void advanceStage(int index) {
      if (index >= stages.length) return;
      if (_activeMission == null || _activeMission!.status == MissionLifecycleStatus.cancelled) return;

      final stage = stages[index];
      _lifecycleTicker = Timer(Duration(milliseconds: stage.$2), () {
        if (_activeMission == null || _activeMission!.status == MissionLifecycleStatus.cancelled) return;

        final newStatus = stage.$1;
        _activeMission = _activeMission!.copyWith(
          status: newStatus,
          completedAt: newStatus == MissionLifecycleStatus.completed ? DateTime.now() : null,
        );

        // Update robot status
        if (newStatus == MissionLifecycleStatus.enRoute) {
          robotProvider.updateStatus(RobotStatus.enRoute, wardName: destination);
        } else if (newStatus == MissionLifecycleStatus.collecting ||
            newStatus == MissionLifecycleStatus.analyzing ||
            newStatus == MissionLifecycleStatus.segregating) {
          robotProvider.updateStatus(RobotStatus.collecting, wardName: destination);
        } else if (newStatus == MissionLifecycleStatus.returning) {
          robotProvider.updateStatus(RobotStatus.discharging, wardName: 'Central Bay');
        } else if (newStatus == MissionLifecycleStatus.completed) {
          robotProvider.updateStatus(RobotStatus.idle, wardName: 'Docking Bay');
        }

        _wsService.broadcastMissionUpdate(_activeMission!);
        notifyListeners();

        advanceStage(index + 1);
      });
    }

    advanceStage(0);
  }

  void cancelActiveMission(RobotProvider robotProvider) {
    _lifecycleTicker?.cancel();
    if (_activeMission != null) {
      _activeMission = _activeMission!.copyWith(status: MissionLifecycleStatus.cancelled);
      robotProvider.updateStatus(RobotStatus.idle);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _lifecycleTicker?.cancel();
    super.dispose();
  }
}
