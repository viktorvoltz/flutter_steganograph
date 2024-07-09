import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';
import 'dart:math';

import '../lib/src/flutter_steganograph.dart';

void main() {
  group('Steganograph', () {
    late Steganograph steganograph;
    late Image coverImage;
    late Image secretImage;

    setUp(() {
      steganograph = Steganograph();
      
      coverImage = Image(width: 100, height: 100, numChannels: 4);
      secretImage = Image(width: 100, height: 100, numChannels: 4);

      fillImage(coverImage, getRandomColor());
      fillImage(secretImage, getRandomColor());
    });

    test('embedText and extractText', () {
      const text = "viktorvoltz!";
      final imageWithText = steganograph.embedText(coverImage, text);
      final extractedText = steganograph.extractText(imageWithText, text.length);

      expect(extractedText, equals(text));
    });

    test('embed and extract image', () {
    for (int y = 0; y < coverImage.height; y++) {
      for (int x = 0; x < coverImage.width; x++) {
        secretImage.setPixel(x, y, ColorInt8.rgba(0, 255, 0, 255));
        secretImage.setPixel(x, y, ColorInt8.rgba(0, 0, 255, 255));
        secretImage.setPixel(x, y, ColorInt8.rgba(0, 0, 0, 255));
      }
    }
    Image embeddedImage = steganograph.embedImage(coverImage, secretImage);
    Image extractedImage = steganograph.extractImage(embeddedImage, secretImage.width, secretImage.height);

    for (int y = 0; y < secretImage.height; y++) {
      for (int x = 0; x < secretImage.width; x++) {
        Color extractedPixel = extractedImage.getPixel(x, y);
        Color originalPixel = secretImage.getPixel(x, y);

        expect(extractedPixel.r, originalPixel.r);
        expect(extractedPixel.g, originalPixel.g);
        expect(extractedPixel.b, originalPixel.b);
        expect(extractedPixel.a, originalPixel.a);
      }
    }
  });

  });
}

void fillImage(Image image, Color color) {
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      image.setPixel(x, y, color);
    }
  }
}

Color getRandomColor() {
  final random = Random();
  return ColorInt8.rgba(random.nextInt(256), random.nextInt(256), random.nextInt(256), 255);
}
