import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limpyo_pisaan/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('reports require meaningful type, landmark, and description', () {
    final draft = ReportDraft();
    expect(
      draft.validate().keys,
      containsAll(['type', 'location', 'description']),
    );
    draft.type = 'Illegal dumping';
    draft.location = '   ';
    draft.description = 'Bags beside the path';
    expect(draft.validate().containsKey('location'), isTrue);
  });
  test('saved reports get unique references and survive reloading', () async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    final report = await state.submitReport(
      ReportDraft(
        type: 'Illegal dumping',
        location: 'Sample lane',
        description: 'Tied bags by the path',
      ),
    );
    expect(report.id, 'LP-001');
    expect(report.status, 'Pending');
    final reloaded = AppState(prefs);
    expect(reloaded.reports.first.id, report.id);
    expect(reloaded.reports.first.description, 'Tied bags by the path');
  });
  test(
    'logout preserves reports and returns to login rather than welcome',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final state = AppState(prefs);
      await state.login('Demo Neighbor', 'neighbor@example.com');
      await state.submitReport(
        ReportDraft(
          type: 'Illegal dumping',
          location: 'Lane A',
          description: 'Bags beside the path',
        ),
      );
      await state.logout();
      expect(state.stage, AuthStage.login);
      expect(AppState(prefs).stage, AuthStage.login);
      expect(state.reports.length, 1);
      expect(prefs.getKeys().any((key) => key.contains('password')), isFalse);
    },
  );
  test(
    'old seeded reports are removed while resident reports are preserved',
    () async {
      SharedPreferences.setMockInitialValues({
        'name': 'Demo Resident',
        'reports': jsonEncode([
          const WasteReport(
            id: 'DEMO-LP-001',
            type: 'Uncollected trash',
            location: 'Example lane',
            description: 'Seeded report',
            status: 'Pending',
            date: '23 Oct 2026',
            sample: true,
          ).toJson(),
          const WasteReport(
            id: 'DEMO-LP-004',
            type: 'Illegal dumping',
            location: 'Near my store',
            description: 'Resident-created report',
            status: 'Pending',
            date: '27 Oct 2026',
          ).toJson(),
        ]),
      });
      final state = AppState(await SharedPreferences.getInstance());
      expect(state.reports.length, 1);
      expect(state.reports.single.id, 'LP-004');
      expect(state.reports.single.description, 'Resident-created report');
      expect(state.name, 'Resident');
    },
  );
}
