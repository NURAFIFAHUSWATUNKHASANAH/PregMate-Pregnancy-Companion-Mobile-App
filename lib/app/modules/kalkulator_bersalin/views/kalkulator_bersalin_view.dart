import 'package:PregMate/app/utils/rupiah_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/kalkulator_bersalin_controller.dart';

class KalkulatorBersalinView extends GetView<KalkulatorBersalinController> {
  const KalkulatorBersalinView({super.key});

  // --- Theme Colors ---
  static const Color kMidnightBlue = Color(0xFF0C2D57);
  static const Color kRosePink = Color(0xFFFF8E9E);
  static const Color kBgColor = Color(0xFFF8FAFC);
  static const Color kTextLight = Color(0xFF64748B);
  static const Color kSuccess = Color(0xFF2DD4BF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        title: const Text(
          "Pregnancy Finance",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_suggest_rounded,
                color: kMidnightBlue, size: 28),
            onPressed: () => _showConfigSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _modernFabMenu(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: kRosePink));
        }
        return RefreshIndicator(
          onRefresh: () => controller.getDashboard(),
          color: kRosePink,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _financialSummary(),
                const SizedBox(height: 30),
                _sectionTitle("TARGET & PROGRESS"),
                _targetCard(),
                const SizedBox(height: 24),
                _insightCard(),
                const SizedBox(height: 30),
                _sectionTitle("RIWAYAT TERAKHIR"),
                _historyList(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- UI COMPONENTS ---

  Widget _financialSummary() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kMidnightBlue, Color(0xFF1E4D8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: kMidnightBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            "Total Saldo Tabungan",
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
                _idr(controller.saldo.value),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              )),
          const SizedBox(height: 30),
          Row(
            children: [
              _sumItemSmall("Pemasukan", controller.totalMasuk.value, kSuccess),
              const Spacer(),
              Container(width: 1, height: 25, color: Colors.white12),
              const Spacer(),
              _sumItemSmall(
                  "Pengeluaran", controller.totalKeluar.value, kRosePink),
            ],
          )
        ],
      ),
    );
  }

  Widget _targetCard() {
    double prog = (controller.progress.value / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Capaian Target",
                  style: TextStyle(
                      fontWeight: FontWeight.w800, color: kMidnightBlue)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: kRosePink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  "${controller.progress.value.toInt()}%",
                  style: const TextStyle(
                      color: kRosePink,
                      fontWeight: FontWeight.w900,
                      fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(10))),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: 12,
                width: (Get.width - 88) * prog,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kRosePink, Color(0xFFFFB4BC)]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: kRosePink.withOpacity(0.3), blurRadius: 5)
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _rowInfo("Total Kebutuhan", _idr(controller.totalKebutuhan.value),
              Icons.account_balance_rounded),
          _rowInfo("Sisa Target", _idr(controller.sisa.value),
              Icons.flag_circle_rounded),
          _rowInfo(
              "Estimasi Waktu",
              "${controller.sisaBulan.value} bulan ${controller.sisaHari.value} hari lagi",
              Icons.auto_graph_rounded),
              _rowInfo(
  "Target Nabung (${controller.metodeNabung.value})",
  _idr(controller.targetNabung.value),
  Icons.savings_rounded,
),
        ],
      ),
    );
  }

  Widget _historyList() {
    return Obx(() {
      if (controller.listTransaksi.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child:
                Text("Belum ada riwayat", style: TextStyle(color: kTextLight)),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.listTransaksi.length,
        itemBuilder: (context, index) {
          final item = controller.listTransaksi[index];
          bool isMasuk = item["tipe"] == "masuk";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isMasuk ? kSuccess : kRosePink).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMasuk
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isMasuk ? kSuccess : kRosePink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMasuk ? "Tabungan Masuk" : "Pengeluaran",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: kMidnightBlue),
                      ),
                      if (!isMasuk &&
                          item["keterangan"] != null &&
                          item["keterangan"].toString().isNotEmpty)
                        Text(
                          item["keterangan"],
                          style: const TextStyle(
                              fontSize: 11,
                              color: kRosePink,
                              fontWeight: FontWeight.w500),
                        ),
                      Text(
                        item["tanggal"] ?? "Baru saja",
                        style: const TextStyle(fontSize: 11, color: kTextLight),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isMasuk ? '+' : '-'} ${_idr((item["jumlah"] ?? 0).toDouble())}",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isMasuk ? kSuccess : kRosePink,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showTransactionSheet(bool isIn) {
    TextEditingController amountC = TextEditingController();
    TextEditingController ketC = TextEditingController();

    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(bottom: Get.mediaQuery.viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isIn ? kSuccess : kRosePink).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isIn ? Icons.add_chart_rounded : Icons.payments_rounded,
                    color: isIn ? kSuccess : kRosePink,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isIn ? "Tambah Tabungan" : "Catat Pengeluaran",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kMidnightBlue),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: amountC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    RupiahInputFormatter(),
                  ],
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: kMidnightBlue,
                  ),
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(color: kMidnightBlue.withOpacity(0.2)),
                    border: InputBorder.none,
                    prefixText: "Rp ",
                    prefixStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextLight,
                    ),
                  ),
                ),
                if (!isIn) ...[
                  const SizedBox(height: 15),
                  TextField(
                    controller: ketC,
                    style: const TextStyle(fontSize: 14, color: kMidnightBlue),
                    decoration: _inputDecoration(
                        "Keterangan", Icons.notes_rounded),
                  ),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isIn ? kMidnightBlue : kRosePink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      double val = parseRupiah(amountC.text);

                      // ❌ VALIDASI 1: nol / kosong
                      if (val <= 0) {
                        Get.snackbar("Validasi", "Nominal tidak boleh 0");
                        return;
                      }

                      // ❌ VALIDASI 2: pengeluaran > saldo
                      if (!isIn && val > controller.saldo.value) {
                        Get.snackbar("Validasi", "Pengeluaran melebihi saldo");
                        return;
                      }

                      // ❌ VALIDASI 3: wajib keterangan untuk pengeluaran
                      if (!isIn && ketC.text.trim().isEmpty) {
                        Get.snackbar("Validasi", "Keterangan wajib diisi");
                        return;
                      }

                      controller.tambahTransaksi(val, isIn,
                          keterangan: ketC.text);
                      Get.back();
                    },
                    child: const Text(
                      "Konfirmasi",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper UI Widgets ---

  void _showConfigSheet(BuildContext context) {
    controller.biayaController.text = controller.totalKebutuhan.value > 0
        ? controller.totalKebutuhan.value.toInt().toString()
        : "";

    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  "Konfigurasi Target",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: kMidnightBlue),
                ),
                const SizedBox(height: 25),
                TextField(
                  controller: controller.biayaController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      controller.totalBiaya.value = double.tryParse(v) ?? 0,
                  decoration: _inputDecoration("Target Biaya Persalinan (Rp)",
                      Icons.account_balance_wallet_rounded),
                ),
                const SizedBox(height: 25),
                _sectionTitle("DATA REFERENSI"),
                Row(
                  children: [
                    Expanded(
                        child: _infoFieldDisabled(
                            "HPHT",
                            controller.homeC.hpht.value,
                            Icons.calendar_today_rounded)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _infoFieldDisabled(
                            "ESTIMASI HPL",
                            controller.homeC.hpl.value,
                            Icons.event_available_rounded)),
                  ],
                ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kMidnightBlue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => controller.saveKalkulator(),
                    child: const Text(
                      "Simpan Rencana",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernFabMenu() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            if (!_isTargetReady) {
              _showNotReadyDialog(Get.context!);
              return;
            }
            _showTransactionSheet(true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: kMidnightBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: kMidnightBlue.withOpacity(0.3), blurRadius: 10)
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text("TABUNG",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.small(
          heroTag: "out",
          onPressed: () {
            if (!_isTargetReady) {
              _showNotReadyDialog(Get.context!);
              return;
            }
            _showTransactionSheet(false);
          },
          backgroundColor: Colors.white,
          elevation: 4,
          child: const Icon(Icons.remove_rounded, color: kRosePink, size: 24),
        ),
      ],
    );
  }

  Widget _sumItemSmall(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(_idr(val),
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }

  Widget _infoFieldDisabled(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: kTextLight,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kBgColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: kMidnightBlue),
              const SizedBox(width: 10),
              Text(
                value.isEmpty ? "-" : value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kMidnightBlue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rowInfo(String t, String v, IconData i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: kBgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(i, size: 18, color: kMidnightBlue),
          ),
          const SizedBox(width: 15),
          Text(t,
              style: const TextStyle(
                  color: kTextLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const Spacer(),
          Text(v,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: kMidnightBlue,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 1.5),
      ),
    );
  }

  Widget _insightCard() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: kRosePink.withOpacity(0.08),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: kRosePink.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  color: kRosePink, size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  controller.insight.value,
                  style: const TextStyle(
                      color: kMidnightBlue,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ));
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: kMidnightBlue, size: 20),
      labelText: label,
      labelStyle: const TextStyle(color: kTextLight, fontSize: 14),
      filled: true,
      fillColor: kBgColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kMidnightBlue, width: 1),
      ),
    );
  }

  String _idr(double v) =>
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
          .format(v);

  bool get _isTargetReady => controller.totalKebutuhan.value > 0;

  void _showNotReadyDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: kMidnightBlue.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Aesthetic dengan Background Blur/Soft
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kMidnightBlue.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: kMidnightBlue,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),

              // Judul Modern
              const Text(
                "Atur Rencana Dulu",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kMidnightBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi dengan Line Height yang nyaman
              const Text(
                "Kamu belum mengatur target biaya persalinan. Atur dulu supaya progres tabunganmu bisa terpantau dengan jelas.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextLight,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Nanti Saja",
                        style: TextStyle(
                          color: kTextLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: kMidnightBlue.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kMidnightBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _showConfigSheet(context);
                          });
                        },
                        child: const Text(
                          "Atur Sekarang",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      transitionCurve: Curves.easeOutBack,
    );
  }
}

double parseRupiah(String value) {
  return double.tryParse(
        value.replaceAll('.', '').replaceAll(',', ''),
      ) ??
      0;
}
