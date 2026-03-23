import 'package:google_sign_in/google_sign_in.dart';
import 'package:sahtek/core/api/endpoint.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;

      final GoogleSignInAuthentication auth = await account.authentication;

      final response = await EndPoint.client.post(
        EndPoint.googleMobileCallback,
        body: {
          'idToken': auth.idToken,
        },
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}