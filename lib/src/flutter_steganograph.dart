import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:image/image.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_steganograph/src/binary_util.dart';
import 'package:flutter_steganograph/src/custom_exception.dart';

class Steganograph {
  /// Embeds a secret text inside a cover text using zero-width characters.
  ///
  /// This function converts the secret text into a binary format, where '0' is represented 
  /// by a zero-width space (`\u200B`) and '1' is represented by a zero-width non-joiner (`\u200C`).
  ///
  /// Returns a string with the secret message embedded, invisible to normal readers.
  String embedTextInText({required String coverText, required String secretMessage}) {
    String binaryMessage = BinaryOperator.textToBinary(secretMessage);

    String encodedMessage =
        binaryMessage.replaceAll('0', '\u200B').replaceAll('1', '\u200C');

    return '$coverText\u200D$encodedMessage';
  }

  /// Extracts a text message embedded in a text using zero-width characters.
  ///
  /// This function identifies the zero-width joiner (`\u200D`) used as a delimiter between the cover text
  /// and the embedded secret message.
  ///
  /// Returns the extracted secret message. If no secret message is found, returns a message indicating this.
  String extractTextFromText({required String encodedText}) {
    int delimiterIndex = encodedText.indexOf('\u200D');

    if (delimiterIndex == -1) {
      return "No secret message found!";
    }

    String encodedMessage = encodedText.substring(delimiterIndex + 1);

    String binaryMessage =
        encodedMessage.replaceAll('\u200B', '0').replaceAll('\u200C', '1');

    final secretMessage = BinaryOperator.binaryToText(binaryMessage);
    return secretMessage;
  }

  /// Embeds the given [text] into the [image].
  ///
  /// The [saveImage] parameter is optional. If set to `true`, the image with
  /// embedded text will be downloaded to gallery.
  ///
  /// Returns the modified byte image with the embedded text.
  Uint8List embedText(
      {required Image image, required String text, bool? saveImage}) {
    int x = 0;
    int y = 0;
    int textLength = text.length;
    int bitMask = 0x80;

    for (int i = 0; i < textLength; i++) {
      int charValue = text.codeUnitAt(i);

      for (int j = 0; j < 8; j++) {
        int bit = (charValue & bitMask) >> 7;
        charValue <<= 1;

        if (x >= image.width) {
          x = 0;
          y++;
        }

        _embedBit(image, x, y, bit);
        x++;
      }
    }
    if (saveImage == true) {
      _saveImage(image, "extractedImage");
    }
    return encodePng(image);
  }

  /// Extracts and returns the text of the given [length] of text from the [image].
  ///
  /// Returns the extracted secret text.
  String extractText({required Image image, required int length}) {
    int totalBits = length * 8;
    int bitIndex = 0;
    List<int> chars = List.filled(length, 0);
    int charValue = 0;

    try {
      for (int i = 0; i < totalBits; i++) {
        int x = bitIndex % image.width;
        int y = bitIndex ~/ image.width;

        Color pixel = image.getPixel(x, y);
        int lsb = (pixel.r as int) & 0x01;
        charValue = (charValue << 1) | lsb;

        if ((i + 1) % 8 == 0) {
          chars[bitIndex ~/ 8] = charValue;
          charValue = 0;
        }

        bitIndex++;
      }
    } catch (e, s) {
      throw ExtractException(errorMessage: e.toString(), stackTrace: s);
    }

    return String.fromCharCodes(chars);
  }

