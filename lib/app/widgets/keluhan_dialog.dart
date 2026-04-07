import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/keluhan/controllers/keluhan_controller.dart';
import 'package:PregMate/app/modules/rekomendasi/controllers/rekomendasi_controller.dart';
import 'package:PregMate/app/widgets/validasi_dialog.dart';

class KeluhanDialog extends StatelessWidget {
  final KeluhanController controller = Get.find<KeluhanController>();

  KeluhanDialog({Key? key, required trimester}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pilih Trimester",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C2D57),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // List Section
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Obx(() {
                  if (controller.keluhanList.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  return Column(
                    children: controller.keluhanList.map((keluhan) {
                      final nama = keluhan["nama"];
                      final deskripsi = keluhan["deskripsi"] ?? "Deskripsi belum tersedia";
                      final isExpanded = controller.selectedKeluhan.value == nama;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isExpanded ? const Color(0xFFF8FAFC) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isExpanded 
                                ? const Color(0xFF0C2D57) 
                                : const Color(0xFFE2E8F0),
                            width: isExpanded ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => controller.toggleKeluhan(nama),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isExpanded 
                                            ? const Color(0xFF0C2D57) 
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.healing_rounded,
                                        size: 20,
                                        color: isExpanded ? Colors.white : const Color(0xFF0C2D57),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        nama,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isExpanded ? FontWeight.bold : FontWeight.w600,
                                          color: const Color(0xFF0C2D57),
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                                if (isExpanded) ...[
                                  const Divider(height: 24, thickness: 1),
                                  Text(
                                    deskripsi,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        controller.pilihKeluhan(nama);
                                        final keluhanId = keluhan["_id"];
                                        final rekomendasiController = Get.put(RekomendasiController());
                                        
                                        rekomendasiController.setKeluhan(keluhanId);
                                        await rekomendasiController.fetchTerapiByKeluhanId(keluhanId);
                                        
                                        Get.back();
                                        Get.dialog(ValidasiDialog());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0C2D57),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        "Pilih",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
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