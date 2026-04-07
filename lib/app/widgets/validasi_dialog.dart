import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/rekomendasi/views/rekomendasi_view.dart';

class ValidasiDialog extends StatefulWidget {
  final Function()? onValid;

  const ValidasiDialog({Key? key, this.onValid}) : super(key: key);

  @override
  _ValidasiDialogState createState() => _ValidasiDialogState();
}

class _ValidasiDialogState extends State<ValidasiDialog> {
  String? pernahFisio;
  String? terakhirFisio;
  String? adaNyeri;

  // Primary Color PhysioCare
  final Color primaryColor = const Color(0xFF0C2D57);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.fact_check_rounded, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                const Text(
                  "Validasi Kondisi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C2D57),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Bantu kami memahami kondisi Anda saat ini untuk hasil yang akurat.",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStepTitle("Apakah Anda pernah ke fisioterapi?"),
                    _buildModernSelector(
                      value: pernahFisio,
                      options: ["Iya", "Tidak"],
                      onChanged: (val) {
                        setState(() {
                          pernahFisio = val;
                          terakhirFisio = null;
                        });
                      },
                    ),
                    
                    if (pernahFisio == "Iya") ...[
                      const SizedBox(height: 20),
                      _buildStepTitle("Kapan terakhir kali?"),
                      _buildModernSelector(
                        value: terakhirFisio,
                        options: ["> 1 minggu", "< 1 minggu"],
                        onChanged: (val) => setState(() => terakhirFisio = val),
                      ),
                    ],

                    const SizedBox(height: 20),
                    _buildStepTitle("Apakah saat ini ada nyeri?"),
                    _buildModernSelector(
                      value: adaNyeri,
                      options: ["Ada", "Tidak"],
                      onChanged: (val) => setState(() => adaNyeri = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Batal", style: TextStyle(color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleValidasi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("Lanjut", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildModernSelector({
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: options.map((option) {
        bool isSelected = value == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? primaryColor : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _handleValidasi() {
    if (pernahFisio == null ||
        adaNyeri == null ||
        (pernahFisio == "Iya" && terakhirFisio == null)) {
      Get.snackbar(
        "Lengkapi Data", 
        "Mohon pilih semua jawaban terlebih dahulu.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
      );
      return;
    }

    if (pernahFisio == "Iya" && adaNyeri == "Ada") {
      _showDialog("Silakan hubungi Fisioterapis untuk penanganan lebih lanjut.");
    } else if (pernahFisio == "Tidak" && adaNyeri == "Ada") {
      _showDialog("Kondisi nyeri sebaiknya dikonsultasikan langsung ke Fisioterapis.");
    } else {
      _lanjutKeRekomendasi();
    }
  }

  void _showDialog(String message) {
    Get.back();
    Get.defaultDialog(
      title: "Saran Ahli",
      titleStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      middleText: message,
      backgroundColor: Colors.white,
      radius: 20,
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Mengerti", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _lanjutKeRekomendasi() {
    Get.back();
    if (widget.onValid != null) {
      widget.onValid!();
    } else {
      Get.dialog(RekomendasiDialog());
    }
  }
}