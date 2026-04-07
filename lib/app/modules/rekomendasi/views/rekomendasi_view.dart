import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/kamera/views/kamera_view.dart';
import '../controllers/rekomendasi_controller.dart';
import 'package:PregMate/app/modules/rekomendasi/views/informasi_view.dart';

class RekomendasiDialog extends StatelessWidget {
  const RekomendasiDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RekomendasiController>();
    const Color primaryColor = Color(0xFF0C2D57);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Rencana Terapi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Selesaikan gerakan secara berurutan untuk hasil maksimal.",
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            // Konten List Terapi
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Obx(() {
                  if (controller.terapiList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_empty_rounded, color: Colors.grey[300], size: 48),
                          const SizedBox(height: 12),
                          const Text('Tidak ada terapi yang ditemukan.', 
                            style: TextStyle(color: Color(0xFF94A3B8))),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: controller.terapiList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final terapi = entry.value;
                      final isEnabled = controller.canAccessTerapi(index);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isEnabled ? Colors.white : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isEnabled ? primaryColor.withOpacity(0.2) : Colors.transparent,
                            width: 1,
                          ),
                          boxShadow: isEnabled ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: isEnabled
                                ? () => Get.to(() => KameraView(terapi: terapi, index: index))
                                : () {
                                    Get.snackbar(
                                      "Langkah Terkunci", 
                                      "Selesaikan gerakan ke-${index} terlebih dahulu",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.black87,
                                      colorText: Colors.white,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 12,
                                      icon: const Icon(Icons.lock_outline_rounded, color: Colors.orange),
                                    );
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Progress Number / Lock Icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isEnabled ? primaryColor : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: isEnabled 
                                        ? Text("${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                        : const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          terapi["nama"],
                                          style: TextStyle(
                                            color: isEnabled ? primaryColor : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          terapi["deskripsi"],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isEnabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Action Icon
                                  Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: isEnabled ? primaryColor : Colors.grey[400],
                                    size: 32,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}