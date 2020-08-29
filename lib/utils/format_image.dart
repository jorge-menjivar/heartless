import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image/image.dart' as image_package;
import 'package:path_provider/path_provider.dart';

Future<File> formatFile({PickedFile image}) async {
  var cropWidth = 840;
  var cropHeight = 1120;

  var bytes = await FlutterImageCompress.compressWithFile(
    image.path,
    autoCorrectionAngle: true,
  );

  // Decoding Image before resizing
  var decodedImage = image_package.decodeImage(bytes);

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
        break;
      }
    }
  }

  // Return null if the image is too small
  if (editedImage.width < cropWidth) {
    return null;
  }

  var pointX = (editedImage.width - cropWidth) ~/ 2;
  var pointY = (editedImage.height - cropHeight) ~/ 2; // Equivalent to 0
  image_package.Image croppedImage;
  try {
    croppedImage = cropImage(
      editedImage,
      pointX,
      pointY,
      cropWidth,
      cropHeight,
    );
  } catch (e) {
    print('ERROR ON PICTURE FORMATTING:\n' + e.toString());
  }
  var appDocDirectory = await getApplicationDocumentsDirectory();
  var finalImage = File('${appDocDirectory.path}/finalImage.jpg');

  var imageEncoded = image_package.encodeJpg(croppedImage, quality: 40);

  await finalImage.writeAsBytes(imageEncoded);
  return finalImage;
}

/// Function based on the copyCrop function of the image package.
image_package.Image cropImage(image_package.Image src, int x, int y, int w, int h) {
  // Channels used by this Image file. For example (R, G, B)
  var channels = src.channels;

  // EXIF data decoded from Image file
  var exif = src.exif;

  // ICC color profile read from Image file
  var iccp = src.iccProfile;

  // Creating a new Image with the following properties. No pixel data yet.
  var dst = image_package.Image(w, h, channels: channels, exif: exif, iccp: iccp);

  // Copying the pixels to the new Image file
  try {
    for (var yi = 0, sy = y; yi < h; ++yi, ++sy) {
      for (var xi = 0, sx = x; xi < w; ++xi, ++sx) {
        dst.setPixel(xi, yi, src.getPixel(sx, sy));
      }
    }
  } catch (e) {
    print('ERROR ON PICTURE CROPPING:\n' + e.toString());
  }

  return dst;
}
