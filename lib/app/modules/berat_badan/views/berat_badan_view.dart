import 'package:PregMate/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/berat_badan_controller.dart';

class BeratBadanView extends StatefulWidget {
  const BeratBadanView({Key? key}) : super(key: key);

  @override
  State<BeratBadanView> createState() => _BeratBadanViewState();
}

class _BeratBadanViewState extends State<BeratBadanView> {
  final controller = Get.put(BeratBadanController());
  final box = GetStorage();
  DateTime? hpht;
  final RxString role = "".obs;
  final TextEditingController beratInputController = TextEditingController();
  final homeController = Get.find<HomeController>();
  DateTime selectedDate = DateTime.now(); // ✅ penting

  @override
  void initState() {
    super.initState();
    role.value = box.read("user_role") ?? "";
    controller.fetchRiwayatBeratBadan();
  }

  bool get isBumil {
    final r = role.value.trim().toLowerCase();
    return r == "bumil" || r == "ibu";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0C2D57);
    const Color accentColor = Color(0xFF2196F3);
    const Color bgColor = Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: primaryColor, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Pantau Berat Badan",
          style: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeaderChart(controller, primaryColor),
            ),

            /// ================= INPUT =================
            SliverToBoxAdapter(
              child: isBumil
                  ? _buildInputSection(
                      beratInputController,
                      accentColor,
                      primaryColor,
                      controller,
                    )
                  : const SizedBox(),
            ),

            /// ================= HEADER =================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        size: 20, color: primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      "Riwayat Pengukuran",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: primaryColor),
                    ),
                    const Spacer(),
                    Text(
                      "${controller.riwayat.length} Data",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            /// ================= LIST =================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = controller.riwayat[index];
                    return _buildHistoryItem(
                      item,
                      accentColor,
                      primaryColor,
                      controller,
                    );
                  },
                  childCount: controller.riwayat.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  /// ================= HEADER CHART =================
  Widget _buildHeaderChart(
      BeratBadanController controller, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tren Mingguan",
                  style: TextStyle(color: Colors.white70)),
              Obx(() => Text(
                    "${controller.formatBerat(controller.beratTerakhir.value)} kg",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(height: 150, child: _buildLineChart(controller)),
        ],
      ),
    );
  }

  /// ================= INPUT =================
  Widget _buildInputSection(
    TextEditingController input,
    Color accent,
    Color primary,
    BeratBadanController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: input,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: "Berat badan (kg)",
                  ),
                ),
              ),
              const SizedBox(width: 12),

              /// DATE PICKER
              InkWell(
                onTap: () async {
                  final hphtString = homeController.hpht.value;

                  /// 🔥 HANDLE BELUM READY (API BELUM SELESAI)
                  if (hphtString.isEmpty) {
                    Get.snackbar(
                      "Tunggu sebentar",
                      "Data kehamilan sedang dimuat...",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  final hphtLocal = DateTime.parse(hphtString);

                  final firstAllowed = DateTime(
                    hphtLocal.year,
                    hphtLocal.month,
                    hphtLocal.day,
                  );

                  final lastAllowed = hphtLocal.add(const Duration(days: 280));

                  final today = DateTime.now();
                  final maxDate =
                      lastAllowed.isBefore(today) ? lastAllowed : today;

                  DateTime safeInitialDate = selectedDate;

                  if (safeInitialDate.isBefore(firstAllowed)) {
                    safeInitialDate = firstAllowed;
                  }

                  if (safeInitialDate.isAfter(maxDate)) {
                    safeInitialDate = maxDate;
                  }

                  /// 🔥 HANDLE DUPLIKAT MINGGU
                  if (controller.isMingguSudahAda(safeInitialDate)) {
                    DateTime temp = safeInitialDate;

                    while (controller.isMingguSudahAda(temp) &&
                        temp.isAfter(firstAllowed)) {
                      temp = temp.subtract(const Duration(days: 1));
                    }

                    if (temp.isBefore(firstAllowed)) {
                      temp = firstAllowed;
                    }

                    safeInitialDate = temp;
                  }

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: safeInitialDate,
                    firstDate: firstAllowed,
                    lastDate: maxDate,
                    selectableDayPredicate: (date) {
                      final hphtString = homeController.hpht.value;
                      if (hphtString.isEmpty) return false;

                      final hpht = DateTime.parse(hphtString);
                      final batasAkhir = hpht.add(const Duration(days: 280));
                      final today = DateTime.now();

                      /// ❌ sebelum HPHT
                      if (date.isBefore(hpht)) return false;

                      /// ❌ lebih dari 40 minggu
                      if (date.isAfter(batasAkhir)) return false;

                      /// ❌ masa depan
                      if (date.isAfter(today)) return false;

                      /// ❌ minggu sudah ada (INI KUNCI UTAMA)
                      if (controller.isMingguSudahAda(date)) return false;

                      return true;
                    },
                  );

                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${selectedDate.day}/${selectedDate.month}",
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// BUTTON ADD
              InkWell(
                onTap: () {
                  final berat = double.tryParse(input.text);

                  if (berat == null || berat <= 0) {
                    Get.snackbar("Error", "Masukkan berat badan yang valid");
                    return;
                  }

                  if (selectedDate.isAfter(DateTime.now())) {
                    Get.snackbar(
                        "Error", "Tidak bisa pilih tanggal masa depan");
                    return;
                  }

                  controller.tambahMingguan(
                    berat,
                    selectedDate,
                  );

                  input.clear();
                  Get.focusScope?.unfocus();
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Input per minggu (boleh pilih tanggal sebelumnya)",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  /// ================= FORMAT =================
  String formatTanggal(String tanggal) {
    final tgl = DateTime.parse(tanggal);
    return "${tgl.day}/${tgl.month}/${tgl.year}";
  }

String getMingguKehamilanLabel(String tanggal) {
  final tgl = DateTime.parse(tanggal);

  final hphtString = homeController.hpht.value;
  if (hphtString.isEmpty) return "-";

  final hpht = DateTime.parse(hphtString);

  final minggu = controller.getMingguKehamilan(tgl, hpht);

  return "Minggu ke-$minggu";
}

  /// ================= HISTORY =================
  Widget _buildHistoryItem(
  dynamic item,
  Color accent,
  Color primary,
  BeratBadanController controller,
) {
  final isAllowed = isBumil;

  /// 🔥 FIX: ambil index lebih aman
  final index = controller.riwayat.indexWhere((e) => e['_id'] == item['_id']);

  final isAbnormal = controller.isLonjakanAbnormal(index);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      /// 🔥 FIX: warna berubah kalau abnormal
      color: isAbnormal ? Colors.red.shade50 : Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: ListTile(
      leading: Icon(Icons.scale, color: accent),
      title: Text("${controller.formatBerat(item['berat_badan'])} kg"),

      /// 🔥 FIX: tambah indikator warning
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(formatTanggal(item['tanggal'])),

          Text(
            getMingguKehamilanLabel(item['tanggal']),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),

          /// 🔥 INI YANG KURANG
          if (isAbnormal)
            const Text(
              "⚠️ Kenaikan berat tidak normal",
              style: TextStyle(
                fontSize: 11,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),

      trailing: isAllowed
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  final TextEditingController editController =
                      TextEditingController(
                    text: controller.formatBerat(item['berat_badan']),
                  );

                  Get.defaultDialog(
                    title: "Edit Berat",
                    content: TextField(
                      controller: editController,
                      keyboardType: TextInputType.number,
                    ),
                    textConfirm: "Simpan",
                    textCancel: "Batal",
                    onConfirm: () {
                      final newBerat =
                          double.tryParse(editController.text);
                      if (newBerat != null) {
                        controller.updateBeratBadan(
                          item['_id'].toString(),
                          newBerat,
                        );
                        Get.back();
                      }
                    },
                  );
                }

                if (value == 'delete') {
                  Get.defaultDialog(
                    title: "Hapus Data?",
                    middleText: "Yakin mau hapus data ini?",
                    textConfirm: "Hapus",
                    textCancel: "Batal",
                    onConfirm: () {
                      controller.deleteBeratBadan(
                          item['_id'].toString());
                      Get.back();
                    },
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange),
                      SizedBox(width: 8),
                      Text("Edit"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Hapus"),
                    ],
                  ),
                ),
              ],
            )
          : null,
    ),
  );
}

  /// ================= CHART =================
  Widget _buildLineChart(BeratBadanController controller) {
    if (controller.riwayat.isEmpty) {
      return const Center(child: Text("Data kosong"));
    }

    var data = controller.riwayat.take(7).toList().reversed.toList();

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) {
              return FlSpot(
                e.key.toDouble(),
                double.tryParse(e.value['berat_badan'].toString()) ?? 0,
              );
            }).toList(),
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}
