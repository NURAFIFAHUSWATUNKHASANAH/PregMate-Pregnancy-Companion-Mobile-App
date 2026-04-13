import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/histori/views/histori_view.dart';
import 'package:PregMate/app/modules/senam/views/senam_session_view.dart';
import 'package:PregMate/app/modules/senam/views/senam_validasi_view.dart';
import '../controllers/senam_controller.dart';
import '../../home/controllers/home_controller.dart';

class SenamView extends GetView<SenamController> {
  const SenamView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HistoriController());
    
    const Color kMidnightBlue = Color(0xFF0C2D57);
    const Color kRosePink = Color(0xFFFF8E9E);
    const Color kBgColor = Color(0xFFFBFBFF);

    final homeController = Get.find<HomeController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: kMidnightBlue.withOpacity(0.05),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: kMidnightBlue),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          title: const Text(
            "Senam Ibu Hamil",
            style: TextStyle(
              color: kMidnightBlue,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          bottom: const TabBar(
            labelColor: kMidnightBlue,
            indicatorColor: kMidnightBlue,
            tabs: [
              Tab(text: "Senam"),
              Tab(text: "History"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /// TAB 1 → SENAM
            Obx(() {
              // Ambil trimester ibu dari HomeController
              final int trimesterIbu = homeController.trimester.value;

              List<dynamic> senamList = [];

              if (trimesterIbu == 1) {
                senamList = controller.trimester1;
              } else if (trimesterIbu == 2) {
                senamList = [
                  ...controller.trimester1,
                  ...controller.trimester2
                ];
              } else if (trimesterIbu == 3) {
                senamList = [
                  ...controller.trimester1,
                  ...controller.trimester2,
                  ...controller.trimester3
                ];
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeader(
                            "Latihan Sesuai Trimester",
                            "Gerakan dirancang untuk trimester ke-$trimesterIbu",
                            kMidnightBlue),
                        const SizedBox(height: 16),
                        _buildExerciseList(senamList, kMidnightBlue, kRosePink),
                      ]),
                    ),
                  ),
                ],
              );
            }),

            /// TAB 2 → HISTORY
            const HistoriView(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: color.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseList(List<dynamic> dataList, Color blue, Color pink) {
    if (dataList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: blue.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: blue.withOpacity(0.05)),
        ),
        child: Center(
          child: Text(
            "Panduan belum tersedia",
            style: TextStyle(
                color: blue.withOpacity(0.4), fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final data = dataList[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
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
                onTap: () {
                  Get.to(() => SenamValidasiView(
                        title: data["title"] ?? "Latihan",
                        image: data["image"] ?? "",
                        desc: data["desc"] ?? "",
                      ));
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: pink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            data["image"] ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.fitness_center_rounded,
                                    color: pink, size: 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["title"] ?? "Latihan",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data["desc"] ?? "Ketuk untuk melihat detail gerakan",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: blue.withOpacity(0.5),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}