import 'dart:async';
import 'dart:math';
import '../models/mission_model.dart';
import '../models/alert_model.dart';

class RobotTelemetryPacket {
  final String robotId;
  final double x;
  final double y;
  final double headingDegrees;
  final int batteryLevel;
  final double temperatureC;
  final double currentAmps;
  final DateTime timestamp;

  const RobotTelemetryPacket({
    required this.robotId,
    required this.x,
    required this.y,
    required this.headingDegrees,
    required this.batteryLevel,
    required this.temperatureC,
    required this.currentAmps,
    required this.timestamp,
  });
}

/// Simulates WebSocket connection to FastAPI / MQTT Broker for R01–R04 telemetry
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  Timer? _telemetryTimer;
  final _telemetryController = StreamController<RobotTelemetryPacket>.broadcast();
  final _missionUpdateController = StreamController<MissionModel>.broadcast();
  final _alertController = StreamController<AlertModel>.broadcast();

  Stream<RobotTelemetryPacket> get telemetryStream => _telemetryController.stream;
  Stream<MissionModel> get missionUpdateStream => _missionUpdateController.stream;
  Stream<AlertModel> get alertStream => _alertController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Mock path coordinates for corridor waypoint simulation
  final List<Point<double>> _waypoints = const [
    Point(110.0, 75.0),
    Point(145.0, 80.0),
    Point(190.0, 85.0),
    Point(240.0, 90.0),
    Point(275.0, 130.0),
    Point(280.0, 190.0),
    Point(235.0, 210.0),
    Point(170.0, 205.0),
    Point(120.0, 180.0),
    Point(100.0, 120.0),
  ];

  int _waypointIndex = 0;
  final Map<String, int> _batteries = {
    'R01': 88,
    'R02': 74,
    'R03': 95,
    'R04': 42,
  };

  static bool enablePeriodicTimer = true;

  void connect() {
    if (_isConnected) return;
    _isConnected = true;

    if (!enablePeriodicTimer) return;

    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _waypointIndex = (_waypointIndex + 1) % _waypoints.length;
      final currentPt = _waypoints[_waypointIndex];
      final nextPt = _waypoints[(_waypointIndex + 1) % _waypoints.length];
      final heading = atan2(nextPt.y - currentPt.y, nextPt.x - currentPt.x) * 180 / pi;

      for (final id in ['R01', 'R02', 'R03', 'R04']) {
        // Slow realistic battery drainage
        if (_batteries[id]! > 15) {
          if (timer.tick % 8 == 0) {
            _batteries[id] = _batteries[id]! - 1;
          }
        }

        // Slight coordinate offsets per robot
        final offsetIndex = (_waypointIndex + id.hashCode) % _waypoints.length;
        final pt = _waypoints[offsetIndex];

        final packet = RobotTelemetryPacket(
          robotId: id,
          x: pt.x + (Random().nextDouble() * 4 - 2),
          y: pt.y + (Random().nextDouble() * 4 - 2),
          headingDegrees: heading,
          batteryLevel: _batteries[id]!,
          temperatureC: 36.2 + (Random().nextDouble() * 0.8),
          currentAmps: 1.6 + (Random().nextDouble() * 0.4),
          timestamp: DateTime.now(),
        );

        _telemetryController.add(packet);
      }
    });
  }

  void disconnect() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
    _isConnected = false;
  }

  void broadcastMissionUpdate(MissionModel mission) {
    _missionUpdateController.add(mission);
  }

  void broadcastAlert(AlertModel alert) {
    _alertController.add(alert);
  }

  void dispose() {
    disconnect();
    _telemetryController.close();
    _missionUpdateController.close();
    _alertController.close();
  }
}
