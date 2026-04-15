import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class RegisterController extends GetxController {
  var isPasswordHidden = true.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController husbandNameController = TextEditingController();
  final TextEditingController husbandPhoneController = TextEditingController();

  // =========================
  // VALIDASI NOMOR WA (08...)
  // =========================
  bool isValidPhone(String phone) {
    return phone.startsWith("08") && phone.length >= 10;
  }

  // =========================
  // KONVERSI 08 -> 62
  // =========================
  String formatPhone(String phone) {
    if (phone.startsWith("08")) {
      return "62" + phone.substring(1);
    }
    return phone;
  }

  // =========================
  // REGISTER
  // =========================
  void register() async {

    final String nama = nameController.text.trim();
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();

    final String namaSuami = husbandNameController.text.trim();
    final String phoneSuami = husbandPhoneController.text.trim();

    // =========================
    // VALIDASI INPUT
    // =========================
    if (nama.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Semua data ibu harus diisi");
      return;
    }

    if (!isValidPhone(phone)) {
      Get.snackbar("Error", "Nomor WA harus diawali 08 dan valid");
      return;
    }

    if (phoneSuami.isNotEmpty && !isValidPhone(phoneSuami)) {
      Get.snackbar("Error", "Nomor WA suami tidak valid");
      return;
    }

    // =========================
    // FORMAT NOMOR KE 62
    // =========================
    final String phoneFormatted = formatPhone(phone);
    final String phoneSuamiFormatted =
        phoneSuami.isNotEmpty ? formatPhone(phoneSuami) : "";

    try {

      final response = await http.post(
        Uri.parse(ApiConfig.registerUrl),
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "nama": nama,
          "phone": phoneFormatted,
          "password": password,
          "nama_suami": namaSuami,
          "phone_suami": phoneSuamiFormatted
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {

        var userId = data["user_id"];

        Get.snackbar(
          "Sukses",
          "OTP dikirim ke WhatsApp Anda",
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.toNamed(
          "/verify-otp",
          arguments: {"user_id": userId},
        );

      } else {

        Get.snackbar(
          "Error",
          data["message"] ?? "Registrasi gagal"
        );

      }

    } catch (e) {

      Get.snackbar(
        "Error",
        "Koneksi gagal: $e"
      );
    }
  }
}