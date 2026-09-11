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

  // Hospital map routes with realistic waypoints per AMR
  static const Map<String, List<RobotRouteStep>> fleetRoutes = {
    'R01': [
      RobotRouteStep(
        title: 'ICU Station 01',
        subtitle: 'Start / Pickup',
        coordinates: RobotCoordinates(x: 75.0, y: 65.0, headingDegrees: 0.0, floor: 'Floor 2 (ICU Wing)'),
      ),
      RobotRouteStep(
        title: 'Airlock Door 1',
        subtitle: 'Bio-Seal Check',
        coordinates: RobotCoordinates(x: 140.0, y: 65.0, headingDegrees: 90.0, floor: 'Floor 2 (ICU Wing)'),
      ),
      RobotRouteStep(
        title: 'Corridor B West',
        subtitle: 'SLAM Navigating',
        coordinates: RobotCoordinates(x: 140.0, y: 160.0, headingDegrees: 180.0, floor: 'Floor 2 (Corridor B)'),
      ),
      RobotRouteStep(
        title: 'Transfer Chute',
        subtitle: 'Elevator Bay',
        coordinates: RobotCoordinates(x: 230.0, y: 160.0, headingDegrees: 90.0, floor: 'Floor 3 (OT Block)'),
      ),
      RobotRouteStep(
        title: 'Central Waste Facility',
        subtitle: 'Automated Deposit',
        coordinates: RobotCoordinates(x: 230.0, y: 260.0, headingDegrees: 180.0, floor: 'Basement Disinfection Hub'),
      ),
    ],
    'R02': [
      RobotRouteStep(
        title: 'OT Complex 03',
        subtitle: 'Surgery Pickup',
        coordinates: RobotCoordinates(x: 235.0, y: 65.0, headingDegrees: 180.0, floor: 'Floor 3 (OT Block)'),
      ),
      RobotRouteStep(
        title: 'Surgical Airlock',
        subtitle: 'Pathogen Seal',
        coordinates: RobotCoordinates(x: 180.0, y: 65.0, headingDegrees: 180.0, floor: 'Floor 3 (OT Block)'),
      ),
      RobotRouteStep(
        title: 'Central Junction',
        subtitle: 'Corridor Transit',
        coordinates: RobotCoordinates(x: 140.0, y: 110.0, headingDegrees: 90.0, floor: 'Floor 3 (Junction)'),
      ),
      RobotRouteStep(
        title: 'Service Elevator B',
        subtitle: 'Descent to Bay',
        coordinates: RobotCoordinates(x: 180.0, y: 180.0, headingDegrees: 135.0, floor: 'Floor 1 Transfer'),
      ),
      RobotRouteStep(
        title: 'Incineration Vault',
        subtitle: 'Incineration Deposit',
        coordinates: RobotCoordinates(x: 230.0, y: 240.0, headingDegrees: 180.0, floor: 'Basement Incinerator'),
      ),
    ],
    'R03': [
      RobotRouteStep(
        title: 'Dock Bay 03',
        subtitle: 'Inductive Pad',
        coordinates: RobotCoordinates(x: 230.0, y: 260.0, headingDegrees: 180.0, floor: 'Basement Disinfection Hub'),
      ),
      RobotRouteStep(
        title: 'Washout Chamber',
        subtitle: 'UV-C Sterilization',
        coordinates: RobotCoordinates(x: 190.0, y: 240.0, headingDegrees: 270.0, floor: 'Basement Decontamination'),
      ),
      RobotRouteStep(
        title: 'Elevator Hub',
        subtitle: 'Level Transit',
        coordinates: RobotCoordinates(x: 140.0, y: 180.0, headingDegrees: 0.0, floor: 'Sub-Level Junction'),
      ),
      RobotRouteStep(
        title: 'Basement Corridor',
        subtitle: 'Sub-Level Patrol',
        coordinates: RobotCoordinates(x: 160.0, y: 220.0, headingDegrees: 90.0, floor: 'Basement Corridor'),
      ),
      RobotRouteStep(
        title: 'Disinfection Dock 03',
        subtitle: 'Docked & Standby',
        coordinates: RobotCoordinates(x: 230.0, y: 260.0, headingDegrees: 180.0, floor: 'Basement Disinfection Hub'),
      ),
    ],
    'R04': [
      RobotRouteStep(
        title: 'Path Lab Station',
        subtitle: 'Specimen Waste Intake',
        coordinates: RobotCoordinates(x: 65.0, y: 225.0, headingDegrees: 0.0, floor: 'Floor 1 (Pathology Lab)'),
      ),
      RobotRouteStep(
        title: 'Specimen Airlock',
        subtitle: 'Bio-Safety Check',
        coordinates: RobotCoordinates(x: 105.0, y: 225.0, headingDegrees: 45.0, floor: 'Floor 1 (Pathology Lab)'),
      ),
      RobotRouteStep(
        title: 'Corridor South',
        subtitle: 'SLAM Navigating',
        coordinates: RobotCoordinates(x: 140.0, y: 200.0, headingDegrees: 90.0, floor: 'Floor 1 Corridor'),
      ),
      RobotRouteStep(
        title: 'Main Freight Chute',
        subtitle: 'Chute Docking',
        coordinates: RobotCoordinates(x: 185.0, y: 215.0, headingDegrees: 135.0, floor: 'Transfer Bay'),
      ),
      RobotRouteStep(
        title: 'Central Disposal Hub',
        subtitle: 'Automated Unload',
        coordinates: RobotCoordinates(x: 230.0, y: 255.0, headingDegrees: 180.0, floor: 'Basement Disinfection Hub'),
      ),
    ],
  };

  final Map<String, int> _robotWaypointIndices = {
    'R01': 0,
    'R02': 0,
    'R03': 0,
    'R04': 0,
  };

  bool _isAutoTraveling = false;

  RobotProvider() {
    _fleet = _dataService.getInitialFleet();
    _syncCurrentRobotPosition();
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
  bool get isAutoTraveling => _isAutoTraveling;

  List<RobotRouteStep> get currentRoute => fleetRoutes[_selectedRobotId] ?? fleetRoutes['R01']!;
  int get currentWaypointIndex => _robotWaypointIndices[_selectedRobotId] ?? 0;
  RobotRouteStep get currentWaypoint => currentRoute[currentWaypointIndex];
  RobotRouteStep get destinationWaypoint => currentRoute.last;

  // Backward compatibility getter
  List<RobotCoordinates> get corridorWaypoints => currentRoute.map((s) => s.coordinates).toList();

  void _syncCurrentRobotPosition() {
    final index = _fleet.indexWhere((r) => r.id == _selectedRobotId);
    if (index == -1) return;
    final route = currentRoute;
    final wpIndex = currentWaypointIndex.clamp(0, route.length - 1);
    final target = route[wpIndex].coordinates;
    _fleet[index] = _fleet[index].copyWith(
      coordinates: target,
      assignedWard: target.floor,
    );
  }

  void selectRobot(String id) {
    if (_selectedRobotId != id && _fleet.any((r) => r.id == id)) {
      _selectedRobotId = id;
      _syncCurrentRobotPosition();
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

  /// Cycles autonomous robot position along its designated route towards its destination
  void stepAutonomousTransit({String? robotId}) {
    final id = robotId ?? _selectedRobotId;
    final index = _fleet.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _fleet[index];
    if (current.status == RobotStatus.offline) return;

    final route = fleetRoutes[id] ?? fleetRoutes['R01']!;
    final currentIndex = _robotWaypointIndices[id] ?? 0;
    final nextIndex = (currentIndex + 1) % route.length;
    _robotWaypointIndices[id] = nextIndex;
    final target = route[nextIndex].coordinates;

    final isAtDestination = nextIndex == route.length - 1;
    final RobotStatus newStatus;
    if (isAtDestination) {
      newStatus = id == 'R03' ? RobotStatus.docked : RobotStatus.discharging;
      _isAutoTraveling = false;
    } else {
      newStatus = RobotStatus.enRoute;
    }

    _fleet[index] = current.copyWith(
      coordinates: target,
      assignedWard: target.floor,
      status: newStatus,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  /// Directly jump/navigate to a specific waypoint on the route
  void navigateToWaypoint(int targetIndex, {String? robotId}) {
    final id = robotId ?? _selectedRobotId;
    final index = _fleet.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _fleet[index];
    if (current.status == RobotStatus.offline) return;

    final route = fleetRoutes[id] ?? fleetRoutes['R01']!;
    final validIndex = targetIndex.clamp(0, route.length - 1);
    _robotWaypointIndices[id] = validIndex;
    final target = route[validIndex].coordinates;

    final isAtDestination = validIndex == route.length - 1;
    _fleet[index] = current.copyWith(
      coordinates: target,
      assignedWard: target.floor,
      status: isAtDestination
          ? (id == 'R03' ? RobotStatus.docked : RobotStatus.discharging)
          : RobotStatus.enRoute,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  /// Toggles continuous autonomous transit simulation
  void toggleAutoTransit() {
    _isAutoTraveling = !_isAutoTraveling;
    if (_isAutoTraveling) {
      final index = _fleet.indexWhere((r) => r.id == _selectedRobotId);
      if (index != -1 && _fleet[index].status != RobotStatus.offline) {
        _fleet[index] = _fleet[index].copyWith(status: RobotStatus.enRoute);
      }
    }
    notifyListeners();
  }

  /// Resets the robot route to waypoint 0 (pickup/origin)
  void resetRoute({String? robotId}) {
    final id = robotId ?? _selectedRobotId;
    final index = _fleet.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _fleet[index];
    final route = fleetRoutes[id] ?? fleetRoutes['R01']!;
    _robotWaypointIndices[id] = 0;
    _isAutoTraveling = false;
    final target = route[0].coordinates;

    _fleet[index] = current.copyWith(
      coordinates: target,
      assignedWard: target.floor,
      status: RobotStatus.idle,
      lastHeartbeat: DateTime.now(),
    );
    notifyListeners();
  }

  static bool enablePeriodicTimer = true;

  void _startTelemetryLoop() {
    _telemetryTicker?.cancel();
    if (!enablePeriodicTimer) return;
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

      // If active selected robot is in transit or auto-traveling, advance transit
      if (_isAutoTraveling || selectedRobot.status == RobotStatus.enRoute) {
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
