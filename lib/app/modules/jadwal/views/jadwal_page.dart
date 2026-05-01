import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'jadwal_dialog.dart';
import '../controllers/jadwal_controller.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  // Palette Warna Profesional & Manis (Konsisten dengan NamaBayiView)
  final Color primaryDark = const Color(0xFF0C2D57);
  final Color accentPink = const Color(0xFFFF8E9E);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color greyText = const Color.fromARGB(255, 168, 166, 166);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JadwalController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  /// TAB 1: FORM (DIBUNGKUS SCROLL AGAR RAPI)
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: const JadwalDialog(),
                  ),

                  /// TAB 2: LIST JADWAL
                  _buildJadwalListTab(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================================
  /// HEADER & NAVIGASI
  /// ================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 90,
      title: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PENGINGAT BUNDA",
              style: TextStyle(
                color: greyText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Jadwal Bunda",
              style: TextStyle(
                color: primaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: TabBar(
        labelColor: Colors.white,
        unselectedLabelColor: primaryDark.withOpacity(0.4),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [primaryDark, primaryDark.withOpacity(0.8)],
          ),
        ),
        tabs: const [
          Tab(
            height: 48,
            child: Text("Buat Baru",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          Tab(
            height: 48,
            child: Text("Jadwal Saya",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  /// ================================
  /// TAB LIST JADWAL
  /// ================================

  Widget _buildJadwalListTab(JadwalController controller) {
    return Obx(() {
      final list = controller.jadwalList;

      if (list.isEmpty) {
        return _buildEmptyState("Belum ada jadwal yang tersimpan.");
      }

      // 🔥 SORT TERBARU DI ATAS
      final sortedList = List<Map<String, dynamic>>.from(list)
        ..sort((a, b) {
          final aDate = parseDateTime(a);
          final bDate = parseDateTime(b);
          return bDate.compareTo(aDate); // DESC
        });

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
        itemCount: sortedList.length,
        itemBuilder: (context, index) {
          final item = sortedList[index];
          return _buildModernJadwalCard(context, controller, item);
        },
      );
    });
  }

  DateTime parseDateTime(Map item) {
  try {
    final tanggal = item['tanggal']; // dd-MM-yyyy
    final jam = item['jam'];

    // 🔥 SPLIT manual
    final parts = tanggal.split("-");
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    final timeParts = jam.split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(" ")[0]);

    if (jam.toLowerCase().contains("pm") && hour < 12) {
      hour += 12;
    }
    if (jam.toLowerCase().contains("am") && hour == 12) {
      hour = 0;
    }

    return DateTime(year, month, day, hour, minute);
  } catch (e) {
    return DateTime.now();
  }
}

  Widget _buildModernJadwalCard(
      BuildContext context, JadwalController controller, Map item) {
    final selesai = isJadwalSelesai(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, // 🔥 tetap putih (tidak abu)
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryDark.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentPink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.calendar_today_rounded, color: accentPink),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['pesan'] ?? "Tanpa Pesan",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: primaryDark,
                    // ❌ HAPUS lineThrough
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.access_time_filled_rounded,
                        size: 14, color: greyText),
                    const SizedBox(width: 4),
                    Text(
                      "${item['tanggal']} • ${item['jam']}",
                      style: TextStyle(
                        fontSize: 13,
                        color: greyText,
                      ),
                    ),
                  ],
                ),

                // 🔥 LABEL SELESAI (OPSIONAL)
                if (selesai) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Selesai",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),

          // 🔥 ACTION: kalau selesai → hanya delete
          _buildActionMenu(context, controller, item, selesai),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, JadwalController controller,
      Map item, bool selesai) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      icon: Icon(Icons.more_vert_rounded, color: primaryDark.withOpacity(0.3)),
      itemBuilder: (context) {
        List<PopupMenuEntry> menu = [];

        // 🔥 kalau BELUM selesai → boleh edit
        if (!selesai) {
          menu.add(
            PopupMenuItem(
              value: "edit",
              child: Row(
                children: [
                  Icon(Icons.edit_note_rounded, size: 20, color: primaryDark),
                  const SizedBox(width: 12),
                  const Text("Edit Jadwal",
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }

        // 🔥 delete selalu ada
        menu.add(
          PopupMenuItem(
            value: "delete",
            child: Row(
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
                const SizedBox(width: 12),
                const Text("Hapus",
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );

        return menu;
      },
      onSelected: (value) {
        if (value == "delete") {
          _showDeleteJadwal(context, controller, item['_id']);
        } else if (value == "edit") {
          _showEditJadwal(context, controller, item);
        }
      },
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded,
              size: 80, color: accentPink.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryDark.withOpacity(0.4),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// 🔥 DIALOG FUNCTIONS (HAPUS & EDIT DENGAN STYLE KEKINIAN)
/// ============================================================

void _showDeleteJadwal(
  BuildContext context,
  JadwalController controller,
  String id,
) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Icon(Icons.delete_sweep_rounded,
              color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Hapus Jadwal?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C2D57), // primaryBlue
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Apakah Bunda yakin ingin menghapus jadwal ini? Data yang dihapus tidak dapat dikembalikan.",
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Color(0xFF64748B), fontSize: 14), // textGrey
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text("Batal",
                      style: TextStyle(color: Color(0xFF0F172A))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.deleteJadwal(id);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("Hapus",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

void _showEditJadwal(
    BuildContext context, JadwalController controller, Map item) {

  final TextEditingController pesanController =
      TextEditingController(text: item['pesan']);

  /// 🔥 PARSE TANGGAL (dd-MM-yyyy)
  final tanggalParts = item['tanggal'].split("-");
  DateTime selectedDate = DateTime(
    int.parse(tanggalParts[2]), // year
    int.parse(tanggalParts[1]), // month
    int.parse(tanggalParts[0]), // day
  );

  /// 🔥 PARSE JAM (SUPPORT AM/PM)
  final jam = item['jam'];
  final timeParts = jam.split(":");

  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1].split(" ")[0]);

  if (jam.toLowerCase().contains("pm") && hour < 12) {
    hour += 12;
  }
  if (jam.toLowerCase().contains("am") && hour == 12) {
    hour = 0;
  }

  TimeOfDay selectedTime = TimeOfDay(hour: hour, minute: minute);

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// HANDLE
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              /// TITLE
              const Text(
                "Perbarui Jadwal",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(0xFF0C2D57),
                ),
              ),

              const SizedBox(height: 24),

              /// INPUT PESAN
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0C2D57).withOpacity(0.05),
                  ),
                ),
                child: TextField(
                  controller: pesanController,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: "Ubah kegiatan Bunda...",
                    border: InputBorder.none,
                    icon: Icon(Icons.edit_note_rounded,
                        color: Color(0xFF0C2D57)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// DATE & TIME PICKER
              Row(
                children: [
                  _buildSmallPicker(
                    icon: Icons.calendar_today_rounded,
                    label:
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),

                  const SizedBox(width: 12),

                  _buildSmallPicker(
                    icon: Icons.access_time_rounded,
                    label: selectedTime.format(context),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              /// BUTTON SIMPAN
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.editJadwal(
                      id: item['_id'],
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      pesan: pesanController.text,
                      context: context,
                    );

                    Get.back();
                    controller.fetchJadwal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C2D57),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor:
                        const Color(0xFF0C2D57).withOpacity(0.3),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}

bool isJadwalSelesai(Map item) {
  try {
    final tanggal = item['tanggal']; // yyyy-MM-dd
    final jam = item['jam']; // bisa HH:mm atau 2:30 PM

    // parse tanggal
    final parts = tanggal.split("-");
final day = int.parse(parts[0]);
final month = int.parse(parts[1]);
final year = int.parse(parts[2]);

final date = DateTime(year, month, day);

    // parse jam manual
    final timeParts = jam.split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1].split(" ")[0]);

    // handle AM/PM
    if (jam.toLowerCase().contains("pm") && hour < 12) {
      hour += 12;
    }
    if (jam.toLowerCase().contains("am") && hour == 12) {
      hour = 0;
    }

    final finalDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    return finalDateTime.isBefore(DateTime.now());
  } catch (e) {
    return false;
  }
}

Widget _buildSmallPicker(
    {required IconData icon,
    required String label,
    required VoidCallback onTap}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFF8E9E).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: const Color(0xFFFF8E9E)),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF8E9E))),
          ],
        ),
      ),
    ),
  );
}
