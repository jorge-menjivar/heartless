import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as image_package;
import 'package:path_provider/path_provider.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> formatFile({PickedFile image}) async {
  var cropWidth = 840;
  var cropHeight = 1120;

  // Decoding Image before resizing
  var decodedImage = image_package.decodeImage(await image.readAsBytes());

  // Return null if the image is too small
  if (decodedImage.height < cropHeight) {
    return null;
  }

  // Making a copy of the copy and cropping and resizing
  var editedImage = image_package.copyResize(decodedImage, height: cropHeight);

  // Resizing the image if aspect ratio is not perfect
  if (editedImage.width < cropWidth) {
    for (int i = 0; i < 4; i++) {
      editedImage = image_package.copyResize(decodedImage, height: (cropHeight * ((i * .1) + 1)).toInt());
      if (editedImage.width >= cropWidth) {
        i += 100;
      }
    }
  }

  // Return null if the image is too small
  if (editedImage.width < cropWidth) {
    return null;
  }

  var pointX = (editedImage.width - cropWidth) ~/ 2;
  var pointY = (editedImage.height - cropHeight) ~/ 2; // Equivalent to 0

  var editedImage2 = image_package.copyCrop(
    editedImage,
    pointX,
    pointY,
    cropWidth,
    cropHeight,
  );

  var appDocDirectory = await getApplicationDocumentsDirectory();
  var croppedResizedImage = File('${appDocDirectory.path}/croppedResizedImage.jpg');
  croppedResizedImage.writeAsBytesSync(image_package.encodeJpg(editedImage2));

  // Compressing the resized file
  var compressedCroppedResizedFile = await FlutterImageCompress.compressAndGetFile(
    '${appDocDirectory.path}/croppedResizedImage.jpg',
    '${appDocDirectory.path}/compressedCroppedResizedImage.jpg',
    quality: 30,
  );

  return compressedCroppedResizedFile;
}
