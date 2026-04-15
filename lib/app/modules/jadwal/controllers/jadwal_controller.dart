import 'dart:convert';
import 'package:PregMate/app/modules/jadwal/views/jadwal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class JadwalController extends GetxController {
  final box = GetStorage();

  String? fcmToken;
  String? userId;
  String? kehamilanId; // Tambahkan variabel untuk menampung kehamilan_id

  @override
  void onInit() {
    super.onInit();
    initUser();
  }

  Future<void> initUser() async {
    userId = box.read('user_id');
    kehamilanId = box.read('kehamilan_id'); // Ambil dari storage

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print("DEBUG USER ID (Jadwal): $userId");
      print("DEBUG KEHAMILAN ID (Jadwal): $kehamilanId");
    } catch (e) {
      debugPrint("FCM error: $e");
    }
  }

  void showJadwalDialog() {
    Get.dialog(const JadwalDialog(), barrierDismissible: false);
  }

  Future<void> submitJadwal({
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String pesan,
    required BuildContext context,
  }) async {
    // Pastikan data terbaru terambil
    if (userId == null) userId = box.read('user_id');
    if (kehamilanId == null) kehamilanId = box.read('kehamilan_id');
    
    if (fcmToken == null) {
      fcmToken = await FirebaseMessaging.instance.getToken();
    }

    if (userId == null || fcmToken == null) {
      Get.snackbar("Error", "Data user belum siap, silakan login ulang.");
      return;
    }

    final tanggal = DateFormat('yyyy-MM-dd').format(selectedDate);
    final jam = selectedTime.format(context);

    try {
      final url = ApiConfig.jadwalUrl;
      
      final bodyData = {
        "user_id": userId,
        "kehamilan_id": kehamilanId, // Kirim kehamilan_id ke backend
        "fcmToken": fcmToken,
        "tanggal": tanggal,
        "jam": jam,
        "pesan": pesan,
        "dikirim": false,
      };

      print("BODY SUBMIT JADWAL: ${jsonEncode(bodyData)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyData),
      );

      print("STATUS SUBMIT JADWAL: ${response.statusCode}");
      print("RESPONSE SUBMIT JADWAL: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Tutup dialog
        Get.snackbar(
          "Berhasil", 
          "Jadwal berhasil disimpan dan notifikasi dikirim",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar("Gagal", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR SUBMIT JADWAL: $e");
      Get.snackbar("Error", "Tidak dapat terhubung ke server");
    }
  }
}