  /// Embeds the [secretImage] into the [coverImage].
  ///
  /// The [saveImage] parameter is optional. If set to `true`, the image with
  /// the embedded secret image will be downloaded to gallery.
  ///
  /// Returns the modified cover byte image with the embedded secret image.
  ///
  /// Throws a [GeneralException] if the secret image dimensions exceed the cover image dimensions.
  Uint8List embedImage({
    required Image coverImage,
    required Image secretImage,
    bool? saveImage,
  }) {
    secretImage = _resizeSecretImageIfNecessary(coverImage, secretImage);
    int coverWidth = coverImage.width;
    int coverHeight = coverImage.height;
    int secretWidth = secretImage.width;
    int secretHeight = secretImage.height;

    if (secretWidth > coverWidth || secretHeight > coverHeight) {
      throw GeneralException(
        errorMessage: 'Secret image dimensions exceeds cover image dimensions',
      );
    }

    try {
      for (int y = 0; y < secretHeight; y++) {
        for (int x = 0; x < secretWidth; x++) {
          Color coverPixel = coverImage.getPixel(x, y);
          Color secretPixel = secretImage.getPixel(x, y);

          int secretRed = (secretPixel.r as int) >> 4;
          int secretGreen = (secretPixel.g as int) >> 4;
          int secretBlue = (secretPixel.b as int) >> 4;
          int secretAlpha = (secretPixel.a as int) >> 4;

          int coverRed = ((coverPixel.r as int) & 0xF0) | secretRed;
          int coverGreen = ((coverPixel.g as int) & 0xF0) | secretGreen;
          int coverBlue = ((coverPixel.b as int) & 0xF0) | secretBlue;
          int coverAlpha = ((coverPixel.a as int) & 0xF0) | secretAlpha;

          Color newPixel =
              ColorInt8.rgba(coverRed, coverGreen, coverBlue, coverAlpha);

          coverImage.setPixel(x, y, newPixel);
        }
      }
    } catch (e, s) {
      throw SizeException(errorMessage: e.toString(), stackTrace: s);
    }
    if (saveImage == true) {
      _saveImage(coverImage, "embeddedImage");
    }
    return encodePng(coverImage);
  }

  /// Extracts the secret image from the [embeddedImage] with the given [secretWidth] and [secretHeight].
  ///
  /// The [saveImage] parameter is optional. If set to `true`, the extracted image will be downloaded to gallery.
  ///
  /// Returns the extracted secret byte image.
  Uint8List extractImage({
    required Image embeddedImage,
    required int secretWidth,
    required int secretHeight,
    bool? saveImage,
  }) {
    Image extractedImage = Image(width: secretWidth, height: secretHeight);
    try {
      for (int y = 0; y < secretHeight; y++) {
        for (int x = 0; x < secretWidth; x++) {
          Color embeddedPixel = embeddedImage.getPixel(x, y);

          int extractedRed = ((embeddedPixel.r as int) & 0x0F) << 4;
          int extractedGreen = ((embeddedPixel.g as int) & 0x0F) << 4;
          int extractedBlue = ((embeddedPixel.b as int) & 0x0F) << 4;
          int extractedAlpha = ((embeddedPixel.a as int) & 0x0F) << 4;

          Color extractedPixel = ColorInt8.rgba(
              extractedRed, extractedGreen, extractedBlue, extractedAlpha);

          extractedImage.setPixel(x, y, extractedPixel);
        }
      }
    } catch (e, s) {
      throw ExtractException(errorMessage: e.toString(), stackTrace: s);
    }
    if (saveImage == true) {
      _saveImage(extractedImage, "extractedImage");
    }

    return encodePng(extractedImage);
  }

  void _embedBit(Image image, int x, int y, int bitValue) {
    try {
      Color pixel = image.getPixel(x, y);
      int red = ((pixel.r as int) & 0xFE) | bitValue;
      Color modifiedColor = ColorFloat32.rgb(red, pixel.g, pixel.b);
      image.setPixel(x, y, modifiedColor);
    } catch (e, s) {
      throw EmbedException(errorMessage: e.toString(), stackTrace: s);
    }
  }

  Image _resizeSecretImageIfNecessary(Image coverImage, Image secretImage) {
    int coverCapacity = coverImage.width * coverImage.height;
    int secretSize = secretImage.width * secretImage.height;

    if (secretSize > coverCapacity) {
      double scaleFactor = (coverCapacity / secretSize);
      scaleFactor = sqrt(scaleFactor);
      int newWidth = (secretImage.width * scaleFactor).toInt();
      int newHeight = (secretImage.height * scaleFactor).toInt();
      Image resizedSecretImage =
          copyResize(secretImage, width: newWidth, height: newHeight);
      return resizedSecretImage;
    } else {
      return secretImage;
    }
  }

  Future<void> _saveImage(Image image, String prefix) async {
    try {
      DateTime now = DateTime.now();
      String timestamp = now.toIso8601String().replaceAll(RegExp(r'[:.]'), '');
      final fileName = "$prefix-$timestamp.png";
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      file.writeAsBytesSync(encodePng(image, level: 1));
      await Gal.putImage(file.path);
    } catch (e, s) {
      throw DownloadException(errorMessage: e.toString(), stackTrace: s);
    }
  }
}
