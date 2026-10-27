import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Android picker results are global. Remember the destination before leaving
// the app so a recovered showcase photo cannot attach to a private report.
class OwnedPhotoPicker {
  static const ownerKey = 'pendingPhotoOwner';
  static Future<XFile?> recover(
    String owner, {
    Future<LostDataResponse> Function()? retrieve,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(ownerKey) != owner) return null;
    final lost = await (retrieve ?? ImagePicker().retrieveLostData)();
    await prefs.remove(ownerKey);
    return lost.files?.isNotEmpty == true ? lost.files!.first : null;
  }

  static Future<XFile?> pick(String owner, ImageSource source) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(ownerKey, owner)) {
      throw StateError('Could not prepare the photo picker.');
    }
    try {
      return await ImagePicker().pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );
    } finally {
      await prefs.remove(ownerKey);
    }
  }
}
