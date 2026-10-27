import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> storePhoto(XFile file, String collection) async {
  final directory = await getApplicationDocumentsDirectory();
  final folder = await Directory(
    '${directory.path}/${collection}_photos',
  ).create(recursive: true);
  final copy = await File(
    file.path,
  ).copy('${folder.path}/${DateTime.now().microsecondsSinceEpoch}.jpg');
  return copy.path;
}

Future<void> deletePhoto(String? reference) async {
  if (reference == null) return;
  try {
    await File(reference).delete();
  } catch (_) {}
}

ImageProvider photoProvider(String reference) => FileImage(File(reference));
