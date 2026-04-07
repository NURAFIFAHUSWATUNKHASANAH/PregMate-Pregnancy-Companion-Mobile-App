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

  Future<void> initUser() async {
    userId = box.read('user_id');

    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
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
    if (userId == null) userId = box.read('user_id');
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
      final response = await http.post(
        Uri.parse(ApiConfig.jadwalUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "fcmToken": fcmToken,
          "tanggal": tanggal,
          "jam": jam,
          "pesan": pesan,
          "dikirim": false,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        Get.snackbar("Berhasil", "Jadwal berhasil disimpan");
      } else {
        Get.snackbar("Gagal", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Tidak dapat terhubung ke server");
    }
  }
}