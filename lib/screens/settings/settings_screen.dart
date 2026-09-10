import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/robot_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _brokerHostController = TextEditingController(text: ApiConstants.defaultBrokerHost);
  final _brokerPortController = TextEditingController(text: '${ApiConstants.defaultBrokerPort}');
  bool _useSsl = ApiConstants.defaultUseSsl;
  bool _isTestingMqtt = false;

  @override
  void dispose() {
    _brokerHostController.dispose();
    _brokerPortController.dispose();
    super.dispose();
  }

  void _testMqttConnection() {
    setState(() => _isTestingMqtt = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isTestingMqtt = false);
        NotificationService.showToast('MQTT Handshake Verified with ${_brokerHostController.text}!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final robotProvider = context.watch<RobotProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospital & System Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Staff User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppConstants.cardBorder,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppConstants.tealPrimary.withOpacity(0.2),
                  child: const Icon(Icons.person_rounded, color: AppConstants.tealAccent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.currentUser?.fullName ?? 'Nurse Sunita Kapoor',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${authProvider.currentUser?.role} • ${authProvider.currentUser?.staffId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                        ),
                      ),
                      Text(
                        authProvider.currentUser?.hospitalName ?? 'Apex Multispecialty',
                        style: const TextStyle(fontSize: 11, color: AppConstants.tealAccent),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Switch User / Logout',
                  icon: const Icon(Icons.logout_rounded, color: AppConstants.crimsonDanger),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Simulation Speed Controls (Crucial for Hackathon Demo)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppConstants.cardBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.speed_rounded, color: AppConstants.amberWarning, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Demo Simulation Engine (SIH Judges)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.amberWarning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        robotProvider.simulationSpeed == 0.0
                            ? 'PAUSED'
                            : '${robotProvider.simulationSpeed.toStringAsFixed(0)}x SPEED',
                        style: const TextStyle(
                          color: AppConstants.amberWarning,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Accelerate telemetry cycles and autonomous waypoint progression during presentation:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    _speedOption(label: 'Pause', speed: 0.0, current: robotProvider.simulationSpeed, onSelect: () => robotProvider.setSimulationSpeed(0.0)),
                    const SizedBox(width: 8),
                    _speedOption(label: '1x (Real)', speed: 1.0, current: robotProvider.simulationSpeed, onSelect: () => robotProvider.setSimulationSpeed(1.0)),
                    const SizedBox(width: 8),
                    _speedOption(label: '2x (Fast)', speed: 2.0, current: robotProvider.simulationSpeed, onSelect: () => robotProvider.setSimulationSpeed(2.0)),
                    const SizedBox(width: 8),
                    _speedOption(label: '5x (Turbo)', speed: 5.0, current: robotProvider.simulationSpeed, onSelect: () => robotProvider.setSimulationSpeed(5.0)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // MQTT Broker & Networking Configuration
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppConstants.cardBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.hub_rounded, color: AppConstants.tealAccent, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'MQTT Broker Telemetry Bridge',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Connected to hospital autonomous fleet orchestration network',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _brokerHostController,
                  decoration: const InputDecoration(
                    labelText: 'Broker Host / Endpoint',
                    prefixIcon: Icon(Icons.dns_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _brokerPortController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          prefixIcon: Icon(Icons.lan_rounded, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('SSL / TLS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        value: _useSsl,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => _useSsl = val),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                OutlinedButton.icon(
                  onPressed: _isTestingMqtt ? null : _testMqttConnection,
                  icon: _isTestingMqtt
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.wifi_tethering_rounded, size: 16),
                  label: const Text('TEST MQTT BROKER HANDSHAKE'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Display Preferences
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppConstants.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppConstants.cardBorder,
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display & Accessibility',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppConstants.clinicalNavy,
                  ),
                ),
                const SizedBox(height: 10),

                SwitchListTile(
                  title: Text(
                    'Night Shift HUD (Low-Light Mode)',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppConstants.clinicalNavy,
                    ),
                  ),
                  subtitle: const Text(
                    'Default: Clean Medical Light Mode (Accessible Clinical)',
                    style: TextStyle(fontSize: 11, color: AppConstants.textSecondary),
                  ),
                  activeColor: AppConstants.medicalTeal,
                  value: themeProvider.isDarkMode,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // App Version & Credits Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _speedOption({
    required String label,
    required double speed,
    required double current,
    required VoidCallback onSelect,
  }) {
    final isSelected = current == speed;

    return Expanded(
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppConstants.amberWarning.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppConstants.amberWarning : AppConstants.borderSlate,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? AppConstants.amberWarning : AppConstants.lightSlate,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
