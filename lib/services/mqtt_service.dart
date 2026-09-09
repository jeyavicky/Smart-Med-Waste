import 'dart:async';
import '../core/constants/api_constants.dart';

enum MqttConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

abstract class MqttService {
  Stream<MqttConnectionState> get connectionStateStream;
  Stream<Map<String, dynamic>> get telemetryStream;
  Stream<Map<String, dynamic>> get alertsStream;
  MqttConnectionState get currentState;

  Future<bool> connect({
    required String host,
    required int port,
    required bool useSsl,
    required String clientId,
  });

  Future<void> disconnect();

  Future<bool> publish(String topic, Map<String, dynamic> payload);

  Future<void> subscribe(String topic);
}

/// Simulated MQTT Service that faithfully implements the MQTT contracts,
/// allowing offline demonstration and seamless integration with real brokers.
class SimulatedMqttService implements MqttService {
  static final SimulatedMqttService instance = SimulatedMqttService._internal();
  SimulatedMqttService._internal();

  final StreamController<MqttConnectionState> _connectionStateController =
      StreamController<MqttConnectionState>.broadcast();
  final StreamController<Map<String, dynamic>> _telemetryController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _alertsController =
      StreamController<Map<String, dynamic>>.broadcast();

  MqttConnectionState _currentState = MqttConnectionState.connected;
  Timer? _telemetryTicker;

  @override
  Stream<MqttConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  @override
  Stream<Map<String, dynamic>> get telemetryStream => _telemetryController.stream;

  @override
  Stream<Map<String, dynamic>> get alertsStream => _alertsController.stream;

  @override
  MqttConnectionState get currentState => _currentState;

  @override
  Future<bool> connect({
    required String host,
    required int port,
    required bool useSsl,
    required String clientId,
  }) async {
    _currentState = MqttConnectionState.connecting;
    _connectionStateController.add(_currentState);

    await Future.delayed(const Duration(milliseconds: 600));

    _currentState = MqttConnectionState.connected;
    _connectionStateController.add(_currentState);
    _startSimulatedTelemetryStream();
    return true;
  }

  @override
  Future<void> disconnect() async {
    _telemetryTicker?.cancel();
    _currentState = MqttConnectionState.disconnected;
    _connectionStateController.add(_currentState);
  }

  @override
  Future<bool> publish(String topic, Map<String, dynamic> payload) async {
    // Simulate MQTT publish handshake
    // print('MQTT Published to [$topic]: $payload');
    if (topic == ApiConstants.topicMissionCreate) {
      // Simulate confirmation receipt
      _telemetryController.add({
        'type': 'MISSION_ACK',
        'status': 'ACCEPTED_DISPATCHED',
        'mission': payload,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } else if (topic == ApiConstants.topicEmergencyStop) {
      _alertsController.add({
        'type': 'EMERGENCY_STOP_ACTIVATED',
        'level': 'CRITICAL',
        'source': 'MOBILE_APP_OVERRIDE',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
    return true;
  }

  @override
  Future<void> subscribe(String topic) async {
    // In simulated mode, topics are automatically routed
  }

  void _startSimulatedTelemetryStream() {
    _telemetryTicker?.cancel();
    _telemetryTicker = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentState != MqttConnectionState.connected) return;

      _telemetryController.add({
        'type': 'TELEMETRY_PING',
        'battery': 88.0,
        'voltage': 12.1,
        'tempCelsius': 30.5,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });
  }

  void dispose() {
    _telemetryTicker?.cancel();
    _connectionStateController.close();
    _telemetryController.close();
    _alertsController.close();
  }
}
