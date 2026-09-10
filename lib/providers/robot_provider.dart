import 'dart:async';
import 'package:flutter/material.dart';
import '../models/robot_model.dart';
import '../services/mock_data_service.dart';
import '../services/mqtt_service.dart';
import '../core/constants/api_constants.dart';

class RobotProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService.instance;
  final MqttService _mqttService = SimulatedMqttService.instance;

  late List<RobotModel> _fleet;
  String _selectedRobotId = 'R01';
  Timer? _telemetryTicker;
  double _simulationSpeed = 1.0; // 1x, 2x, 5x, 0.0 (paused)
  bool _isManualDriveEnabled = false;

  // Hospital map waypoints for autonomous corridor transit
  final List<RobotCoordinates> _corridorWaypoints = const [
    RobotCoordinates(x: 75.0, y: 65.0, headingDegrees: 0.0, floor: 'Floor 2 (ICU Wing)'),
    RobotCoordinates(x: 140.0, y: 65.0, headingDegrees: 90.0, floor: 'Floor 2 (ICU Wing)'),
    RobotCoordinates(x: 140.0, y: 160.0, headingDegrees: 180.0, floor: 'Floor 2 (Corridor B)'),
    RobotCoordinates(x: 230.0, y: 160.0, headingDegrees: 90.0, floor: 'Floor 3 (OT Block)'),
    RobotCoordinates(x: 230.0, y: 260.0, headingDegrees: 180.0, floor: 'Basement Disinfection Hub'),
  ];
  int _currentWaypointIndex = 0;

  RobotProvider() {
    _fleet = _dataService.getInitialFleet();
    _startTelemetryLoop();
  }

  List<RobotModel> get fleet => List.unmodifiable(_fleet);
  String get selectedRobotId => _selectedRobotId;

  RobotModel get selectedRobot {
    return _fleet.firstWhere(
      (r) => r.id == _selectedRobotId,
      orElse: () => _fleet.first,
    );
  }

  // Backward compatibility getter
  RobotModel get robot => selectedRobot;

  double get simulationSpeed => _simulationSpeed;
  bool get isManualDriveEnabled => _isManualDriveEnabled;
  List<RobotCoordinates> get corridorWaypoints => _corridorWaypoints;
  int get currentWaypointIndex => _currentWaypointIndex;

  void selectRobot(String id) {
    if (_selectedRobotId != id && _fleet.any((r) => r.id == id)) {
      _selectedRobotId = id;
      notifyListeners();
    }
  }

  void setSimulationSpeed(double speed) {
    _simulationSpeed = speed;
    _startTelemetryLoop();
    notifyListeners();
  }

  void toggleManualDrive() {
    _isManualDriveEnabled = !_isManualDriveEnabled;
    notifyListeners();
  }

  /// Emergency Stop Action: Immediately halts drive motors for the selected robot
  void triggerEmergencyStop() {
    final index = _fleet.indexWhere((r) => r.id == _selectedRobotId);
    if (index == -1) return;

    final current = _fleet[index];
    _fleet[index] = current.copyWith(
      status: RobotStatus.offline,
      currentAmps: 0.0,
      health: current.health.copyWith(driveMotors: false),
      lastHeartbeat: DateTime.now(),
    );

    _mqttService.publish(ApiConstants.topicEmergencyStop, {
      'action': 'ESTOP_TRIGGERED',
      'robotId': current.id,
      'timestamp': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  /// Resumes normal autonomous operations after E-Stop clearance
  void resumeOperations() {
    final index = _fleet.indexWhere((r) => r.id == _selectedRobotId);
    if (index == -1) return;

    final current = _fleet[index];
    _fleet[index] = current.copyWith(
      status: RobotStatus.idle,
      currentAmps: 1.8,
      health: current.health.copyWith(driveMotors: true),
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  /// Updates robot status during mission lifecycle
  void updateStatus(RobotStatus newStatus, {String? wardName, String? targetRobotId}) {
    final idToUpdate = targetRobotId ?? _selectedRobotId;
    final index = _fleet.indexWhere((r) => r.id == idToUpdate);
    if (index == -1) return;

    final current = _fleet[index];
    _fleet[index] = current.copyWith(
      status: newStatus,
      assignedWard: wardName ?? current.assignedWard,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  /// Cycles autonomous robot position along corridor for selected robot
  void stepAutonomousTransit() {
    final index = _fleet.indexWhere((r) => r.id == _selectedRobotId);
    if (index == -1) return;

    final current = _fleet[index];
    if (current.status == RobotStatus.offline) return;

    _currentWaypointIndex = (_currentWaypointIndex + 1) % _corridorWaypoints.length;
    final target = _corridorWaypoints[_currentWaypointIndex];

    _fleet[index] = current.copyWith(
      coordinates: target,
      assignedWard: target.floor,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  void _startTelemetryLoop() {
    _telemetryTicker?.cancel();
    if (_simulationSpeed == 0.0) return; // Paused

    final intervalMs = (2500 / _simulationSpeed).round().clamp(500, 5000);

    _telemetryTicker = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      bool hasChanged = false;

      for (int i = 0; i < _fleet.length; i++) {
        final bot = _fleet[i];
        if (bot.status == RobotStatus.offline) continue;

        double newBattery = bot.batteryPercent;
        double newAmps = bot.currentAmps;
        double newTemp = bot.temperatureC;

        if (bot.status == RobotStatus.docked) {
          newBattery = (bot.batteryPercent + 0.1).clamp(0.0, 100.0);
          newAmps = 4.5;
        } else {
          newBattery = (bot.batteryPercent - 0.02).clamp(0.0, 100.0);
        }

        final voltWobble = 11.9 + (DateTime.now().second % 6) * 0.05;
        newTemp = 29.5 + (DateTime.now().second % 4) * 0.3;

        _fleet[i] = bot.copyWith(
          batteryLevel: newBattery.round(),
          voltage: voltWobble,
          currentAmps: newAmps,
          temperatureC: newTemp,
          lastHeartbeat: DateTime.now(),
        );
        hasChanged = true;
      }

      // If active selected robot is in transit, step position
      if (selectedRobot.status == RobotStatus.enRoute) {
        stepAutonomousTransit();
      }

      if (hasChanged) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _telemetryTicker?.cancel();
    super.dispose();
  }
}
