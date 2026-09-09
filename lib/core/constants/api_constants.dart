/// MQTT Topics and Service Endpoints for SmartMedWaste
class ApiConstants {
  // MQTT Broker Defaults
  static const String defaultBrokerHost = 'broker.emqx.io';
  static const int defaultBrokerPort = 8883;
  static const bool defaultUseSsl = true;
  static const String defaultClientId = 'smartmedwaste_app_client';

  // Topic Namespaces
  static const String baseTopic = 'hospital/waste';

  // Specific Subscribed & Published Topics
  static const String topicRobotTelemetry = '$baseTopic/robot/telemetry';
  static const String topicRobotHealth = '$baseTopic/robot/health';
  static const String topicMissionCreate = '$baseTopic/mission/create';
  static const String topicMissionStatus = '$baseTopic/mission/status';
  static const String topicMissionCancel = '$baseTopic/mission/cancel';
  static const String topicAiDetection = '$baseTopic/ai/detection';
  static const String topicLoadCellWeight = '$baseTopic/sensors/loadcell';
  static const String topicCompartmentLevels = '$baseTopic/compartments/levels';
  static const String topicAlerts = '$baseTopic/alerts/broadcast';
  static const String topicEmergencyStop = '$baseTopic/robot/estop';

  // REST API Stubs
  static const String restBaseUrl = 'https://api.smartmedwaste.hospital.internal/v1';
  static const String endpointLedgerRecords = '$restBaseUrl/ledger/records';
  static const String endpointVerifyToken = '$restBaseUrl/ledger/verify';
  static const String endpointCpcbReport = '$restBaseUrl/compliance/cpcb-export';
}
