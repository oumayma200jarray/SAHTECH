import 'dart:io';

import 'package:sahtek/core/api/endpoint.dart';

class AuthService {
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    return await EndPoint.client.post(
      EndPoint.signin,
      body: {'email': email, 'password': password},
      requiresAuth: false, // no token needed for signin
    );
  }

  static Future<Map<String, dynamic>> verifySignIn({
    required String userId,
    required String code,
  }) async {
    return await EndPoint.client.post(
      EndPoint.signinVerify,
      body: {'userId': userId, 'code': code},
      requiresAuth: false, // no token needed yet
    );
  }

  static Future<void> sendOtp({
    required String userId,
    required String email,
    required String type,
  }) async {
    await EndPoint.client.post(
      EndPoint.otpSend,
      body: {'userId': userId, 'email': email, 'type': type},
      requiresAuth: false, // no token needed
    );
  }

  static Future<dynamic> uploadImage({required File file}) async {
    return await EndPoint.client.uploadFile(
      EndPoint.uploadImage,
      file: file,
      fieldName: 'file', // must match FileInterceptor('file') in backend
    );
  }
}
