import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime_type/mime_type.dart';

Future<void> uploadFileToS3({File file, String url}) async {
  final parsedMimeType = mime(file.path);

  final body = await file.readAsBytes();
  await http.put(
    url,
    body: body,
    headers: {
      'Content-Type': parsedMimeType,
    },
  );
}
