import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limpyo_pisaan/app.dart';
import 'package:limpyo_pisaan/state.dart';

class DelayedAppState extends AppState {
  final gate = Completer<void>();
  DelayedAppState(super.prefs);
  @override
  Future<WasteReport> submitReport(ReportDraft draft) async {
    await gate.future;
    return super.submitReport(draft);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<AppState> loadApp(WidgetTester tester, {bool signedIn = false}) async {
    SharedPreferences.setMockInitialValues({
      'welcomed': true,
      'signedIn': signedIn,
    });
    final state = AppState(await SharedPreferences.getInstance());
    await tester.pumpWidget(LimpyoApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('demo login opens the five-tab native app', (tester) async {
    await loadApp(tester);
    await tester.ensureVisible(find.text('Continue as guest →'));
    await tester.tap(find.text('Continue as guest →'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Hello, Resident'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('all main screens fit a narrow phone without layout exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await loadApp(tester, signedIn: true);
    expect(tester.takeException(), isNull);
    for (final tab in ['Updates', 'Collection', 'Report', 'Profile', 'Home']) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(tab),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: '$tab should fit a 320px phone',
      );
    }
    await tester.tap(find.text('Updates'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Showcase'));
    await tester.pumpAndSettle();
    expect(find.text('Naunsa naman ni atong palibot? 😩'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty report highlights required fields without submitting', (
    tester,
  ) async {
    final state = await loadApp(tester, signedIn: true);
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(FilledButton, 'Review Report');
    await tester.scrollUntilVisible(
      submit,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Review Report'), findsOneWidget);
    expect(state.reports.length, 0);
    expect(find.text('Choose an issue type.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'report review, edit and submit preserve details and save locally',
    (tester) async {
      final state = await loadApp(tester, signedIn: true);
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select an issue type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Illegal dumping'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Near the sample store',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Tied bags beside the path',
      );
      final review = find.widgetWithText(FilledButton, 'Review Report');
      await tester.scrollUntilVisible(
        review,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      expect(find.text('Near the sample store'), findsOneWidget);
      final edit = find.widgetWithText(OutlinedButton, 'Edit Report');
      await tester.scrollUntilVisible(
        edit,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(find.text('Near the sample store'), findsOneWidget);
      await tester.scrollUntilVisible(
        review,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(FilledButton, 'Save Report');
      await tester.scrollUntilVisible(
        submit,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(find.text('Report saved\nsuccessfully!'), findsOneWidget);
      expect(state.reports.first.location, 'Near the sample store');
      expect(state.reports.first.id, 'LP-001');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'navigation cannot interrupt a save and retain the submitted draft',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'welcomed': true,
        'signedIn': true,
      });
      final state = DelayedAppState(await SharedPreferences.getInstance());
      await tester.pumpWidget(LimpyoApp(state: state));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select an issue type'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Illegal dumping'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Test landmark');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Test waste concern',
      );
      final review = find.widgetWithText(FilledButton, 'Review Report');
      await tester.scrollUntilVisible(
        review,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(FilledButton, 'Save Report');
      await tester.scrollUntilVisible(
        submit,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pump();
      expect(
        tester
            .widget<NavigationBar>(find.byType(NavigationBar))
            .onDestinationSelected,
        isNull,
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Saving…'), findsOneWidget);
      state.gate.complete();
      await tester.pumpAndSettle();
      expect(find.text('Report saved\nsuccessfully!'), findsOneWidget);
      expect(state.reports.length, 1);
    },
  );
}
