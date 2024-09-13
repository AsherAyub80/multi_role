import 'dart:io';
import 'package:image/image.dart' as img;

Future<File> applyFilter(File imageFile, String filterType) async {
  // Load image from file
  final image = img.decodeImage(imageFile.readAsBytesSync());

  img.Image? editedImage;

  switch (filterType) {
    case 'original':
      editedImage = (image!);
      break;
    case 'grayscale':
      editedImage = img.grayscale(image!);
      break;

    case 'invert':
      editedImage = img.invert(image!);
      break;
    case 'sepia':
      editedImage = img.sepia(image!);
      break;
    case 'brightness':
      editedImage =
          img.adjustColor(image!, brightness: 1.5); // Increase brightness
      break;
    case 'contrast':
      editedImage = img.adjustColor(image!, contrast: 1.5); // Increase contrast
      break;
    case 'saturation':
      editedImage =
          img.adjustColor(image!, saturation: 2.0); // Increase saturation
      break;
    case 'monochrome':
      editedImage = img.monochrome(
        image!,
      ); // Increase saturation
      break;
    case 'sketch':
      editedImage = img.sketch(
        image!,
      ); // Increase saturation
      break;
    default:
      editedImage = image;
  }

  // Save edited image to file
  final editedFile = File('${imageFile.path}_edited_$filterType.jpg')
    ..writeAsBytesSync(img.encodeJpg(editedImage!));

  return editedFile;
}
