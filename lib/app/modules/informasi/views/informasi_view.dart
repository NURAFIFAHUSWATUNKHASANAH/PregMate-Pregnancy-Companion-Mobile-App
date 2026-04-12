import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/informasi_controller.dart';

class InformasiView extends StatelessWidget {
  final InformasiController controller = Get.put(InformasiController());

  InformasiView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kMidnightBlue = Color(0xFF0C2D57);
    const Color kRosePink = Color(0xFFFF8E9E);
    const Color kBgColor = Color(0xFFF8F9FD);

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kMidnightBlue),
        leading: Obx(() {
          bool isDetail = controller.selectedData.value != null;
          return IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (isDetail) {
                controller.clearSelected();
              } else {
                Get.back();
              }
            },
          );
        }),
        title: Obx(() => Text(
              controller.selectedData.value != null
                  ? "Detail"
                  : "Pusat Informasi",
              style: const TextStyle(
                color: kMidnightBlue,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            )),
      ),
      body: Obx(() {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildMainContent(kMidnightBlue, kRosePink),
        );
      }),
    );
  }

  Widget _buildMainContent(Color primary, Color accent) {
    // 1. DETAIL VIEW
    if (controller.selectedData.value != null) {
      return _buildDetail(controller.selectedData.value!, primary, accent);
    }

    // 2. EMPTY STATE
    if (controller.informasiList.isEmpty) {
      return _buildEmptyState(primary);
    }

    // 3. GROUPING LOGIC
    Map<String, List<dynamic>> groupedData = {
      "Hari Ini": [],
      "Kemarin": [],
      "Minggu Ini": [],
      "Lama": [],
    };

    for (var item in controller.informasiList) {
      String dateValue = _pickDateValue(item);
      String groupKey = _getGroupKey(dateValue);
      groupedData[groupKey]!.add(item);
    }

    List<String> sortedKeys = ["Hari Ini", "Kemarin", "Minggu Ini", "Lama"];

    return ListView(
      key: const ValueKey("InfoList"),
      // DITAMBAHKAN PADDING BAWAH 100 AGAR TIDAK KETUTUP BOTTOM MENU
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      physics: const BouncingScrollPhysics(),
      children: sortedKeys.map((key) {
        if (groupedData[key]!.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
              child: Text(
                key,
                style: TextStyle(
                  color: primary.withOpacity(0.4),
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            ...groupedData[key]!
                .map((data) => _buildInfoCard(data, primary, accent))
                .toList(),
          ],
        );
      }).toList(),
    );
  }

  String _pickDateValue(dynamic data) {
    return data["tanggal"] ?? data["created_at"] ?? data["date"] ?? "";
  }

  String _getGroupKey(String dateStr) {
    if (dateStr.isEmpty) return "Lama";

    try {
      DateTime date;

      if (dateStr.contains('GMT')) {
        date = DateFormat(
          "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
          "en_US",
        ).parse(dateStr, true).toLocal();
      } else if (dateStr.contains('T')) {
        date = DateTime.parse(dateStr).toLocal();
      } else if (dateStr.contains('-') && dateStr.length == 10) {
        date = DateFormat("yyyy-MM-dd").parse(dateStr);
      } else {
        date = DateFormat("dd-MM-yyyy").parse(dateStr);
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final lastWeek = today.subtract(const Duration(days: 7));
      final compareDate = DateTime(date.year, date.month, date.day);

      if (compareDate == today) return "Hari Ini";
      if (compareDate == yesterday) return "Kemarin";
      if (compareDate.isAfter(lastWeek)) return "Minggu Ini";
      return "Lama";
    } catch (e) {
      return "Lama";
    }
  }

  Widget _buildInfoCard(dynamic data, Color primary, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => controller.selectData(data),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_outlined,
                      color: accent, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data["pesan"] ?? "Informasi Baru",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: primary.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(_pickDateValue(data)),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: primary.withOpacity(0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(dynamic data, Color primary, Color accent) {
    return ListView(
      key: const ValueKey("InfoDetail"),
      // DITAMBAHKAN PADDING BAWAH 100 AGAR TIDAK KETUTUP BOTTOM MENU
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: accent.withOpacity(0.1)),
          ),
          child: Icon(Icons.info_outline_rounded, size: 40, color: accent),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(_pickDateValue(data)),
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                data["pesan"] ?? "-",
                style: TextStyle(
                  fontSize: 15,
                  height: 1.7,
                  color: primary.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Text("Tidak ada informasi",
          style: TextStyle(color: color.withOpacity(0.3))),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return "Baru saja";

    try {
      DateTime date;

      if (dateStr.contains('GMT')) {
        date = DateFormat(
          "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
          "en_US",
        ).parse(dateStr, true).toLocal();
      } else {
        date = DateTime.parse(dateStr).toLocal();
      }

      return DateFormat("d MMMM yyyy, HH:mm", "id_ID").format(date);
    } catch (e) {
      return dateStr;
    }
  }
}