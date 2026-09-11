import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/robot_model.dart';
import '../models/mission_model.dart';
import '../services/websocket_service.dart';

class SmartAssignmentScore {
  final String robotId;
  final double totalScore;
  final double fillScore;
  final double riskScore;
  final double priorityScore;
  final double batteryEtaScore;
  final String rationale;

  const SmartAssignmentScore({
    required this.robotId,
    required this.totalScore,
    required this.fillScore,
    required this.riskScore,
    required this.priorityScore,
    required this.batteryEtaScore,
    required this.rationale,
  });
}

class FleetProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription? _telemetrySub;

  Map<String, RobotModel> _robots = {};
  String _selectedRobotId = 'R01';
  bool _isAutoAssignmentEnabled = true;

  Map<String, RobotModel> get robots => _robots;
  List<RobotModel> get robotList => _robots.values.toList();
  String get selectedRobotId => _selectedRobotId;
  RobotModel get selectedRobot => _robots[_selectedRobotId] ?? _robots.values.first;
  bool get isAutoAssignmentEnabled => _isAutoAssignmentEnabled;

  FleetProvider() {
    _initializeFleet();
    _connectWebSocket();
  }

  void _initializeFleet() {
    _robots = {
      'R01': _buildRobot(
        id: 'R01',
        name: 'Nordic Rover Alpha',
        ward: 'Floor 2 (ICU Wing)',
        status: RobotStatus.enRoute,
        battery: 88,
        temp: 36.4,
        x: 120.0,
        y: 85.0,
        sharpsKg: 3.2,
        infectiousKg: 8.4,
        plasticKg: 4.1,
        glasswareKg: 1.8,
        unknownKg: 0.9,
      ),
      'R02': _buildRobot(
        id: 'R02',
        name: 'Nordic Rover Beta',
        ward: 'Floor 3 (Surgery OT)',
        status: RobotStatus.collecting,
        battery: 74,
        temp: 37.1,
        x: 230.0,
        y: 95.0,
        sharpsKg: 6.8,
        infectiousKg: 14.2,
        plasticKg: 5.5,
        glasswareKg: 3.0,
        unknownKg: 1.2,
      ),
      'R03': _buildRobot(
        id: 'R03',
        name: 'Nordic Rover Gamma',
        ward: 'Floor 1 (Pathology Lab)',
        status: RobotStatus.docked,
        battery: 96,
        temp: 34.8,
        x: 105.0,
        y: 190.0,
        sharpsKg: 0.0,
        infectiousKg: 0.0,
        plasticKg: 0.0,
        glasswareKg: 0.0,
        unknownKg: 0.0,
      ),
      'R04': _buildRobot(
        id: 'R04',
        name: 'Nordic Rover Delta',
        ward: 'Central Bio Disposal (Basement)',
        status: RobotStatus.discharging,
        battery: 42,
        temp: 38.2,
        x: 275.0,
        y: 180.0,
        sharpsKg: 9.8,
        infectiousKg: 19.5,
        plasticKg: 9.2,
        glasswareKg: 4.8,
        unknownKg: 2.7,
      ),
    };
  }

  void _connectWebSocket() {
    _wsService.connect();
    _telemetrySub = _wsService.telemetryStream.listen((packet) {
      if (_robots.containsKey(packet.robotId)) {
        final current = _robots[packet.robotId]!;
        _robots[packet.robotId] = current.copyWith(
          batteryLevel: packet.batteryLevel,
          temperatureC: packet.temperatureC,
          currentAmps: packet.currentAmps,
          coordinates: current.coordinates.copyWith(
            x: packet.x,
            y: packet.y,
            headingDegrees: packet.headingDegrees,
          ),
          lastHeartbeat: packet.timestamp,
        );
        notifyListeners();
      }
    });
  }

  RobotModel _buildRobot({
    required String id,
    required String name,
    required String ward,
    required RobotStatus status,
    required int battery,
    required double temp,
    required double x,
    required double y,
    required double sharpsKg,
    required double infectiousKg,
    required double plasticKg,
    required double glasswareKg,
    required double unknownKg,
  }) {
    return RobotModel(
      id: id,
      name: name,
      assignedWard: ward,
      status: status,
      batteryLevel: battery,
      voltage: 24.2,
      temperatureC: temp,
      coordinates: RobotCoordinates(x: x, y: y, headingDegrees: 0.0),
      aiCameraActive: true,
      compartments: {
        'sharps': Compartment(
          id: 'comp_sharps',
          name: 'Sharps Vault',
          badgeColor: AppTheme.sharpsColor,
          lightColor: AppTheme.sharpsBg,
          currentWeightKg: sharpsKg,
          capacityKg: 10.0,
          fillPercentage: ((sharpsKg / 10.0) * 100).round(),
          isFull: sharpsKg >= 9.0,
        ),
        'infectious': Compartment(
          id: 'comp_infectious',
          name: 'Infectious Bio-Lock',
          badgeColor: AppTheme.infectiousColor,
          lightColor: AppTheme.infectiousBg,
          currentWeightKg: infectiousKg,
          capacityKg: 20.0,
          fillPercentage: ((infectiousKg / 20.0) * 100).round(),
          isFull: infectiousKg >= 18.0,
        ),
        'plastic': Compartment(
          id: 'comp_plastic',
          name: 'Plastic Diverter',
          badgeColor: AppTheme.plasticColor,
          lightColor: AppTheme.plasticBg,
          currentWeightKg: plasticKg,
          capacityKg: 10.0,
          fillPercentage: ((plasticKg / 10.0) * 100).round(),
          isFull: plasticKg >= 9.0,
        ),
        'glassware': Compartment(
          id: 'comp_glassware',
          name: 'Glassware Chute',
          badgeColor: AppTheme.glasswareColor,
          lightColor: AppTheme.glasswareBg,
          currentWeightKg: glasswareKg,
          capacityKg: 5.0,
          fillPercentage: ((glasswareKg / 5.0) * 100).round(),
          isFull: glasswareKg >= 4.5,
        ),
        'unknown': Compartment(
          id: 'comp_unknown',
          name: 'Unknown Fallback',
          badgeColor: AppTheme.unknownColor,
          lightColor: AppTheme.unknownBg,
          currentWeightKg: unknownKg,
          capacityKg: 3.0,
          fillPercentage: ((unknownKg / 3.0) * 100).round(),
          isFull: unknownKg >= 2.7,
        ),
      },
    );
  }

  void selectRobot(String id) {
    if (_robots.containsKey(id)) {
      _selectedRobotId = id;
      notifyListeners();
    }
  }

  void toggleAutoAssignment(bool value) {
    _isAutoAssignmentEnabled = value;
    notifyListeners();
  }

  /// Calculates Intelligent Assignment Score:
  /// Score = Fill Level + Waste Risk + Department Priority + Robot Battery/ETA
  SmartAssignmentScore calculateScore(
    RobotModel robot, {
    double departmentPriorityMultiplier = 1.0,
    double wasteRiskScore = 0.5,
  }) {
    // 1. Available Capacity (Higher available capacity = higher score)
    final avgFillPct = robot.compartments.values
            .map((c) => c.fillPercentage)
            .reduce((a, b) => a + b) /
        robot.compartments.length;
    final fillScore = (100.0 - avgFillPct) * 0.35; // max 35 pts

    // 2. Waste Risk Readiness (Can handle bio-risk)
    final infectiousComp = robot.compartments['infectious'];
    final riskScore = (infectiousComp != null && !infectiousComp.isFull)
        ? (wasteRiskScore * 20.0) // max 20 pts
        : 5.0;

    // 3. Department Priority Weighting
    final priorityScore = departmentPriorityMultiplier * 15.0; // max 15 pts

    // 4. Battery Level & Proximity / ETA (Max 30 pts)
    final batteryFactor = (robot.batteryLevel / 100.0) * 20.0;
    final statusFactor = (robot.status == RobotStatus.idle || robot.status == RobotStatus.docked)
        ? 10.0
        : (robot.status == RobotStatus.enRoute ? 5.0 : 0.0);
    final batteryEtaScore = batteryFactor + statusFactor;

    final totalScore = (fillScore + riskScore + priorityScore + batteryEtaScore)
        .clamp(0.0, 100.0);

    final rationale = totalScore >= 75
        ? 'Optimal Match: High battery (${robot.batteryLevel}%) & ample capacity'
        : totalScore >= 50
            ? 'Moderate Candidate: Check compartment levels'
            : 'Deprioritized: High compartment load or low battery';

    return SmartAssignmentScore(
      robotId: robot.id,
      totalScore: double.parse(totalScore.toStringAsFixed(1)),
      fillScore: double.parse(fillScore.toStringAsFixed(1)),
      riskScore: double.parse(riskScore.toStringAsFixed(1)),
      priorityScore: double.parse(priorityScore.toStringAsFixed(1)),
      batteryEtaScore: double.parse(batteryEtaScore.toStringAsFixed(1)),
      rationale: rationale,
    );
  }

  /// Dispatches the highest-scoring robot for an incoming collection mission
  RobotModel getBestScoringRobot({
    MissionPriority priority = MissionPriority.normal,
  }) {
    final mult = priority == MissionPriority.emergencyBiologicalSpill
        ? 1.5
        : (priority == MissionPriority.high ? 1.2 : 1.0);

    RobotModel? best;
    double highestScore = -1.0;

    for (final r in _robots.values) {
      if (r.status == RobotStatus.offline) continue;
      final score = calculateScore(r, departmentPriorityMultiplier: mult).totalScore;
      if (score > highestScore) {
        highestScore = score;
        best = r;
      }
    }
    return best ?? _robots.values.first;
  }

  void dispatchRobotToMission(String robotId, String destination) {
    if (_robots.containsKey(robotId)) {
      _robots[robotId] = _robots[robotId]!.copyWith(
        status: RobotStatus.enRoute,
        destination: destination,
      );
      notifyListeners();
    }
  }

  void triggerEmergencyStop(String robotId) {
    if (_robots.containsKey(robotId)) {
      final r = _robots[robotId]!;
      final newStatus = r.status == RobotStatus.offline ? RobotStatus.idle : RobotStatus.offline;
      _robots[robotId] = r.copyWith(status: newStatus);
      notifyListeners();
    }
  }

  void recallToDisposalBay(String robotId) {
    if (_robots.containsKey(robotId)) {
      _robots[robotId] = _robots[robotId]!.copyWith(
        status: RobotStatus.discharging,
        destination: 'Central Bio-Hazard Bay',
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    super.dispose();
  }
}
