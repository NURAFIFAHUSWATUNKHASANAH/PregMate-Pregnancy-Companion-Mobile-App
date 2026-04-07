import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:PregMate/config/api_config.dart';

class ProfileController extends GetxController {

  final box = GetStorage(); // ✅ FIX

  /// ===== STATE USER =====
  var userId = "".obs;
  var namaC = "".obs;
  var emailC = "".obs;
  var loginMethod = "".obs;
  var foto = "".obs;
  var image = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();
  var isPicking = false.obs;

  /// =============================
  /// INIT
  /// =============================
  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// =============================
  /// LOAD USER DATA (SUPER CEPAT)
  /// =============================
  Future<void> loadUserData() async {

    userId.value = box.read('user_id') ?? '';
    loginMethod.value = box.read('login_method') ?? '';

    // ✅ LANGSUNG TAMPIL TANPA NUNGGU API
    namaC.value = box.read('user_nama') ?? '';
    emailC.value = box.read('user_email') ?? '';
    foto.value = box.read('user_foto') ?? '';

    image.value = null;

    print("LOAD PROFILE:");
    print("Nama: ${namaC.value}");
    print("Email: ${emailC.value}");

    /// optional: refresh dari server
    if (userId.value.isNotEmpty) {
      fetchUserProfile();
    }
  }

  /// =============================
  /// GET TOKEN
  /// =============================
  String? getToken() {
    return box.read('auth_token');
  }

  /// =============================
  /// FETCH PROFILE (SYNC DENGAN SERVER)
  /// =============================
  Future<void> fetchUserProfile() async {

    if (userId.value.isEmpty) return;

    try {

      final token = getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/${userId.value}'),
        headers: {
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        namaC.value = data['nama'] ?? '';
        emailC.value = data['email'] ?? '';
        foto.value = data['foto'] ?? '';

        /// ✅ UPDATE STORAGE BIAR SINKRON
        box.write('user_nama', namaC.value);
        box.write('user_email', emailC.value);
        box.write('user_foto', foto.value);

      } else {

        safeSnackbar("Error", "Gagal mengambil profil");

      }

    } catch (e) {

      safeSnackbar("Error", "Terjadi kesalahan");

    }

  }

  /// =============================
  /// PICK IMAGE
  /// =============================
  Future<void> pickImageFromGallery() async {

    if (isPicking.value) return;

    isPicking.value = true;

    try {

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile != null) {

        File file = File(pickedFile.path);

        image.value = file;

        await uploadProfileImage(file);

      }

    } catch (e) {

      safeSnackbar("Error", "Gagal memilih gambar");

    } finally {

      isPicking.value = false;

    }

  }
  /// =============================
  /// UPLOAD PROFILE IMAGE
  /// =============================
  Future<void> uploadProfileImage(File file) async {

    try {

      final token = getToken();
      if (token == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload_profile_picture/${userId.value}'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {

        await fetchUserProfile();

        safeSnackbar("Berhasil", "Foto profil berhasil diperbarui");

      } else {

        safeSnackbar("Error", "Upload gagal");

      }

    } catch (e) {

      safeSnackbar("Error", "Terjadi kesalahan upload");

    }

  }

  /// =============================
  /// LOGOUT (FIX TOTAL)
  /// =============================
  Future<void> logout() async {

    userId.value = '';
    namaC.value = '';
    emailC.value = '';
    foto.value = '';
    image.value = null;

    /// ✅ bersihin semua storage
    box.erase();

    /// hapus controller
    // Get.deleteAll();

    Get.offAllNamed('/login');
  }

  /// =============================
  /// UTIL
  /// =============================
  void safeSnackbar(String title, String message) {
    if (Get.context != null) {
      Get.snackbar(title, message);
    }
  }

  void editProfile() => Get.toNamed('/edit-profil');
  void showAbout() => Get.toNamed('/tentang');
}