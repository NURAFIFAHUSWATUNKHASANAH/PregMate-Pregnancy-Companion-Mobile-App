import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/rekomendasi/controllers/rekomendasi_controller.dart';
import 'package:PregMate/app/modules/rekomendasi/views/informasi_view.dart';
import '../controllers/terapi_controller.dart';
import 'package:PregMate/app/widgets/validasi_dialog.dart';

class TerapiView extends StatelessWidget {
  final TerapiController controller = Get.put(TerapiController());
  final RekomendasiController rekomendasiController = Get.put(RekomendasiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF), // Konsisten dengan HomeView
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0C2D57), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Program Terapi",
          style: TextStyle(color: Color(0xFF0C2D57), fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pilih Gerakan Hari Ini",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  "Lakukan gerakan secara perlahan dan konsisten.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Obx(() {
              if (controller.terapiList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0C2D57)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.terapiList.length,
                itemBuilder: (context, index) {
                  final terapi = controller.terapiList[index];
                  if (terapi == null) return const SizedBox.shrink();

                  return Obx(() {
                    final bool isSelected = controller.selectedIndex.value == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? const Color(0xFF3B82F6).withOpacity(0.1) 
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            controller.selectTerapi(index);
                            _showValidationFlow(terapi, index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Thumbnail Image
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: const Color(0xFFF1F5F9),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      terapi.gambar ?? "",
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.fitness_center_rounded, color: Color(0xFF94A3B8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        terapi.nama ?? "Gerakan Terapi",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        terapi.deskripsi ?? "Tidak ada deskripsi",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Action Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF3B82F6).withOpacity(0.1) : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showValidationFlow(dynamic terapi, int index) {
    Get.dialog(
      ValidasiDialog(
        onValid: () {
          Get.back(); // Tutup ValidasiDialog
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.dialog(InformasiDialog(terapi: terapi.toJson(), index: index));
          });
        },
      ),
    );
  }
}