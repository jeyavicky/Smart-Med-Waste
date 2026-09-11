import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/mission_provider.dart';
import 'providers/robot_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/waste_analytics_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin_navigation_wrapper.dart';
import 'screens/staff_navigation_wrapper.dart';
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
        ChangeNotifierProvider(create: (_) => RobotProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => WasteAnalyticsProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          Widget homeScreen = const LoginScreen();
          
          if (authProvider.isAuthenticated && authProvider.currentUser != null) {
            if (authProvider.currentUser!.role == 'admin') {
              homeScreen = const AdminNavigationWrapper();
            } else {
              homeScreen = const StaffNavigationWrapper();
            }
          }

          return MaterialApp(
            key: ValueKey(authProvider.isAuthenticated ? (authProvider.currentUser?.uid ?? 'auth') : 'unauth'),
            title: AppConstants.appName,
            scaffoldMessengerKey: NotificationService.scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: homeScreen,
          );
        },
      ),
    );
  }
}
