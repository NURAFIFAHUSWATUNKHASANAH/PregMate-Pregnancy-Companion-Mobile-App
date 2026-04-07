import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';

import 'package:PregMate/config/api_config.dart';

class AuthService {
  final GetStorage _storage = GetStorage();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  /// =========================
  /// LOGIN MANUAL
  /// =========================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['token'] != null) {
        _storage.write('auth_token', body['token']);
        _storage.write('user_id', body['user']['_id']);

        return {
          'success': true,
          'user': body['user'],
          'token': body['token'],
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Login gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// =========================
  /// LOGIN GOOGLE
  /// =========================
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return {
          'success': false,
          'message': 'User membatalkan login',
        };
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return {
          'success': false,
          'message': 'Firebase user tidak ditemukan',
        };
      }

      final firebaseToken = await firebaseUser.getIdToken();

      final response = await http.post(
        Uri.parse(ApiConfig.loginGoogleUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebaseToken': firebaseToken,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ FIX KEY
        _storage.write('auth_token', body['token']);
        _storage.write('user_id', body['user']['_id']);

        return {
          'success': true,
          'user': body['user'],
          'token': body['token'],
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Login Google gagal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Firebase error: $e',
      };
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    // ✅ bersihin semua
    _storage.erase();
  }
}