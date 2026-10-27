import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Store image bytes with the local entry instead of an ephemeral blob URL.
Future<String> storePhoto(XFile file, String collection) async =>
    'data:image/jpeg;base64,${base64Encode(await file.readAsBytes())}';

Future<void> deletePhoto(String? reference) async {}

ImageProvider photoProvider(String reference) =>
    MemoryImage(base64Decode(reference.substring(reference.indexOf(',') + 1)));
