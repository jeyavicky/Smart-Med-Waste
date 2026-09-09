import 'dart:async';
import 'package:flutter/material.dart';
import '../models/robot_model.dart';
import '../services/mock_data_service.dart';
import '../services/mqtt_service.dart';
import '../core/constants/api_constants.dart';

class RobotProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService.instance;
  final MqttService _mqttService = SimulatedMqttService.instance;

  late RobotModel _robot;
  Timer? _telemetryTicker;
  double _simulationSpeed = 1.0; // 1x, 2x, 5x, 0.0 (paused)
  bool _isManualDriveEnabled = false;

  // Hospital map waypoints for autonomous corridor transit
  final List<RobotCoordinates> _corridorWaypoints = const [
    RobotCoordinates(x: 75.0, y: 65.0, headingDegrees: 0.0, floor: 'Floor 2 (ICU Wing)'), // ICU Drop Bay
    RobotCoordinates(x: 140.0, y: 65.0, headingDegrees: 90.0, floor: 'Floor 2 (ICU Wing)'), // Airlock 1
    RobotCoordinates(x: 140.0, y: 160.0, headingDegrees: 180.0, floor: 'Floor 2 (Corridor B)'), // Central Corridor
    RobotCoordinates(x: 230.0, y: 160.0, headingDegrees: 90.0, floor: 'Floor 2 (Corridor B)'), // Transfer Bay
    RobotCoordinates(x: 230.0, y: 260.0, headingDegrees: 180.0, floor: 'Basement Disinfection Hub'), // Central Waste
  ];
  int _currentWaypointIndex = 0;

  RobotProvider() {
    _robot = _dataService.getInitialRobot();
    _startTelemetryLoop();
  }

  RobotModel get robot => _robot;
  double get simulationSpeed => _simulationSpeed;
  bool get isManualDriveEnabled => _isManualDriveEnabled;
  List<RobotCoordinates> get corridorWaypoints => _corridorWaypoints;
  int get currentWaypointIndex => _currentWaypointIndex;

  void setSimulationSpeed(double speed) {
    _simulationSpeed = speed;
    _startTelemetryLoop();
    notifyListeners();
  }

  void toggleManualDrive() {
    _isManualDriveEnabled = !_isManualDriveEnabled;
    notifyListeners();
  }

  /// Emergency Stop Action: Immediately halts all drive motors and engages safety locks
  void triggerEmergencyStop() {
    _robot = _robot.copyWith(
      status: RobotStatus.emergencyStop,
      currentAmps: 0.0,
      health: _robot.health.copyWith(driveMotors: false),
      lastHeartbeat: DateTime.now(),
    );

    _mqttService.publish(ApiConstants.topicEmergencyStop, {
      'action': 'ESTOP_TRIGGERED',
      'robotId': _robot.id,
      'timestamp': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  /// Resumes normal autonomous operations after E-Stop clearance
  void resumeOperations() {
    _robot = _robot.copyWith(
      status: RobotStatus.idle,
      currentAmps: 1.8,
      health: _robot.health.copyWith(driveMotors: true),
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  /// Updates robot status during mission lifecycle
  void updateStatus(RobotStatus newStatus, {String? wardName}) {
    _robot = _robot.copyWith(
      status: newStatus,
      currentWard: wardName ?? _robot.currentWard,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  /// Cycles autonomous robot position along corridor
  void stepAutonomousTransit() {
    if (_robot.status == RobotStatus.emergencyStop) return;

    _currentWaypointIndex = (_currentWaypointIndex + 1) % _corridorWaypoints.length;
    final target = _corridorWaypoints[_currentWaypointIndex];

    _robot = _robot.copyWith(
      coordinates: target,
      currentWard: target.floor,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  void _startTelemetryLoop() {
    _telemetryTicker?.cancel();
    if (_simulationSpeed == 0.0) return; // Paused

    final intervalMs = (2500 / _simulationSpeed).round().clamp(500, 5000);

    _telemetryTicker = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (_robot.status == RobotStatus.emergencyStop) return;

      // Slight natural variance in telemetry
      double newBattery = _robot.batteryPercent;
      double newAmps = _robot.currentAmps;
      double newTemp = _robot.tempCelsius;

      if (_robot.status == RobotStatus.dockedCharging) {
        newBattery = (_robot.batteryPercent + 0.1).clamp(0.0, 100.0);
        newAmps = 4.5; // Charging current
      } else {
        newBattery = (_robot.batteryPercent - 0.02).clamp(0.0, 100.0);
      }

      // Small wobble in voltage & temp
      final voltWobble = 11.9 + (DateTime.now().second % 6) * 0.05;
      newTemp = 30.2 + (DateTime.now().second % 4) * 0.2;

      _robot = _robot.copyWith(
        batteryPercent: newBattery,
        voltage: voltWobble,
        currentAmps: newAmps,
        tempCelsius: newTemp,
        lastHeartbeat: DateTime.now(),
      );

      // If in transit, automatically step position
      if (_robot.status == RobotStatus.navigatingToWard ||
          _robot.status == RobotStatus.returningToDisposal) {
        stepAutonomousTransit();
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _telemetryTicker?.cancel();
    super.dispose();
  }
}
