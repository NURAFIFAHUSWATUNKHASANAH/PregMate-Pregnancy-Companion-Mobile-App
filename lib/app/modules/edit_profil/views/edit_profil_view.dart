import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profil_controller.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/config/api_config.dart';
import 'dart:io';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Color(0xFF0C2D57);
    const Color kAccentColor = Color(0xFF4485FD);
    const Color kBgColor = Color(0xFFF8FAFC);

    final profileController = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: kPrimaryColor,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: kBgColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kPrimaryColor, size: 18),
            onPressed: () => Get.back(),
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryColor),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [

                // =========================
                // FOTO (READ ONLY)
                // =========================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Column(
                    children: [

                      Obx(() {
                        final selectedImage = profileController.image.value;
                        final fotoUrl = profileController.foto.value;

                        ImageProvider imageProvider;

                        if (selectedImage != null) {
                          imageProvider = FileImage(selectedImage);
                        } else if (fotoUrl.isNotEmpty) {
                          String fullUrl = fotoUrl.startsWith('http')
                              ? fotoUrl
                              : '${ApiConfig.baseUrl}/$fotoUrl';

                          imageProvider = NetworkImage(fullUrl);
                        } else {
                          imageProvider =
                              const AssetImage('assets/splash1.png');
                        }

                        return CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white,
                          backgroundImage: imageProvider,
                        );
                      }),

                      const SizedBox(height: 12),

                      Text(
                        "Foto Profil",
                        style: TextStyle(
                          color: kPrimaryColor.withOpacity(0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // =========================
                // FORM
                // =========================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildModernTextField(
                        label: "Nama Lengkap",
                        hint: "Masukkan nama Anda",
                        controller: controller.namaC,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 20),
                      _buildModernTextField(
                        label: "Nomor WhatsApp",
                        hint: "08xxxxxxxxxx",
                        controller: controller.phoneC,
                        icon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      Obx(() => _buildModernTextField(
                            label: "Kata Sandi",
                            hint: "Isi jika ingin mengubah sandi",
                            controller: controller.passwordC,
                            icon: Icons.lock_outline_rounded,
                            obscure: controller.isPasswordHidden.value,
                            isOptional: true,
                            suffixIcon: IconButton(
                              onPressed: controller.togglePasswordVisibility,
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: kPrimaryColor.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                          )),

                      const SizedBox(height: 40),

                      // BUTTON
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [kPrimaryColor, Color(0xFF1E4D8C)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: controller.updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          ),
                          child: const Text(
                            "Simpan Perubahan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildModernTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            isOptional ? "$label (opsional)" : label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xFF334155),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Color(0xFF0C2D57)),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}