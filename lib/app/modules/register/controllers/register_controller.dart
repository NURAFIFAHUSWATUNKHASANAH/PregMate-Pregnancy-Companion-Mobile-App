import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class RegisterController extends GetxController {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController husbandNameController = TextEditingController();
  final TextEditingController husbandEmailController = TextEditingController();

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  void register() async {

    final String nama = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    final String namaSuami = husbandNameController.text.trim();
    final String emailSuami = husbandEmailController.text.trim();

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {

      Get.snackbar("Error", "Semua data ibu harus diisi");

      return;
    }

    if (!isValidEmail(email)) {

      Get.snackbar("Error", "Format email tidak valid");

      return;
    }

    try {

      final response = await http.post(

        Uri.parse(ApiConfig.registerUrl),

        headers: {
          "Content-Type": "application/json"
        },

        body: jsonEncode({

          "nama": nama,
          "email": email,
          "password": password,

          "nama_suami": namaSuami,
          "email_suami": emailSuami

        }),

      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {

        var userId = data["user_id"];

        Get.snackbar(
          "Sukses",
          "OTP dikirim ke email Anda",
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