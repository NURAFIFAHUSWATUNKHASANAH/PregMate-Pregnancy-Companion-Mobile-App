import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';
import 'package:PregMate/app/data/services/auth_services.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/app/routes/app_pages.dart';

class LoginController extends GetxController {
  var phone = ''.obs; // 🔥 GANTI dari email → phone
  var password = ''.obs;
  var isPasswordHidden = true.obs;

  final AuthService _authService;
  final box = GetStorage();

  LoginController({required AuthService authService})
      : _authService = authService;

  void updatePhone(String value) => phone.value = value;
  void updatePassword(String value) => password.value = value;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// =========================
  /// FORMAT NOMOR (08 → 62)
  /// =========================
  String formatPhone(String phone) {
    if (phone.startsWith("08")) {
      return "62" + phone.substring(1);
    }
    return phone;
  }

  /// =========================
  /// LOGIN MANUAL
  /// =========================
  Future<void> login() async {
    if (phone.value.isEmpty || password.value.isEmpty) {
      Get.snackbar("Error", "Nomor WA dan Password harus diisi!");
      return;
    }

    final String phoneFormatted = formatPhone(phone.value);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneFormatted, // 🔥 KIRIM KE BACKEND
          'password': password.value,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];
        final role = userData['role'];

        /// SIMPAN DATA
        box.write('auth_token', token);
        box.write('user_id', userData['_id']);
        box.write('user_nama', userData['nama']);
        box.write('user_phone', userData['phone']); // 🔥 GANTI email → phone
        box.write('user_role', role);
        box.write('login_method', 'manual');

        if (userData['partner_id'] != null) {
          box.write('partner_id', userData['partner_id']);
        }

        if (userData['foto'] != null) {
          box.write('user_foto', userData['foto']);
        }

        await sendFcmToken(token);

        /// INIT PROFILE
        final profileController = Get.put(ProfileController());

        profileController.userId.value = userData['_id'];
        profileController.namaC.value = userData['nama'];
        profileController.emailC.value = userData['phone']; // 🔥 isi pakai phone
        profileController.foto.value = userData['foto'] ?? '';
        profileController.loginMethod.value = 'manual';

        Get.snackbar("Berhasil", "Selamat datang, ${userData['nama']}!");

        /// LOAD HISTORI
        if (Get.isRegistered<HistoriController>()) {
          Get.find<HistoriController>().loadUserData();
        } else {
          Get.put(HistoriController()).loadUserData();
        }

        /// REDIRECT
        final isValidated = userData['is_validated'] ?? false;

        if (role == "ibu" && !isValidated) {
          Get.offNamed(Routes.VALIDASI_KEHAMILAN);
        } else {
          Get.offNamed(Routes.BOTTOM);
        }
      } else {
        final res = jsonDecode(response.body);
        Get.snackbar(
            "Gagal Login", res['message'] ?? "Nomor atau password salah");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }

  /// =========================
  /// LOGIN GOOGLE
  /// =========================
  Future<void> loginWithGoogle() async {
    final result = await _authService.loginWithGoogle();

    if (result['success']) {
      final userData = result['user'];
      final token = result['token'];

      print("Token JWT: $token");

      /// ✅ SIMPAN KE GETSTORAGE (FIX)
      box.write('auth_token', token);
      box.write('user_id', userData['_id']);
      box.write('user_nama', userData['nama']);
      box.write('user_email', userData['email']);
      box.write('user_foto', userData['foto'] ?? '');
      box.write('login_method', 'google');

      await sendFcmToken(token);

      final profileController = Get.put(ProfileController());
      profileController.namaC.value = userData['nama'] ?? '';
      profileController.emailC.value = userData['email'] ?? '';
      profileController.foto.value = userData['foto'] ?? '';
      profileController.loginMethod.value = 'google';

      /// 🔥 TRIGGER HISTORI (FIX)
      if (Get.isRegistered<HistoriController>()) {
        Get.find<HistoriController>().loadUserData();
      } else {
        Get.put(HistoriController()).loadUserData();
      }

      Get.snackbar("Berhasil", "Login dengan Google berhasil");
      Get.offNamed(Routes.BOTTOM);
    } else {
      Get.snackbar("Gagal", result['message'] ?? "Login Google gagal");
    }
  }

  /// =========================
  /// SEND FCM TOKEN
  /// =========================
  Future<void> sendFcmToken(String jwt) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();

      print("FCM TOKEN: $token");

      if (token == null) return;

      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/save-fcm-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $jwt"
        },
        body: jsonEncode({"token": token}),
      );
    } catch (e) {
      print("Gagal kirim FCM token: $e");
    }
  }
}
