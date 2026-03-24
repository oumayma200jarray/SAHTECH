import 'dart:io';
import 'package:sahtek/core/api/endpoint.dart';

class UploadImageService {
  static Future<String> uploadProfileImage({required File file}) async {
    final response = await EndPoint.client.uploadFile(
      EndPoint.uploadImage,
      file: file,
      fieldName: 'file',
    );
    return response['imageUrl'];
  }
}