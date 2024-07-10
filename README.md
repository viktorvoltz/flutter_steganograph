<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Flutter Steganograph

***
Flutter Steganograph is a digital image encoding package. it simply takes a message (text or image)
and embeds (conceals 🕵️‍♂️) it inside of a `cover image` with minimum possible alteration to the original `cover image`.

## Installation 🛸

Add `flutter_steganograph` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_steganograph: ^0.0.1
```

## Usage 📦

Importing the Package

```dart
import 'package:flutter_steganograph/flutter_steganograph.dart';
```

## Embed a text into an image 🔩

```dart
//Embeds a text string into an image.
//Optional `saveImage` argument to download embedded image to gallery.
//Returns the encoded bytes -> `Uint8List`.
import 'package:image/image.dart' as dImage;
import 'package:flutter_steganograph/src/flutter_steganograph.dart';

final steganograph = Steganograph();
final coverImage = dImage.decodePng(File('/cover_image.png').readAsBytesSync())!;

final embeddedTextImage = steganograph.embedText(
    image: coverImage, 
    text: 'super secret text',
    saveImage: true
    );
// to covert to material image
Image.memory(embeddedTextImage);
```

## Extract a secret text from the encoded image 🔬

```dart
//Extracts a secret text string from an encoded image.
//Returns the extracted secret String
import 'package:image/image.dart' as dImage;
import 'package:flutter_steganograph/src/flutter_steganograph.dart';

final steganograph = Steganograph();
final encodedImage = dImage.decodePng(File('/encoded_image.png').readAsBytesSync())!;
int secretLength = secretText.length;

String secretText = steganograph.extractText(
    image: encodedImage, 
    length: secretLength,
    );

```

## Embed a secret Image inside a cover image 🖼️

```dart
//Embed/encode a secret image inside a cover image.
//secret image dimensions are smaller than cover image dimensions.
//Returns the embedded bytes -> `Uint8List` of encoded image.
import 'package:image/image.dart' as dImage;
import 'package:flutter_steganograph/src/flutter_steganograph.dart';

final steganograph = Steganograph();
final coverImage = dImage.decodePng(File('/cover_image.png').readAsBytesSync())!;
final secretImage = dImage.decodePng(File('/secret_image.png').readAsBytesSync())!;

Uint8List embeddedImage = steganograph.embedImage(
        coverImage: coverImage,
        secretImage: secretImage,
      );
//to covert to material image
Image.memory(embeddedImage);
```

## Extract secret Image from an encoded image 🧮

```dart
//decode a secret image from the encoded image.
//Returns the embedded bytes -> `Uint8List` of secret image.
import 'package:image/image.dart' as dImage;
import 'package:flutter_steganograph/src/flutter_steganograph.dart';

final steganograph = Steganograph();
final encodedImage = dImage.decodePng(File('/encodedImage_image.png').readAsBytesSync())!;
int secretImageHeight;
int secretImageWith;

Uint8List extractedImage = steganograph.extractImage(
        embeddedImage: encodedImage!,
        secretWidth: secretImageHeight,
        secretHeight: secretImageHeight,
      );
//to covert to material image
Image.memory(extractedImage);
```


## Coming soon
encryption 🔒 of secret text and image

## Contribution
Feel free to open pull requests that improve the quality of images or performance of the library.
Any bugs should be submitted to Issues
