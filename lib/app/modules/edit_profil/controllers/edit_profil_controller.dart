import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/app/routes/app_pages.dart';
import 'package:PregMate/config/api_config.dart';

class EditProfileController extends GetxController {

  final box = GetStorage();

  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  final currentNama = ''.obs;
  final currentEmail = ''.obs;
  final isLoading = false.obs;

  String? userId;
  bool isGoogleLogin = false;

  @override
  void onInit() {
    super.onInit();
    fetchUserIdAndData();
  }

  String? get token => box.read("auth_token");

  void fetchUserIdAndData() async {

    final googleEmail = box.read('googleEmail');

    if (googleEmail != null && googleEmail.isNotEmpty) {

      isGoogleLogin = true;

      currentNama.value = box.read('googleName') ?? '';
      currentEmail.value = googleEmail;

      namaC.text = currentNama.value;
      emailC.text = currentEmail.value;

    } else {

      userId = box.read('user_id');

      if (userId == null) {
        Get.snackbar("Error", "User ID tidak ditemukan");
        return;
      }

      await fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    isLoading.value = true;

    try {

      final tokenValue = token;

      if (tokenValue == null || tokenValue.isEmpty) {
        Get.snackbar("Error", "Token tidak ditemukan");
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.userProfileUrl(userId ?? '')),
        headers: {
          'Authorization': 'Bearer $tokenValue',
        },
      );

      if (response.statusCode == 200) {

        final data = json.decode(response.body);

        currentNama.value = data['nama'] ?? '';
        currentEmail.value = data['email'] ?? '';

        namaC.text = currentNama.value;
        emailC.text = currentEmail.value;

      } else {

        Get.snackbar("Gagal", "Tidak dapat mengambil data pengguna");
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfile() async {

    String newNama = namaC.text.trim();
    String newEmail = emailC.text.trim();
    String newPassword = passwordC.text.trim();

    Map<String, String> dataToUpdate = {};

    if (newNama.isNotEmpty && newNama != currentNama.value) {
      dataToUpdate['nama'] = newNama;
    }

    if (newEmail.isNotEmpty && newEmail != currentEmail.value) {
      dataToUpdate['email'] = newEmail;
    }

    if (!isGoogleLogin && newPassword.isNotEmpty) {
      dataToUpdate['password'] = newPassword;
    }

    if (dataToUpdate.isEmpty) {
      Get.snackbar("Info", "Tidak ada perubahan yang disimpan.");
      return;
    }

    try {

      final tokenValue = token;

      if (tokenValue == null || tokenValue.isEmpty) {
        Get.snackbar("Error", "Token tidak ditemukan");
        return;
      }

      final userIdToUse = isGoogleLogin ? box.read('_id') : userId;

      if (userIdToUse == null) {
        Get.snackbar("Error", "User ID tidak ditemukan");
        return;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.updateUserUrl(userIdToUse)),
        headers: {
          'Authorization': 'Bearer $tokenValue',
          'Content-Type': 'application/json',
        },
        body: json.encode(dataToUpdate),
      );

      if (response.statusCode == 200) {

        final profileController = Get.find<ProfileController>();
        await profileController.fetchUserProfile();

        if (dataToUpdate.containsKey('nama')) {
          currentNama.value = newNama;
          box.write(isGoogleLogin ? 'googleName' : 'user_nama', newNama);
        }

        if (dataToUpdate.containsKey('email')) {
          currentEmail.value = newEmail;
          box.write(isGoogleLogin ? 'googleEmail' : 'user_email', newEmail);
        }

        passwordC.clear();

        Get.snackbar("Sukses", "Profil berhasil diperbarui.");
        Get.offAllNamed(Routes.BOTTOM, arguments: 3);

      } else {

        print(response.body);

        Get.snackbar("Gagal", "Gagal update profil (${response.statusCode})");
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}