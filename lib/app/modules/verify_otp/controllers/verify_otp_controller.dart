import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class VerifyOtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  String? userId;
  var isLoading = false.obs; // observable for loading state

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    userId = args != null ? args["user_id"]?.toString() : null;

    if (userId == null || userId!.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "User ID tidak ditemukan, silakan daftar ulang",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed("/register");
      });
    }
  }

  void verifyOtp() async {
    final String otp = otpController.text.trim();

    if (otp.isEmpty) {
      Get.snackbar("Error", "Kode OTP harus diisi",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    if (userId == null || userId!.trim().isEmpty) {
      Get.snackbar("Error", "User ID tidak tersedia",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtpUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "otp": otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Verifikasi berhasil",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue[900],
            colorText: Colors.white);
        Get.offAllNamed("/login");
      } else {
        Get.snackbar("Gagal", data["message"] ?? "Verifikasi gagal",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan koneksi: $e",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
