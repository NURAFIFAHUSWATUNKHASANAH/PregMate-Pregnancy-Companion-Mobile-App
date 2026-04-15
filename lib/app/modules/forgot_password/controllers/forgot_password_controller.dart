import 'package:PregMate/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:PregMate/config/api_config.dart';

class ForgotPasswordController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  var isLoading = false.obs;
  var otpRequested = false.obs;
  var hidePassword = true.obs;

  final String baseUrl = ApiConfig.baseUrl;

  Future<void> requestOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      Get.snackbar('Error', 'Nomor WhatsApp harus diisi');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot_password/request_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        otpRequested.value = true;
        Get.snackbar('Sukses', data['message']);
      } else {
        Get.snackbar('Error', data['error'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final phone = phoneController.text.trim();
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (phone.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot_password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          'Sukses',
          data['message'] ?? 'Password berhasil diubah',
        );

        // =========================
        // CLEAR STATE
        // =========================
        phoneController.clear();
        otpController.clear();
        newPasswordController.clear();
        otpRequested.value = false;

        // =========================
        // BACK TO LOGIN (CLEAR STACK)
        // =========================
        Future.delayed(const Duration(milliseconds: 800), () {
          Get.offAllNamed(Routes.LOGIN);
        });
      } else {
        Get.snackbar(
          'Error',
          data['error'] ?? 'Terjadi kesalahan',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Koneksi gagal');
    } finally {
      isLoading.value = false;
    }
  }
}
