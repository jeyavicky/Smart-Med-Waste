import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_med_waste/main.dart';
import 'package:smart_med_waste/core/constants/app_constants.dart';

void main() {
  Future<void> loginAsAdmin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pumpAndSettle();

    final adminBtn = find.text('Login as Hospital Admin (Dr. Ramanujam)');
    expect(adminBtn, findsOneWidget);
    await tester.ensureVisible(adminBtn);
    await tester.tap(adminBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> loginAsStaff(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    final staffBtn = find.text('Login as ICU Ward Staff (Nurse Sunita)');
    expect(staffBtn, findsOneWidget);
    await tester.ensureVisible(staffBtn);
    await tester.tap(staffBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('LoginScreen loads and displays form and demo buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('Secure Login'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Login as Hospital Admin (Dr. Ramanujam)'), findsOneWidget);
    expect(find.text('Login as ICU Ward Staff (Nurse Sunita)'), findsOneWidget);
  });

  testWidgets('Admin login routes to Admin Navigation Wrapper & Dashboard', (WidgetTester tester) async {
    await loginAsAdmin(tester);

    expect(find.text('Admin Command Portal'), findsOneWidget);
    expect(find.text('ADMIN'), findsWidgets);
    expect(find.text('FLEET ORCHESTRATION'), findsOneWidget);
    expect(find.text('Executive Oversight Controls'), findsOneWidget);
    expect(find.text('Staff Management'), findsOneWidget);
    expect(find.text('Compliance Audit'), findsOneWidget);
  });

  testWidgets('Admin Dashboard opens Staff Management Sheet and lists staff', (WidgetTester tester) async {
    await loginAsAdmin(tester);

    final staffMgmtBtn = find.text('Staff Management');
    expect(staffMgmtBtn, findsOneWidget);
    await tester.tap(staffMgmtBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Clinical Staff Management'), findsOneWidget);
    expect(find.text('Nurse Sunita Kapoor'), findsOneWidget);
    expect(find.text('Dr. Ramanujam MD'), findsOneWidget);
  });

  testWidgets('Admin Navigation Bar switches to Fleet, Stats, and Settings', (WidgetTester tester) async {
    await loginAsAdmin(tester);

    // Fleet tab
    await tester.tap(find.text('Fleet'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Robot Telemetry & Diagnostics'), findsOneWidget);

    // Stats tab
    await tester.tap(find.text('Stats'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Waste Generation & Compliance Analytics'), findsOneWidget);

    // Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hospital & System Settings'), findsOneWidget);
  });

  testWidgets('Staff login routes to Staff Navigation Wrapper & Ward Portal', (WidgetTester tester) async {
    await loginAsStaff(tester);

    expect(find.text('Staff Ward Portal'), findsOneWidget);
    expect(find.text('WARD STAFF'), findsOneWidget);
    expect(find.text('DISPATCH ROBOT / REQUEST WARD PICKUP'), findsOneWidget);
    expect(find.text('Ward Waste Operations'), findsOneWidget);
    expect(find.text('Scan Waste / AI HUD'), findsOneWidget);
    expect(find.text('Live AMR Tracker'), findsOneWidget);
  });

  testWidgets('Staff Dashboard opens Request Collection Sheet', (WidgetTester tester) async {
    await loginAsStaff(tester);

    final pickupBtn = find.text('DISPATCH ROBOT / REQUEST WARD PICKUP');
    expect(pickupBtn, findsOneWidget);
    await tester.tap(pickupBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Request Waste Pickup'), findsOneWidget);
    expect(find.text('CONFIRM & DISPATCH ROBOT'), findsOneWidget);
  });

  testWidgets('Staff Dashboard opens AI Vision Inspection HUD', (WidgetTester tester) async {
    await loginAsStaff(tester);

    final scanBtn = find.text('Scan Waste / AI HUD');
    expect(scanBtn, findsOneWidget);
    await tester.tap(scanBtn);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CLINICAL AI INSPECTION PORTAL'), findsOneWidget);
  });

  testWidgets('Staff Navigation Bar switches to Tracking, Waste, and Settings', (WidgetTester tester) async {
    await loginAsStaff(tester);

    // Tracking tab
    await tester.tap(find.text('Tracking'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hospital Autonomous Transit Map'), findsOneWidget);

    // Waste tab
    await tester.tap(find.text('Waste'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Waste Segregation & Compartments'), findsOneWidget);

    // Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Hospital & System Settings'), findsOneWidget);
  });
}
