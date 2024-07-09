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
and embeds (conceal 🕵️‍♂️) it inside of a `cover image` with minimum possible alteration to the original 
`cover image`.

## Installation 🛸

Add `steganograph` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_steganograph: ^0.0.1
```

## Usage 📦

Importing the Package

```dart
import 'package:flutter_steganograph/flutter_steganograph.dart';
```

## Embed a text into an image

```dart
//Embeds a text string into an image.
//Optional `saveImage` argument to download embedded image to gallery.
final steganography = Steganography();
final embeddedTextImage = steganography.embedText(
    image: Image.asset('/my_picture.png'), 
    text: 'super secret text',
    saveImage: true
    );

```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
