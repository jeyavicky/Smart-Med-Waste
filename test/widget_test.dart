import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_med_waste/main.dart';
import 'package:smart_med_waste/screens/auth/login_screen.dart';
import 'package:smart_med_waste/screens/core_navigation_shell.dart';
import 'package:smart_med_waste/providers/fleet_provider.dart';
import 'package:smart_med_waste/providers/waste_provider.dart';
import 'package:smart_med_waste/models/waste_item_model.dart';
import 'package:smart_med_waste/models/mission_model.dart';
import 'package:smart_med_waste/services/websocket_service.dart';
import 'package:smart_med_waste/providers/robot_provider.dart';
import 'package:smart_med_waste/services/mqtt_service.dart';
import 'package:smart_med_waste/services/api_service.dart';
import 'package:smart_med_waste/providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() {
    WebSocketService.enablePeriodicTimer = false;
    RobotProvider.enablePeriodicTimer = false;
    SimulatedMqttService.enablePeriodicTimer = false;
    ApiService.enableNetworkDelays = false;
  });

  tearDownAll(() {
    WebSocketService.enablePeriodicTimer = true;
    RobotProvider.enablePeriodicTimer = true;
    SimulatedMqttService.enablePeriodicTimer = true;
    ApiService.enableNetworkDelays = true;
  });

  Future<void> loginAsAdmin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pumpAndSettle();

    final adminBtn = find.text('Admin Officer');
    expect(adminBtn, findsOneWidget);
    await tester.ensureVisible(adminBtn);
    await tester.tap(adminBtn);
    await tester.pumpAndSettle();
  }

  Future<void> loginAsStaff(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pumpAndSettle();

    final staffBtn = find.text('Clinical Staff');
    expect(staffBtn, findsOneWidget);
    await tester.ensureVisible(staffBtn);
    await tester.tap(staffBtn);
    await tester.pumpAndSettle();
  }

  testWidgets('LoginScreen displays form, fields, and quick demo buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SMART MED-WASTE'), findsOneWidget);
    expect(find.text('CLINICAL PORTAL ACCESS'), findsOneWidget);
    expect(find.text('AUTHENTICATE & ENTER PORTAL'), findsOneWidget);
    expect(find.text('Admin Officer'), findsOneWidget);
    expect(find.text('Clinical Staff'), findsOneWidget);
  });

  testWidgets('Admin login routes to Core Navigation Shell with Admin features', (WidgetTester tester) async {
    await loginAsAdmin(tester);

    expect(find.byType(CoreNavigationShell), findsOneWidget);
    expect(find.text('ADMIN'), findsOneWidget);
    expect(find.text('FLEET ACTIVE'), findsOneWidget);
    expect(find.text('CPCB COMPLIANCE'), findsOneWidget);
    expect(find.text('Live Fleet Tracking'), findsOneWidget);
  });

  testWidgets('Staff login routes to Core Navigation Shell with Staff portal', (WidgetTester tester) async {
    await loginAsStaff(tester);

    expect(find.byType(CoreNavigationShell), findsOneWidget);
    expect(find.text('STAFF'), findsOneWidget);
    expect(find.text('CLINICAL WARD PORTAL'), findsOneWidget);
    expect(find.text('DISPATCH COLLECTION ROVER'), findsOneWidget);
  });

  testWidgets('5-Core Navigation Shell switches between Home, Robots, Waste, Analytics, and More', (WidgetTester tester) async {
    await loginAsAdmin(tester);

    // Tab 2: Robots
    await tester.tap(find.text('Robots'));
    await tester.pumpAndSettle();
    expect(find.text('FLEET DISPATCH & AMR TELEMETRY'), findsOneWidget);
    expect(find.text('CLINICAL WING - LEVEL 2 & 3 SCHEMATIC'), findsOneWidget);
    expect(find.text('RECALL TO BAY'), findsOneWidget);

    // Tab 3: Waste
    await tester.tap(find.text('Waste'));
    await tester.pumpAndSettle();
    expect(find.text('WASTE SEGREGATION & TRACEABILITY'), findsOneWidget);
    expect(find.text('AI Vision Viewfinder'), findsOneWidget);
    expect(find.text('QR Bag Traceability'), findsOneWidget);

    // Tab 4: Analytics
    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('ANALYTICS & CPCB REGULATORY LEDGER'), findsOneWidget);
    expect(find.text('5-COMPARTMENT WEIGHT ALLOCATION'), findsOneWidget);

    // Tab 5: More
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('SYSTEM CENTER & PREFERENCES'), findsOneWidget);
    expect(find.text('Alert Center'), findsOneWidget);
    expect(find.text('Offline Sync'), findsOneWidget);
    expect(find.text('Profile & Ops'), findsOneWidget);
  });

  test('Smart Assignment scoring calculates balanced score', () {
    final fleet = FleetProvider();
    final r01 = fleet.robots['R01']!;
    final score = fleet.calculateScore(r01, departmentPriorityMultiplier: 1.2);

    expect(score.totalScore, greaterThan(0.0));
    expect(score.totalScore, lessThanOrEqualTo(100.0));
    expect(score.rationale, isNotEmpty);
  });

  test('WasteProvider AI confidence logic auto-locks >=80% and flags <80%', () async {
    final waste = WasteProvider();

    // High confidence item
    await waste.simulateYoloDetection(
      objectName: 'Needle 5ml',
      category: WasteCategory.sharps,
      confidence: 0.95,
      weight: 0.1,
    );

    expect(waste.currentDetection, isNotNull);
    expect(waste.currentDetection!.isHighConfidence, isTrue);
    expect(waste.currentDetection!.isDiverterLocked, isTrue);
    expect(waste.currentDetection!.internalActionDetails, contains('AUTO-LOCKED'));

    // Manual override simulation
    waste.applyManualOverride(
      correctedCategory: WasteCategory.infectious,
      operatorId: 'OP-Tester',
    );

    expect(waste.currentDetection!.category, WasteCategory.infectious);
    expect(waste.currentDetection!.isManualOverride, isTrue);
  });

  test('QR Bag generation creates BAG-YYYY-XXXXX format', () {
    final waste = WasteProvider();
    final bag = waste.generateNewBagQr(
      ward: 'ICU Wing Floor 2',
      category: 'Sharps',
      weightKg: 1.5,
      missionId: 'MSN-2026-TEST',
      generatedBy: 'Nurse Sunita',
    );

    expect(bag.bagId, startsWith('BAG-'));
    expect(bag.ward, 'ICU Wing Floor 2');
    expect(bag.weightKg, 1.5);
    expect(bag.toQrString(), contains('BAG-'));
  });
}
