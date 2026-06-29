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
              child: Column(
                children: [
                  _buildRecommendationCard(controller),
                  _buildHeaderChart(controller, primaryColor),
                ],
              ),
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
            controller.riwayat.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.monitor_weight_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Belum ada riwayat pengukuran",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Lakukan pengukuran pertama untuk mulai memantau kenaikan berat badan selama kehamilan.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
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

Widget _buildRecommendationCard(BeratBadanController controller) {
  final kategori = controller.getKategoriIMT();
  final status = controller.getStatusBeratSaatIni();
  final imt = controller.getIMT();

  final double minimal = (status["minimal"] as num).toDouble();
  final double maksimal = (status["maksimal"] as num).toDouble();
  final double sekarang = (status["sekarang"] as num).toDouble();

  // Menentukan warna tema & pesan berdasarkan status berat badan saat ini
  Color statusColor = Colors.green;
  Color bgColor = const Color(0xffE8F5E9); // light green
  String statusMessage = "Berat badan sesuai target";
  String subMessage = "Pertahankan pola makan sehat Anda 🎉";

  if (sekarang < minimal) {
    statusColor = Colors.orange.shade700;
    bgColor = Colors.orange.shade50;
    statusMessage = "Kurang ${(minimal - sekarang).toStringAsFixed(1)} kg";
    subMessage = "Yuk, penuhi nutrisi harian sesuai saran dokter.";
  } else if (sekarang > maksimal) {
    statusColor = Colors.red.shade700;
    bgColor = Colors.red.shade50;
    statusMessage = "Kelebihan ${(sekarang - maksimal).toStringAsFixed(1)} kg";
    subMessage = "Coba batasi konsumsi gula dan rutin jalan santai.";
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 8),
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER CARD ---
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rekomendasi Berat Badan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Usia Kehamilan: Bulan ke-${status["bulan"]}",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              // Badge Kategori IMT Awal
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "${kategori["kategori"]}",
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFF4F5F7)),

        // --- BODY INFO (GRID/ROW LAYOUT) ---
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Kolom Kiri: Kondisi Awal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoLabel("IMT AWAL"),
                    const SizedBox(height: 4),
                    Text(
                      imt.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoLabel("TOTAL TARGET KENAIKAN"),
                    const SizedBox(height: 4),
                    Text(
                      "${kategori["minimal"]}-${kategori["maksimal"]} kg",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F5D75),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Garis Pembatas Tengah
              Container(
                height: 70,
                width: 1,
                color: Colors.grey.shade200,
              ),
              const SizedBox(width: 20),

              // Kolom Kanan: Kondisi Saat Ini
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoLabel("BERAT SAAT INI"),
                    const SizedBox(height: 4),
                    Text(
                      "${sekarang.toStringAsFixed(1)} kg",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoLabel("TARGET BULAN INI"),
                    const SizedBox(height: 4),
                    Text(
                      "${minimal.toStringAsFixed(1)} - ${maksimal.toStringAsFixed(1)} kg",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F5D75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- FOOTER BANNER (STATUS KONDISI) ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Icon(
                sekarang < minimal 
                    ? Icons.warning_amber_rounded 
                    : sekarang > maksimal 
                        ? Icons.error_outline_rounded 
                        : Icons.check_circle_outline_rounded,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusMessage,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subMessage,
                      style: TextStyle(
                        color: statusColor.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Helper widget untuk label kecil abu-abu agar kode lebih bersih
Widget _buildInfoLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.grey.shade500,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
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
              const Text("Tren Berat Badan",
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

                  if (!controller.bolehInputBulanSekarang()) {
                    final bulan = controller.getBulanKehamilanByHpht(
                      DateTime.now(),
                      hphtLocal,
                    );

                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Icon(
                              Icons.event_busy_rounded,
                              color: Colors.orange,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Pengukuran Sudah Ada",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C2D57),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Data pengukuran pada bulan ke-$bulan sudah tersedia.\n\n"
                              "Silakan lakukan pengukuran kembali pada bulan berikutnya atau ubah data pada menu Riwayat Pengukuran.",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C2D57),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  "Mengerti",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isScrollControlled: true,
                    );
                    return;
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
                      if (controller.isBulanSudahAda(date)) return false;

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
              "Input per Bulan",
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

    final hpht = DateTime.parse(homeController.hpht.value);

    final bulan = controller.getBulanKehamilan(
      DateTime.parse(item["tanggal"]),
      hpht,
    );

    final range = controller.getRangeTargetBerat(bulan);

    final double minimal = range["minimal"]!;
    final double maksimal = range["maksimal"]!;
    final double berat = double.tryParse(item["berat_badan"].toString()) ?? 0;

    final bool isNormal = berat >= minimal && berat <= maksimal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isNormal ? Colors.white : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(Icons.scale, color: accent),
        title: Text(
          "${controller.formatBerat(berat)} kg",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatTanggal(item["tanggal"])),
            Text(
              getMingguKehamilanLabel(item["tanggal"]),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Target bulan $bulan : "
              "${minimal.toStringAsFixed(1)} - ${maksimal.toStringAsFixed(1)} kg",
              style: const TextStyle(
                fontSize: 11,
                color: Colors.blueGrey,
              ),
            ),
            if (berat < minimal)
              Text(
                "⚠️ Masih kurang ${(minimal - berat).toStringAsFixed(1)} kg",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              )
            else if (berat > maksimal)
              Text(
                "⚠️ Melebihi target ${(berat - maksimal).toStringAsFixed(1)} kg",
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                "✓ Berat badan sesuai target",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: isAllowed
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "edit") {
                    final editController = TextEditingController(
                      text: controller.formatBerat(item["berat_badan"]),
                    );

                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const Text(
                                "Edit Berat Badan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0C2D57),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: editController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  hintText: "Masukkan berat badan baru (kg)",
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Get.back(),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text("Batal"),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF0C2D57),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: () {
                                        final newBerat = double.tryParse(
                                            editController.text);

                                        if (newBerat != null) {
                                          controller.updateBeratBadan(
                                            item["_id"].toString(),
                                            newBerat,
                                          );
                                          Get.back();
                                        }
                                      },
                                      child: const Text(
                                        "Simpan Perubahan",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),
                      isScrollControlled: true,
                    );
                  }

                  if (value == "delete") {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const Icon(
                              Icons.delete_sweep_rounded,
                              color: Colors.redAccent,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Hapus Data Berat Badan?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C2D57),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Data yang telah dihapus tidak dapat dikembalikan. Apakah Bunda yakin ingin menghapus riwayat ini?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text("Batal"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: () {
                                      controller.deleteBeratBadan(
                                        item["_id"].toString(),
                                      );
                                      Get.back();
                                    },
                                    child: const Text(
                                      "Hapus",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "delete",
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
    return const Center(
      child: Text(
        "Belum ada riwayat pengukuran",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  // Ambil maksimal 7 data terakhir TANPA dibalik
  final data = controller.riwayat.length > 7
      ? controller.riwayat.sublist(controller.riwayat.length - 7)
      : controller.riwayat;

  return LineChart(
    LineChartData(
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: data
              .map((e) =>
                  (double.tryParse(e["berat_badan"].toString()) ?? 0))
              .reduce((a, b) => a < b ? a : b) -
          1,
      maxY: data
              .map((e) =>
                  (double.tryParse(e["berat_badan"].toString()) ?? 0))
              .reduce((a, b) => a > b ? a : b) +
          1,
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: data.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              double.tryParse(
                    entry.value["berat_badan"].toString(),
                  ) ??
                  0,
            );
          }).toList(),
          isCurved: true,
          color: Colors.white,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    ),
  );
}
}
