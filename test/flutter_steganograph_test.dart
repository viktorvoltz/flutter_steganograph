import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as dImage;
import 'dart:math';

import 'package:flutter_steganograph/src/flutter_steganograph.dart';

void main() {
  group('Steganograph', () {
    late Steganograph steganograph;
    late dImage.Image coverImage;
    late dImage.Image secretImage;

    setUp(() {
      steganograph = Steganograph();

      coverImage = dImage.Image(width: 100, height: 100, numChannels: 4);
      secretImage = dImage.Image(width: 100, height: 100, numChannels: 4);

      fillImage(coverImage, getRandomColor());
      fillImage(secretImage, getRandomColor());
    });

    test('embedText and extractText', () {
      const text = "viktorvoltz!";
      final imageWithText =
          steganograph.embedText(image: coverImage, text: text);
      final copyImageWithText = dImage.decodePng(imageWithText);

      final extractedText =
          steganograph.extractText(image: copyImageWithText!, length: text.length);

      expect(extractedText, equals(text));
    });

    test('embed and extract image', () {
      for (int y = 0; y < coverImage.height; y++) {
        for (int x = 0; x < coverImage.width; x++) {
          secretImage.setPixel(x, y, dImage.ColorInt8.rgba(0, 255, 0, 255));
          secretImage.setPixel(x, y, dImage.ColorInt8.rgba(0, 0, 255, 255));
          secretImage.setPixel(x, y, dImage.ColorInt8.rgba(0, 0, 0, 255));
        }
      }
      Uint8List embeddedImage = steganograph.embedImage(
        coverImage: coverImage,
        secretImage: secretImage,
      );

      final copyEmbeddedImage = dImage.decodePng(embeddedImage);
      
      Uint8List extractedImage = steganograph.extractImage(
        embeddedImage: copyEmbeddedImage!,
        secretWidth: secretImage.width,
        secretHeight: secretImage.height,
      );

      final copyExtractedImage = dImage.decodePng(extractedImage);

      for (int y = 0; y < secretImage.height; y++) {
        for (int x = 0; x < secretImage.width; x++) {
          dImage.Color extractedPixel = copyExtractedImage!.getPixel(x, y);
          dImage.Color originalPixel = secretImage.getPixel(x, y);

          expect(extractedPixel.r, originalPixel.r);
          expect(extractedPixel.g, originalPixel.g);
          expect(extractedPixel.b, originalPixel.b);
          expect(extractedPixel.a, originalPixel.a);
        }
      }
    });
  });
}

void fillImage(dImage.Image image, dImage.Color color) {
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      image.setPixel(x, y, color);
    }
  }
}

dImage.Color getRandomColor() {
  final random = Random();
  return dImage.ColorInt8.rgba(
      random.nextInt(256), random.nextInt(256), random.nextInt(256), 255);
}
