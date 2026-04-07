import 'package:PregMate/app/modules/tips_newborn/views/menyusui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tips_newborn_controller.dart';
import 'bedong_bayi.dart';

class TipsNewbornView extends GetView<TipsNewbornController> {
  const TipsNewbornView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definisi palet warna agar konsisten
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
          "Panduan Bunda",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Obx(() {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: controller.tipsList.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final tip = controller.tipsList[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildTutorialCard(
                context,
                index: index,
                title: tip["title"] ?? "Tutorial",
                desc: tip["desc"] ?? "Pelajari selengkapnya di sini",
                blue: kMidnightBlue,
                pink: kRosePink,
                onTap: () {
                  // Navigasi sesuai judul tutorial
                  if (tip["title"] == "Tutorial Bedong Bayi") {
                    Get.to(() => const BedongBayiView());
                  } else if (tip["title"] == "Tutorial Menyusui") {
                    Get.to(() => const MenyusuiView());
                  } else {
                    Get.snackbar(
                      "Coming Soon 🚧",
                      "Tutorial '${tip["title"]}' sedang dikembangkan",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: kMidnightBlue,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(15),
                      borderRadius: 15,
                    );
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildTutorialCard(
    BuildContext context, {
    required int index,
    required String title,
    required String desc,
    required Color blue,
    required Color pink,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "${index + 1}",
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: blue,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: blue.withOpacity(0.5),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: pink.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: pink,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}