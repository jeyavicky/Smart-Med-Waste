import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_med_waste/main.dart';
import 'package:smart_med_waste/core/constants/app_constants.dart';

void main() {
  testWidgets('SmartMedWaste app loads dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    expect(find.text(AppConstants.appName), findsWidgets);
    expect(find.text('Request Pickup'), findsNWidgets(2)); // FAB + Quick Action
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Robot'), findsOneWidget);
    expect(find.text('Waste'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Navigation bar switches to Robot Telemetry screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    await tester.tap(find.text('Robot'));
    await tester.pumpAndSettle();

    expect(find.text('Robot Telemetry & Diagnostics'), findsOneWidget);
    await tester.drag(find.text('Power & Battery BMS'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Subsystem Diagnostics Checklist'), findsOneWidget);
  });

  testWidgets('Navigation bar switches to Waste Segregation screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    await tester.tap(find.text('Waste'));
    await tester.pump();

    expect(find.text('Waste Segregation & Compartments'), findsOneWidget);
    expect(find.text('Open Onboard AI Vision HUD'), findsOneWidget);
    expect(find.text('5 Standard Biomedical Compartments'), findsOneWidget);
  });

  testWidgets('Fleet Selector displays all 4 AMRs', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    expect(find.text('FLEET ORCHESTRATION'), findsOneWidget);
    expect(find.text('4 AMRs ONLINE'), findsOneWidget);
    expect(find.text('R01'), findsWidgets);
    expect(find.text('R02'), findsWidgets);
    expect(find.text('R03'), findsWidgets);
    expect(find.text('R04'), findsWidgets);
  });

  testWidgets('Open Request Pickup bottom sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    // Tap Floating Action Button
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify modal sheet contents
    expect(find.text('Request Waste Pickup'), findsOneWidget);
    expect(find.text('CONFIRM & DISPATCH ROBOT'), findsOneWidget);
  });

  testWidgets('Navigation bar switches to Stats screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    await tester.tap(find.text('Stats'));
    await tester.pump();

    expect(find.text('Waste Generation & Compliance Analytics'), findsOneWidget);
    expect(find.text('CPCB COMPLIANCE'), findsOneWidget);
  });

  testWidgets('Navigation bar switches to Settings screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartMedWasteApp());
    await tester.pump();

    await tester.tap(find.text('Settings'));
    await tester.pump();

    expect(find.text('Hospital & System Settings'), findsOneWidget);
    expect(find.text('Demo Simulation Engine (SIH Judges)'), findsOneWidget);
  });
}
