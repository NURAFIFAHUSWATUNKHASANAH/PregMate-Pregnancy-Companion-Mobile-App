import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tas_bersalin_controller.dart';

class TasBersalinView extends GetView<TasBersalinController> {
  const TasBersalinView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definisi Brand Colors PregMate
    const primaryBlue = Color(0xFF0C2D57); // Midnight Blue kebanggaanmu
    const softBlue = Color(0xFFFCFEFF); // Background ultra clean
    const accentPink = Color(0xFFFF8A8A); // Soft Coral untuk aksen hangat

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: softBlue,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Tas Bersalin",
            style: TextStyle(
              color: primaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [primaryBlue, Color(0xFF1A4D8C)],
                  ),
                ),
                tabs: const [
                  Tab(child: Text("Ibu", style: TextStyle(fontWeight: FontWeight.bold))),
                  Tab(child: Text("Bayi", style: TextStyle(fontWeight: FontWeight.bold))),
                  Tab(child: Text("Ayah", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildChecklistPage(controller.ibuList, primaryBlue, accentPink),
            _buildChecklistPage(controller.bayiList, primaryBlue, accentPink),
            _buildChecklistPage(controller.pendampingList, primaryBlue, accentPink),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistPage(List<ItemChecklist> list, Color primary, Color accent) {
    return Obx(() {
      double progress = controller.getProgress(list);
      int totalItems = list.length;
      int completedItems = list.where((item) => item.isChecked).length;

      return Column(
        children: [
          // Glassmorphism Progress Header
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Kesiapan Tas",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOutCubic,
                      height: 12,
                      width: (MediaQuery.of(Get.context!).size.width - 88) * progress,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 10,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "$completedItems dari $totalItems item telah dikemas",
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // List dengan Desain Card Modern
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                bool isDone = item.isChecked;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDone ? Colors.grey[100] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDone ? Colors.transparent : Colors.grey[200]!,
                      width: 1.5,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    onTap: () => controller.toggleItem(item),
                    leading: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? accent : Colors.transparent,
                        border: Border.all(
                          color: isDone ? accent : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        size: 18,
                        color: isDone ? Colors.white : Colors.transparent,
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDone ? Colors.grey : primary,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.detail,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}