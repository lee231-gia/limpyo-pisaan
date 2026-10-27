import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:limpyo_pisaan/community.dart';
import 'package:limpyo_pisaan/community_photos.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all eight community photographs are bundled offline', () async {
    expect(communityPhotos.length, 8);
    for (final photo in communityPhotos) {
      final data = await rootBundle.load(photo.asset);
      expect(data.lengthInBytes, greaterThan(1000), reason: photo.asset);
    }
  });

  testWidgets(
    'showcase photo opens a zoomable viewer and closes back to story',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PostPage(index: 0, back: () {})),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PhotoCard).first);
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byTooltip('Close photo'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Close photo'));
      await tester.pumpAndSettle();
      expect(find.byType(InteractiveViewer), findsNothing);
      expect(find.text('Naunsa naman ni atong palibot? 😩'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
