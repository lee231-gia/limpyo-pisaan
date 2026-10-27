import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:limpyo_pisaan/photo_picker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('recovery only consumes an image for its originating flow', () async {
    SharedPreferences.setMockInitialValues({
      OwnedPhotoPicker.ownerKey: 'showcase',
    });
    var calls = 0;
    Future<LostDataResponse> retrieve() async {
      calls++;
      return LostDataResponse(
        files: [XFile('/private/showcase.jpg')],
        type: RetrieveType.image,
      );
    }

    expect(
      await OwnedPhotoPicker.recover('report', retrieve: retrieve),
      isNull,
    );
    expect(calls, 0);
    final photo = await OwnedPhotoPicker.recover(
      'showcase',
      retrieve: retrieve,
    );
    expect(photo?.path, '/private/showcase.jpg');
    expect(calls, 1);
    expect(
      await OwnedPhotoPicker.recover('showcase', retrieve: retrieve),
      isNull,
    );
    expect(calls, 1);
  });
}
