import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/services/map_service.dart';
import '../controllers/craving_controller.dart';

import 'map_view.dart';

class CravingView extends GetView<CravingController> {
  final TextEditingController makananController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  CravingView({super.key});

  /// 🔥 buka map OSM
  void openMap(String makanan) async {
    Get.dialog(const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    final location = await MapService.getLocation(makanan);

    Get.back();

    if (location != null) {
      Get.to(() => MapView(
            lat: location["lat"]!,
            lon: location["lon"]!,
            title: makanan,
          ));
    } else {
      Get.snackbar("Error", "Lokasi tidak ditemukan");
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C2D57);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Ngidam 💖"),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          /// INPUT
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                TextField(
                  controller: makananController,
                  decoration: InputDecoration(
                    hintText: "Makanan (contoh: seblak)",
                    prefixIcon: const Icon(Icons.fastfood),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: keteranganController,
                  decoration: InputDecoration(
                    hintText: "Keterangan",
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    controller.addCraving(
                      makananController.text,
                      keteranganController.text,
                    );

                    makananController.clear();
                    keteranganController.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text("Tambah"),
                )
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: controller.cravings.length,
                itemBuilder: (context, index) {
                  final item = controller.cravings[index];

                  return GestureDetector(
                    onTap: () => openMap(item["makanan"]),
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(item["makanan"]),
                        subtitle: Text(item["keterangan"] ?? ""),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            controller.updateStatus(
                                item["_id"], value);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: "dipenuhi",
                                child: Text("Dipenuhi")),
                            const PopupMenuItem(
                                value: "nanti",
                                child: Text("Nanti")),
                            const PopupMenuItem(
                                value: "ditolak",
                                child: Text("Tidak bisa")),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}