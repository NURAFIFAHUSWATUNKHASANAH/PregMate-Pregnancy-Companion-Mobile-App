import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tas_bersalin_controller.dart';

class TasBersalinView extends GetView<TasBersalinController> {
  const TasBersalinView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definisi Warna Sesuai Request
    const Color kMidnightBlue = Color(0xFF0C2D57);
    const Color kRosePink = Color(0xFFFF8E9E);
    const Color kBgSoft = Color(0xFFF8F9FD);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBgSoft,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kBgSoft,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 110,
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tas Bersalin",
                  style: TextStyle(
                    color: kMidnightBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  "Persiapan menyambut kehadiran buah hati",
                  style: TextStyle(
                    color: kMidnightBlue.withOpacity(0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: kMidnightBlue.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: kMidnightBlue.withOpacity(0.4),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kMidnightBlue,
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
            _buildChecklistPage(controller.ibuList, "ibu", kMidnightBlue, kRosePink, Icons.auto_awesome),
            _buildChecklistPage(controller.bayiList, "bayi", kMidnightBlue, kRosePink, Icons.child_friendly),
            _buildChecklistPage(controller.pendampingList, "pendamping", kMidnightBlue, kRosePink, Icons.family_restroom),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistPage(
    List<ItemChecklist> list,
    String category,
    Color primary,
    Color accent,
    IconData icon,
  ) {
    return Obx(() {
      double progress = controller.getProgress(list);
      int totalItems = list.length;
      int completedItems = list.where((e) => e.isChecked).length;

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // --- HEADER PROGRESS CARD ---
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, Color(0xFF1B4275)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(icon, color: accent, size: 28),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 35,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      completedItems == totalItems ? "Semua Perlengkapan Siap! ✨" : "Lengkapi Persiapan",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        height: 10,
                        width: (MediaQuery.of(Get.context!).size.width - 88) * progress,
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$completedItems / $totalItems Item Terpenuhi",
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                      Icon(Icons.verified, color: accent.withOpacity(0.8), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- CHECKLIST ITEMS ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = list[index];
                  final isDone = item.isChecked;

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDone ? 0.5 : 1.0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isDone ? accent.withOpacity(0.2) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () => controller.toggleItem(item, category),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: GestureDetector(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDone ? accent : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDone ? accent : Colors.grey.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: isDone 
                                ? const Icon(Icons.check, color: Colors.white, size: 18) 
                                : null,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDone ? primary.withOpacity(0.5) : primary,
                                  decoration: TextDecoration.none, // Garis coret dihapus
                                ),
                              ),
                            ),
                            if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Siap",
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.detail,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDone ? Colors.grey[400] : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: list.length,
              ),
            ),
          ),
        ],
      );
    });
  }
}