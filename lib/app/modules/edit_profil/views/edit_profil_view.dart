import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profil_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C2D57);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna background modern
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Section Judul Form
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Perbarui Informasi Profil Anda",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Form Fields
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
  controller: controller.phoneC, // ✅ sudah diganti ke phoneC
  icon: Icons.phone_android_rounded,
  keyboardType: TextInputType.phone,
),
                const SizedBox(height: 20),
                _buildModernTextField(
                  label: "Kata Sandi",
                  hint: "Isi jika ingin mengubah sandi",
                  controller: controller.passwordC,
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  isOptional: true,
                ),
                const SizedBox(height: 50),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (isOptional)
                const Text(
                  " (opsional)",
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                ),
            ],
          ),
        ),
        // Text Field Card Modern
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF0C2D57), size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}