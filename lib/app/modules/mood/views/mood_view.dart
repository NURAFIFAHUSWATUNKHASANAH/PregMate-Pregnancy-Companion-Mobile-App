import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mood_controller.dart';

class MoodView extends StatelessWidget {
  final MoodController controller = Get.put(MoodController());

  // Palette Warna Modern & Lembut
  final Color primaryDark = const Color(0xFF0C2D57);
  final Color accentColor = const Color(0xFFFC6736);
  final Color bgLight = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Indikator Tubuh Bunda"),
            const SizedBox(height: 20),
            _buildVerticalSliders(),
            const SizedBox(height: 32),
            _buildRecommendationButton(),
            const SizedBox(height: 32),
            _buildRecommendationResult(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 90,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Halo, Bunda!",
            style: TextStyle(
              color: primaryDark.withOpacity(0.5),
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "Jurnal Kesehatan",
            style: TextStyle(
              color: primaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: primaryDark),
            onPressed: () {},
          ),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalSliders() {
    return Column(
      children: [
        _buildFullWidthSlider("Mual", controller.mual, Colors.orange,
            Icons.sick_rounded, "Ringan", "Berat"),
        const SizedBox(height: 16),
        _buildFullWidthSlider("Kondisi Tubuh", controller.energi, Colors.green,
            Icons.bolt_rounded, "Lemas", "Bugar"),
        const SizedBox(height: 16),
        _buildFullWidthSlider("Pegal-Pegal", controller.nyeri, Colors.redAccent,
            Icons.healing_rounded, "Nyaman", "Sakit"),
        const SizedBox(height: 16),
        _buildFullWidthSlider("Tidur", controller.tidur, Colors.indigo,
            Icons.bedtime_rounded, "Buruk", "Pulas"),
        const SizedBox(height: 16),
        _buildFullWidthSlider("Nafsu Makan", controller.nafsuMakan,
            Colors.pinkAccent, Icons.restaurant_rounded, "Kurang", "Baik"),
      ],
    );
  }

  Widget _buildFullWidthSlider(String label, RxDouble obsValue, Color color,
      IconData icon, String minL, String maxL) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Obx(() => Text(
                    "${obsValue.value.toInt()}/10",
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontSize: 16),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  activeTrackColor: color,
                  inactiveTrackColor: color.withOpacity(0.1),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10, elevation: 4),
                  overlayColor: color.withOpacity(0.1),
                ),
                child: Slider(
                  min: 0,
                  max: 10,
                  divisions: 10,
                  value: obsValue.value,
                  onChanged: (v) => obsValue.value = v,
                ),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(minL,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600)),
                Text(maxL,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient:
            LinearGradient(colors: [primaryDark, const Color(0xFF1A4D8C)]),
        boxShadow: [
          BoxShadow(
              color: primaryDark.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        onPressed: () => controller.getRecommendation(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Text(
              "Dapatkan Analisis Cerdas",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationResult() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(
                color: Color(0xFF0C2D57), strokeWidth: 3),
          ),
        );
      }

      if (controller.recommendation.value.isEmpty) return const SizedBox();

      // Logika Pemisahan Data
      List<String> rawLines = controller.recommendation.value.split('\n');
      String analisisSingkat = "";
      bool isAnalisis = false;
      Map<String, List<String>> sections = {};
      String currentKey = "";

      for (var line in rawLines) {
        String cleanLine =
            line.replaceAll(RegExp(r'^[0-9.]+|[#*•\-]'), '').trim();
        if (cleanLine.isEmpty) continue;

        if (cleanLine.toUpperCase().contains("ANALISIS SINGKAT")) {
          isAnalisis = true;
          continue;
        }

        if (isAnalisis) {
          if (cleanLine.toUpperCase() == "NUTRISI") {
            isAnalisis = false;
            currentKey = "NUTRISI";
            sections[currentKey] = [];
          } else {
            analisisSingkat += "$cleanLine ";
          }
          continue;
        }

        if (cleanLine.toUpperCase() == "NUTRISI" ||
            cleanLine.toUpperCase() == "AKTIVITAS" ||
            cleanLine.toUpperCase() == "RELAKSASI") {
          currentKey = cleanLine.toUpperCase();
          sections[currentKey] = [];
        } else if (currentKey.isNotEmpty) {
          sections[currentKey]!.add(cleanLine);
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (analisisSingkat.isNotEmpty) ...[
            _buildSectionHeader("Ringkasan Kondisi"),
            const SizedBox(height: 16),
            _buildSummaryBox(analisisSingkat),
            const SizedBox(height: 32),
          ],
          _buildSectionHeader("Rekomendasi"),
          const SizedBox(height: 16),
          ...sections.entries
              .map((entry) => _buildModernInfoCard(entry.key, entry.value))
              .toList(),
        ],
      );
    });
  }

  Widget _buildSummaryBox(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryDark.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_graph_rounded, color: primaryDark, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: primaryDark.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard(String title, List<String> points) {
    IconData icon = Icons.info_outline_rounded;
    Color themeColor = primaryDark;

    if (title.contains("NUTRISI")) {
      icon = Icons.restaurant_rounded;
      themeColor = Colors.orange.shade800;
    } else if (title.contains("AKTIVITAS")) {
      icon = Icons.directions_run_rounded;
      themeColor = Colors.blue.shade700;
    } else {
      icon = Icons.spa_rounded;
      themeColor = Colors.teal.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: themeColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.05),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: themeColor,
                      fontSize: 15,
                      letterSpacing: 1.1),
                ),
              ],
            ),
          ),
          // List Poin
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: points.asMap().entries.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Text("${point.key + 1}",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          point.value,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: primaryDark.withOpacity(0.85),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
