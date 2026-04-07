import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenyusuiView extends StatelessWidget {
  const MenyusuiView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color kMidnightBlue = Color(0xFF0C2D57);
    const Color kRosePink = Color(0xFFFF8E9E);
    const Color kSoftBg = Color(0xFFFBFBFF);

    return Scaffold(
      backgroundColor: kSoftBg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kMidnightBlue.withOpacity(0.05),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kMidnightBlue),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          "Teknik Menyusui",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ILUSTRASI UTAMA ---
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: kMidnightBlue.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/images/menyusui.png",
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.pregnant_woman_rounded, size: 100, color: kRosePink.withOpacity(0.5));
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Posisi Pelekat Sempurna",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kMidnightBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- HEADER SECTION ---
            const Text(
              "Panduan Langkah Demi Langkah",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kMidnightBlue,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),

            // --- LIST PANDUAN ---
            _buildGuideCard(1, "Posisi Nyaman", "Pilih cradle hold, football hold, atau side-lying sesuai kenyamanan Bunda.", kMidnightBlue),
            _buildGuideCard(2, "Pelekatan (Latching)", "Pastikan mulut bayi menempel pada puting dan sebagian besar areola.", kMidnightBlue),
            _buildGuideCard(3, "Gunakan Penopang", "Gunakan bantal menyusui untuk menjaga posisi bayi tetap stabil.", kMidnightBlue),
            _buildGuideCard(4, "Kenali Tanda", "Perhatikan tanda bayi lapar (rooting) dan tanda saat sudah kenyang.", kMidnightBlue),
            _buildGuideCard(5, "Kebersihan", "Pastikan tangan dan area payudara bersih sebelum memulai sesi.", kMidnightBlue),
            _buildGuideCard(6, "Sisi Bergantian", "Lakukan sesi secara bergantian agar produksi ASI tetap seimbang.", kMidnightBlue),
            _buildGuideCard(7, "Sabar & Rileks", "Beri waktu bayi menghisap dan menelan dengan tenang, jangan terburu-buru.", kMidnightBlue),
            _buildGuideCard(8, "Pantau Jadwal", "Catat durasi dan waktu menyusui untuk memantau pola tumbuh kembang.", kMidnightBlue),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(int step, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF8E9E).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$step",
                style: const TextStyle(
                  color: Color(0xFFFF8E9E),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}