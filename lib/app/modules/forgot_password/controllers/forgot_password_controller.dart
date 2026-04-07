import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:PregMate/config/api_config.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  var isLoading = false.obs;
  var otpRequested = false.obs;

  // Base URL diakses dari ApiConfig
  final String baseUrl = ApiConfig.baseUrl;

  Future<void> requestOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Error', 'Email harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot_password/request_otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        otpRequested.value = true;
        Get.snackbar('Sukses', data['message']);
      } else {
        Get.snackbar('Error', data['error'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan jaringan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot_password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('Sukses', data['message']);
        // Bersihkan form
        emailController.clear();
        otpController.clear();
        newPasswordController.clear();
        otpRequested.value = false;
      } else {
        Get.snackbar('Error', data['error'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan jaringan');
    } finally {
      isLoading.value = false;
    }
  }
}
