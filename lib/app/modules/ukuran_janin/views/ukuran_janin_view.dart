import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ukuran_janin_controller.dart';

class UkuranJaninView extends GetView<UkuranJaninController> {
  const UkuranJaninView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C2D57);
    const Color accentColor = Color(0xFF448AFF);
    const Color softBg = Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: softBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          "Ukuran Janin",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Tampilkan indikator loading jika data sedang diproses
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: accentColor));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 100)),

            // 1. Header Ringkasan & Card Utama
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      "USIA KEHAMILAN SAAT INI",
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.5),
                        fontSize: 12,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${controller.mingguUser.value} Minggu",
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Card Visual
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A4D8F), Color(0xFF0C2D57)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -50,
                              top: -50,
                              child: CircleAvatar(
                                radius: 100,
                                backgroundColor: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Seukuran ${controller.buah.value}",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
const SizedBox(height: 24),

Obx(() {
  if (controller.imageUrl.value.isEmpty) {
    return const SizedBox();
  }

  return Container(
    width: 180,
    height: 180,
    margin: const EdgeInsets.only(bottom: 24),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(24),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        controller.imageUrl.value,
        fit: BoxFit.contain,

        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;

          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        },

        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white54,
              size: 60,
            ),
          );
        },
      ),
    ),
  );
}),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    _buildInfoDetail(
      Icons.straighten_rounded,
      "Panjang",
      controller.panjang.value,
    ),
    Container(
      height: 40,
      width: 1,
      color: Colors.white24,
    ),
    _buildInfoDetail(
      Icons.monitor_weight_outlined,
      "Berat",
      controller.berat.value,
    ),
  ],
),
                                  const SizedBox(height: 30),
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          controller.deskripsi.value,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            height: 1.6,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(color: Colors.white12, thickness: 1),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Ukuran di atas adalah estimasi berdasarkan data rata-rata medis, "
                                          "bukan hasil pemeriksaan USG. Setiap janin dapat berkembang berbeda "
                                          "tergantung kondisi ibu dan janin.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 11,
                                            height: 1.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Judul Timeline
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Timeline Pertumbuhan",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Icon(Icons.calendar_view_day_rounded, color: primaryColor.withOpacity(0.3)),
                  ],
                ),
              ),
            ),

            // 3. List Perkembangan Dinamis dari Backend
            controller.perkembanganJaninList.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text("Data timeline belum tersedia"),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = controller.perkembanganJaninList[index];
                          final String week = item["minggu"].toString();
                          
                          bool isSelected = controller.selectedWeek.value == week;
                          bool isCurrent = controller.mingguUser.value.toString() == week;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? accentColor : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? accentColor.withOpacity(0.15) 
                                      : Colors.black.withOpacity(0.03),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              onTap: () => controller.setPerkembangan(item),
                              leading: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: isSelected 
                                      ? const LinearGradient(colors: [accentColor, Color(0xFF1976D2)]) 
                                      : LinearGradient(colors: [Colors.grey[200]!, Colors.grey[100]!]),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    week,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[700],
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    "Minggu $week",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? accentColor : primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (isCurrent) ...[
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "NOW",
                                        style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w900),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "${item["buah"]}",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                              trailing: Icon(
                                isSelected ? Icons.check_circle : Icons.chevron_right_rounded,
                                color: isSelected ? accentColor : Colors.grey[300],
                              ),
                            ),
                          );
                        },
                        childCount: controller.perkembanganJaninList.length,
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  Widget _buildInfoDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          label, 
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500)
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    );
  }
}