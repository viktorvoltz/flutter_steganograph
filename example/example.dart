import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_steganograph/flutter_steganograph.dart';
// ignore: library_prefixes
import 'package:image/image.dart' as dImage;

void main() async {
  final steganograph = Steganograph();
  String path1 = "example/assets/plant1.png";
  String path2 = "example/assets/plant2.png";

  //Embed text in an image
  final coverImageText = dImage.decodePng(File(path1).readAsBytesSync())!;
  String textInput = "my_secret_plant_name";
  final embeddedTextImage = steganograph.embedText(image: coverImageText, text: textInput);
  Image.memory(embeddedTextImage); // convert bytes to material image to display

  //Extract text string from encoded image
  final imageToExtractFrom =  dImage.decodePng(embeddedTextImage)!;
  steganograph.extractText(image: imageToExtractFrom, length: textInput.length);

  //Embed plant1 image inside plant2 image
  final coverImage = dImage.decodePng(File(path1).readAsBytesSync())!;
  final secretImage = dImage.decodeImage(File(path2).readAsBytesSync())!;
  final embeddedImageCover = steganograph.embedImage(coverImage: coverImage, secretImage: secretImage);
  Image.memory(embeddedImageCover); // convert bytes to material image to display

  //Extract plant1 image from encoded image 
  final coverToExtractFrom =  dImage.decodePng(embeddedImageCover)!;
  final extractedSecretImage = steganograph.extractImage(embeddedImage: coverToExtractFrom, secretWidth: secretImage.width, secretHeight: secretImage.height);
  Image.memory(extractedSecretImage); // convert bytes to material image to display

}
