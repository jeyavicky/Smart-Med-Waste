import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _staffIdController = TextEditingController(text: 'STF-4428');
  final _pinController = TextEditingController(text: '••••');

  void _proceedToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo / Icon
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppConstants.tealPrimary, Color(0xFF0F766E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.tealPrimary.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title & Tagline
                  const Center(
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'AI Autonomous Medical Waste Segregation',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.tealPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Smart India Hackathon • Problem PS 26115',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppConstants.tealAccent,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surfaceSlate : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Hospital Staff Sign In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: _staffIdController,
                          decoration: const InputDecoration(
                            labelText: 'Hospital Staff ID',
                            prefixIcon: Icon(Icons.badge_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Clinical Security PIN',
                            prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: () {
                            auth.loginAsRole(
                              staffId: _staffIdController.text,
                              name: 'Nurse Sunita K.',
                              role: 'Ward Incharge',
                              ward: 'ICU - Floor 2',
                            );
                            _proceedToApp();
                          },
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('AUTHENTICATE & ENTER'),
                        ),

                        const SizedBox(height: 12),

                        OutlinedButton.icon(
                          onPressed: () {
                            auth.loginAsRole(
                              staffId: 'BIO-209',
                              name: 'Nurse Sunita K.',
                              role: 'Biometric Authenticated Nurse',
                              ward: 'ICU - Floor 2',
                            );
                            _proceedToApp();
                          },
                          icon: const Icon(Icons.fingerprint_rounded),
                          label: const Text('BIOMETRIC RFID / NFC SCAN'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Demo Logins for SIH Judging
                  Center(
                    child: Text(
                      'QUICK DEMO ROLES (SIH JUDGING)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildQuickDemoChip(
                    context,
                    title: 'ICU Ward Staff Nurse',
                    subtitle: 'Request pickup, monitor disposal, track bin fullness',
                    icon: Icons.local_hospital_rounded,
                    onTap: () {
                      auth.loginAsRole(
                        staffId: 'STF-4428',
                        name: 'Nurse Sunita Kapoor',
                        role: 'ICU Ward Incharge',
                        ward: 'ICU - Floor 2',
                      );
                      _proceedToApp();
                    },
                  ),
                  const SizedBox(height: 8),

                  _buildQuickDemoChip(
                    context,
                    title: 'Hospital Infection Control Officer',
                    subtitle: 'Regulatory compliance ledger, CPCB audits, alerts',
                    icon: Icons.shield_rounded,
                    onTap: () {
                      auth.loginAsRole(
                        staffId: 'ADM-9011',
                        name: 'Dr. Ramanujam MD',
                        role: 'Infection Control Officer',
                        ward: 'Hospital Wide',
                      );
                      _proceedToApp();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDemoChip(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: (isDark ? AppConstants.surfaceSlate : Colors.white).withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppConstants.borderSlate : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppConstants.tealAccent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppConstants.lightSlate : AppConstants.neutralGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppConstants.neutralGrey),
          ],
        ),
      ),
    );
  }
}
