import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:limpyo_pisaan/photo_storage_web.dart';
import 'package:limpyo_pisaan/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'browser photos remain attached after state reload without a blob URL',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final reference = await storePhoto(
        XFile.fromData(utf8.encode('image bytes')),
        'showcase',
      );
      expect(reference, startsWith('data:image/'));
      final state = AppState(prefs);
      await state.addShowcase('Bottles', 'Separated for reuse.', reference);
      final restored = AppState(prefs).showcases.single;
      expect(restored.photo, reference);
      expect(
        utf8.decode(base64Decode(restored.photo!.split(',').last)),
        'image bytes',
      );
    },
  );
}
