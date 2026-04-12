import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_kehamilan_controller.dart';

class RiwayatKehamilanView extends GetView<RiwayatKehamilanController> {
  const RiwayatKehamilanView({super.key});

  // Konstanta Warna Sesuai Request
  static const Color kMidnightBlue = Color(0xFF0C2D57);
  static const Color kRosePink = Color(0xFFFF8E9E);
  static const Color kBackground = Color(0xFFF8F9FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Riwayat Kehamilan",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kMidnightBlue, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kRosePink),
          );
        }

        if (controller.listKehamilan.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories_outlined, size: 80, color: kMidnightBlue.withOpacity(0.2)),
                const SizedBox(height: 16),
                const Text(
                  "Belum ada riwayat kehamilan",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: controller.listKehamilan.length,
          itemBuilder: (context, index) {
            final item = controller.listKehamilan[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kMidnightBlue.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  onExpansionChanged: (isOpen) {
                    if (isOpen) controller.fetchHistoriByKehamilan(item["id"]);
                  },
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kRosePink.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pregnant_woman, color: kRosePink),
                  ),
                  title: Text(
                    "Kehamilan ke-${item["kehamilan_ke"]}",
                    style: const TextStyle(
                      color: kMidnightBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    "HPL: ${item["hpl"]}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  children: [
                    const Divider(height: 1, thickness: 1),
                    const SizedBox(height: 16),
                    
                    // Detail Section
                    _buildInfoRow("Status Kehamilan", item["status"], isStatus: true),
                    
                    const SizedBox(height: 24),
                    
                    // Histori Senam Header
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                            color: kRosePink,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Histori Latihan Senam",
                          style: TextStyle(
                            color: kMidnightBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Obx(() {
                      if (controller.historiList.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Belum ada catatan aktivitas",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.historiList.map((h) {
                          return _buildHistoriCard(h);
                        }).toList(),
                      );
                    })
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        Container(
          padding: isStatus ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) : null,
          decoration: isStatus ? BoxDecoration(
            color: kMidnightBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ) : null,
          child: Text(
            value,
            style: const TextStyle(
              color: kMidnightBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoriCard(Map<String, dynamic> h) {
    double accuracy = (h["accuracy"] as num).toDouble();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fitness_center, size: 18, color: kMidnightBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              h["label"] ?? "-",
              style: const TextStyle(
                color: kMidnightBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${accuracy.toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: kRosePink,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Text(
                "Akurasi",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}