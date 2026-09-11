import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/fleet_provider.dart';
import 'providers/robot_provider.dart';
import 'providers/mission_provider.dart';
import 'providers/waste_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/waste_analytics_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/core_navigation_shell.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartMedWasteApp());
}

class SmartMedWasteApp extends StatelessWidget {
  const SmartMedWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FleetProvider()),
        ChangeNotifierProvider(create: (_) => RobotProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => WasteProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => WasteAnalyticsProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          Widget homeScreen = const LoginScreen();

          if (authProvider.isAuthenticated && authProvider.currentUser != null) {
            homeScreen = const CoreNavigationShell();
          }

          return MaterialApp(
            key: ValueKey(authProvider.isAuthenticated ? (authProvider.currentUser?.uid ?? 'auth') : 'unauth'),
            title: 'Smart Med-Waste AMR',
            scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.nordicClinicalTheme,
            darkTheme: AppTheme.nordicClinicalTheme,
            themeMode: ThemeMode.light,
            home: homeScreen,
          );
        },
      ),
    );
  }
}
