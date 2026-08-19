import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({bool useCamera = true}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }
}
