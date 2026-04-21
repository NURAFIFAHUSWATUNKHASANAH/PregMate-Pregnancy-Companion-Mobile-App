import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tas_bersalin_controller.dart';

class TasBersalinView extends GetView<TasBersalinController> {
  const TasBersalinView({Key? key}) : super(key: key);

  // Definisi Warna Konsisten
  static const Color kMidnightBlue = Color(0xFF0C2D57);
  static const Color kRosePink = Color(0xFFFF8E9E);
  static const Color kBgSoft = Color(0xFFF4F7FA);
  static const Color kAccentBlue = Color(0xFF4485FD);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: kBgSoft,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kBgSoft,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 100,
          title: Padding(
            padding: const EdgeInsets.only(top: 20, left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tas Bersalin",
                  style: TextStyle(
                    color: kMidnightBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: kRosePink.withOpacity(0.8)),
                    const SizedBox(width: 4),
                    Text(
                      "Persiapan lengkap untuk momen spesial",
                      style: TextStyle(
                        color: kMidnightBlue.withOpacity(0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: kMidnightBlue.withOpacity(0.4),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [kMidnightBlue, Color(0xFF214C85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                tabs: const [
                  Tab(text: "Ibu"),
                  Tab(text: "Bayi"),
                  Tab(text: "Ayah"),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildChecklist(controller.ibuList, "ibu"),
            _buildChecklist(controller.bayiList, "bayi"),
            _buildChecklist(controller.pendampingList, "pendamping"),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(List<ItemChecklist> list, String category) {
    return Obx(() {
      final wajib = list.where((e) => e.type == "wajib").toList();
      final done = wajib.where((e) => e.isChecked).length;
      final progress = wajib.isEmpty ? 0.0 : done / wajib.length;

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // PROGRES HEADER
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [kMidnightBlue, Color(0xFF1B4273)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kMidnightBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(Icons.pregnant_woman, size: 100, color: Colors.white.withOpacity(0.05)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Kesiapan Barang",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "${(progress * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          color: kRosePink,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "$done dari ${wajib.length} item Wajib telah masuk tas",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // LIST ITEMS
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final item = list[i];
                  final isDone = item.isChecked;
                  final isWajib = item.type == "wajib";

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDone ? 0.6 : 1.0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.white.withOpacity(0.5) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => controller.toggleItem(item, category),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Checkbox Modern
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDone ? Colors.green : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDone ? Colors.green : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: isDone
                                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: kMidnightBlue,
                                          decoration: isDone ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      if (item.detail.isNotEmpty)
                                        Text(
                                          item.detail,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (isWajib && !isDone)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kRosePink.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "WAJIB",
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: kRosePink),
                                    ),
                                  ),
                              ],
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
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      );
    });
  }
}