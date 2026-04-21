import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tips_newborn_controller.dart';
import 'tips_detail_view.dart';

class TipsNewbornView extends GetView<TipsNewbornController> {
  const TipsNewbornView({Key? key}) : super(key: key);

  static const Color kMidnightBlue = Color(0xFF0C2D57);
  static const Color kRosePink = Color(0xFFFF8E9E);
  static const Color kSoftBg = Color(0xFFF8F9FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftBg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "Tips Newborn",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.list.isEmpty) {
          return const Center(child: Text("Data belum tersedia"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.list.length,
          itemBuilder: (context, index) {
            final item = controller.list[index];

            return _card(item.title, item.desc, index, () {
              Get.to(() => TipsDetailView(data: item));
            });
          },
        );
      }),
    );
  }

  Widget _card(String title, String desc, int index, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kRosePink.withOpacity(0.2),
              child: Text("${index + 1}"),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),

            const Icon(Icons.play_circle_fill, color: kRosePink),
          ],
        ),
      ),
    );
  }
}