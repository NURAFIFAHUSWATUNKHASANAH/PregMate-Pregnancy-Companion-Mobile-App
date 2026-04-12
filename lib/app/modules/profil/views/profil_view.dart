import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/config/api_config.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 65;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: Color(0xFF0C2D57),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // TAMBAHKAN padding bawah ekstra (misal: 100) supaya tidak tertutup bottom menu
        padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
        child: Column(
          children: [
            // 1. Profile Header Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0C2D57).withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                    child: Obx(() {
                      final selectedImage = controller.image.value;
                      final fotoUrl = controller.foto.value;

                      ImageProvider imageProvider;
                      if (selectedImage != null) {
                        imageProvider = FileImage(selectedImage);
                      } else if (fotoUrl.isNotEmpty) {
                        String fullUrl = fotoUrl.startsWith('http')
                            ? fotoUrl
                            : '${ApiConfig.baseUrl}/$fotoUrl';
                        imageProvider = NetworkImage(fullUrl);
                      } else {
                        imageProvider = const AssetImage('assets/splash1.png');
                      }

                      return GestureDetector(
                        onTap: controller.pickImageFromGallery,
                        child: CircleAvatar(
                          radius: avatarRadius,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage: imageProvider,
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: controller.pickImageFromGallery,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C2D57),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C2D57).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Obx(() => Text(
                  controller.namaC.value,
                  style: const TextStyle(
                    color: Color(0xFF0C2D57),
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                )),
            const Text(
              "Pengguna PregMate",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 40),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pengaturan Akun",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildModernMenu(
              icon: Icons.person_outline_rounded,
              title: "Edit Profil",
              subtitle: "Perbarui informasi data diri Anda",
              onTap: controller.editProfile,
              accentColor: const Color(0xFF0C2D57),
            ),
            _buildModernMenu(
              icon: Icons.info_outline_rounded,
              title: "Tentang Aplikasi",
              subtitle: "Pelajari lebih lanjut tentang PregMate",
              onTap: controller.showAbout,
              accentColor: Colors.blue.shade600,
            ),
            _buildModernMenu(
              icon: Icons.pregnant_woman_rounded,
              title: "Riwayat Kehamilan",
              subtitle: "Lihat data kehamilan",
              onTap: () => Get.toNamed('/riwayat-kehamilan'),
              accentColor: Colors.pink.shade400,
            ),
            _buildModernMenu(
              icon: Icons.logout_rounded,
              title: "Keluar",
              subtitle: "Akhiri sesi login akun ini",
              onTap: () => _showLogoutDialog(),
              accentColor: Colors.red.shade600,
              isLast: true,
            ),

            const SizedBox(height: 40),

            Text(
              "PregMate Mobile v2.1.0",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0C2D57),
      ),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          "Apakah Anda yakin ingin keluar?\nSesi Anda akan berakhir.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      ),
      backgroundColor: Colors.white,
      radius: 20,
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text("Batal", style: TextStyle(color: Color(0xFF64748B))),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          controller.logout();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text("Ya, Keluar",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildModernMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color accentColor,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}