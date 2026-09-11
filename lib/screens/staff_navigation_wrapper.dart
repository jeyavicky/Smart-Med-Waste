import 'package:flutter/material.dart';
import 'dashboard/staff_dashboard_screen.dart';
import 'tracking/tracking_screen.dart';
import 'waste/waste_screen.dart';
import 'settings/settings_screen.dart';

class StaffNavigationWrapper extends StatefulWidget {
  const StaffNavigationWrapper({super.key});

  @override
  State<StaffNavigationWrapper> createState() => _StaffNavigationWrapperState();
}

class _StaffNavigationWrapperState extends State<StaffNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StaffDashboardScreen(),
    TrackingScreen(), // Simulates Robot Tracking
    WasteScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Tracking',
          ),
          NavigationDestination(
            icon: Icon(Icons.delete_sweep_outlined),
            selectedIcon: Icon(Icons.delete_sweep_rounded),
            label: 'Waste',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
