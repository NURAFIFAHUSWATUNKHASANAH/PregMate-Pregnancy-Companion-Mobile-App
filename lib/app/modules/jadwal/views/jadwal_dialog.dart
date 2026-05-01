import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/jadwal_controller.dart';

class JadwalDialog extends StatefulWidget {
  const JadwalDialog({super.key});

  @override
  State<JadwalDialog> createState() => _JadwalDialogState();
}

class _JadwalDialogState extends State<JadwalDialog> {
  final controller = Get.find<JadwalController>();
  final Color primaryColor = const Color(0xFF0C2D57);

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final TextEditingController pesanController = TextEditingController();

  Future<void> pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> pickTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => selectedTime = result);
    }
  }

  void submit() async {
  if (selectedDate == null || selectedTime == null) {
    Get.snackbar(
      "Oops!",
      "Silakan pilih tanggal dan waktu terlebih dahulu",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
    );
    return;
  }

  final success = await controller.submitJadwal(
    selectedDate: selectedDate!,
    selectedTime: selectedTime!,
    pesan: pesanController.text.isEmpty
        ? "Saatnya latihan!"
        : pesanController.text,
    context: context,
  );

  // 🔥 RESET FORM SETELAH SUKSES
  if (success) {
    setState(() {
      selectedDate = null;
      selectedTime = null;
      pesanController.clear();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  "Buat Jadwal",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Atur pengingat aktivitas latihan Anda secara efisien.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Date & Time Selectors in a Row
            Row(
              children: [
                Expanded(
                  child: _buildSelectionTile(
                    label: "Tanggal",
                    value: selectedDate == null
                        ? "Pilih"
                        : DateFormat('dd MMM').format(selectedDate!),
                    icon: Icons.event,
                    onTap: pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSelectionTile(
                    label: "Waktu",
                    value: selectedTime == null
                        ? "Pilih"
                        : selectedTime!.format(context),
                    icon: Icons.access_time_rounded,
                    onTap: pickTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Message Field
            Text(
              "Pesan Pengingat",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pesanController,
              decoration: InputDecoration(
                hintText: "Contoh: Sesi Pagi Semangat!",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Batal",
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Simpan Jadwal",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk tile pilihan Tanggal/Jam
  Widget _buildSelectionTile({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}