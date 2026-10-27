import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limpyo_pisaan/app.dart';
import 'package:limpyo_pisaan/state.dart';

void main() {
  Future<AppState> launch(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'signedIn': true});
    final state = AppState(await SharedPreferences.getInstance());
    await tester.pumpWidget(LimpyoApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('create and persist a showcase with validation', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await launch(tester);
    await tester.tap(find.text('Updates'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Showcase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add showcase'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Save showcase'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save showcase'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a title.'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title *'),
      'Our clean corner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Your story *'),
      'Nagtinabangay mi sa paghipos.',
    );
    await tester.scrollUntilVisible(
      find.text('Save showcase'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save showcase'));
    await tester.pumpAndSettle();
    expect(find.text('Our clean corner'), findsOneWidget);
    await tester.tap(find.text('Our clean corner'));
    await tester.pumpAndSettle();
    expect(find.text('Nagtinabangay mi sa paghipos.'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('showcases'), contains('Our clean corner'));
    expect(AppState(prefs).showcases.single.title, 'Our clean corner');
  });
  testWidgets('custom issue persists through review and submission', (
    tester,
  ) async {
    final state = await launch(tester);
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select an issue type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other waste-related concern'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Specify issue *'),
      'Broken glass on pathway',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Beside our store',
    );
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Glass pieces across the walkway.',
    );
    await tester.scrollUntilVisible(
      find.text('Review Report'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review Report'));
    await tester.pumpAndSettle();
    expect(find.text('Broken glass on pathway'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Save Report'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Report'));
    await tester.pumpAndSettle();
    expect(state.reports.single.type, 'Broken glass on pathway');
  });
}
