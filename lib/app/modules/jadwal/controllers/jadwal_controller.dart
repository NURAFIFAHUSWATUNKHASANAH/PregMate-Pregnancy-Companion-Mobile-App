import 'dart:convert';
import 'package:PregMate/app/modules/jadwal/views/jadwal_dialog.dart';
import 'package:PregMate/app/modules/jadwal/views/jadwal_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

class JadwalController extends GetxController {
  final box = GetStorage();
  var jadwalList = <dynamic>[].obs;

  String? fcmToken;
  String? userId;
  String? kehamilanId; // Tambahkan variabel untuk menampung kehamilan_id

@override
void onInit() {
  super.onInit();
  initUser().then((_) {
    fetchJadwal(); // 🔥 JALAN SETELAH USER READY
  });
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

Future<void> fetchJadwal() async {
  try {
    if (userId == null) {
      userId = box.read('user_id');
    }

    if (userId == null) return; // 🔥 STOP kalau masih null

    final url = "${ApiConfig.jadwalUrl}?user_id=$userId";

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      jadwalList.value = List<Map<String, dynamic>>.from(data);
    }
  } catch (e) {
    print("ERROR FETCH JADWAL: $e");
  }
}

Future<void> deleteJadwal(String id) async {
  try {
    final url = "${ApiConfig.jadwalUrl}/$id";

    await http.delete(Uri.parse(url));

    jadwalList.removeWhere((item) => item['_id'] == id);

    Get.snackbar("Berhasil", "Jadwal dihapus");
  } catch (e) {
    Get.snackbar("Error", "Gagal hapus jadwal");
  }
}

Future<void> editJadwal({
  required String id,
  required DateTime selectedDate,
  required TimeOfDay selectedTime,
  required String pesan,
  required BuildContext context,
}) async {
  try {
    final tanggal = DateFormat('yyyy-MM-dd').format(selectedDate);
    final jam = selectedTime.format(context);

    final url = "${ApiConfig.jadwalUrl}/$id";

    final bodyData = {
      "tanggal": tanggal,
      "jam": jam,
      "pesan": pesan,
    };

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyData),
    );

    if (response.statusCode == 200) {
      await fetchJadwal();

      // 🔥 TUTUP DIALOG DI SINI (lebih aman)
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        "Berhasil",
        "Jadwal berhasil diupdate",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar("Gagal", "Update gagal");
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  }
}


  void showJadwalDialog() {
    Get.to(() => const JadwalPage());
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
        // tutup dialog dengan aman (paksa pop sampai root dialog tertutup)
        if (Get.isDialogOpen ?? false) {
          Get.back(closeOverlays: true);
        }
  await fetchJadwal();

// kasih delay supaya UI stabil dulu
        Future.delayed(const Duration(milliseconds: 150), () {
          Get.snackbar(
            "Berhasil",
            "Jadwal berhasil disimpan dan notifikasi dikirim",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        });
      } else {
        Get.snackbar("Gagal", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR SUBMIT JADWAL: $e");
      Get.snackbar("Error", "Tidak dapat terhubung ke server");
    }
  }
}
