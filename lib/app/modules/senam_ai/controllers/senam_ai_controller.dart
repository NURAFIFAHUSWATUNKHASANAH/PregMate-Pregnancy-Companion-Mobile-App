import 'dart:async';
import 'package:PregMate/app/routes/app_pages.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/pose_service.dart';
import '../services/tflite_service.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';

class SenamAiController extends GetxController {
  CameraController? cameraController;

  final PoseService poseService = PoseService();
  final TfliteService tfliteService = TfliteService();

  final FlutterTts tts = FlutterTts();

  var currentPose = "".obs;
  var feedback = "".obs;

  var isCameraReady = false.obs;
  String targetPose = "";

  Timer? timer;
  var seconds = 60.obs;

  var correctFrames = 0.obs;
  var totalFrames = 0.obs;
  var accuracy = 0.0.obs;

  bool isProcessing = false;

  /// cooldown TTS supaya tidak spam suara
  DateTime lastSpeak = DateTime.now();

  final labels = ["Bird Dog", "Cat Cow", "Child Pose", "Side Lying Leg Lift"];

  /// ✅ STORAGE BARU
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    initModel();
  }

  /// ==============================
  /// LOAD MODEL
  /// ==============================
  Future initModel() async {
    await tfliteService.loadModel();
  }

  /// ==============================
  /// INIT CAMERA
  /// ==============================
  Future initCamera(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController!.initialize();

    isCameraReady.value = true;

    startPoseDetection();
  }

  /// ==============================
  /// TIMER LATIHAN
  /// ==============================
  void startTimer() {
    seconds.value = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      seconds.value--;

      if (seconds.value <= 0) {
        t.cancel();
        cameraController?.stopImageStream();

        accuracy.value = totalFrames.value > 0
            ? (correctFrames.value / totalFrames.value) * 100
            : 0;

        await simpanHistori(accuracy.value, targetPose);

        speak(
          "Latihan selesai. Akurasi kamu ${accuracy.value.toStringAsFixed(1)} persen",
        );

        showResultDialog();
      }
    });
  }

  /// ==============================
  /// POSE DETECTION
  /// ==============================
  void startPoseDetection() {
    cameraController!.startImageStream((image) async {
      if (isProcessing) return;

      isProcessing = true;

      try {
        final pose = await poseService.detectPose(image);

        if (pose != null) {
          final input = poseService.extractLandmarks(pose);
          final normalized = await poseService.normalize(input);
          final result = await tfliteService.predict(normalized);

          currentPose.value = labels[result];
          giveFeedback();
        }
      } catch (e) {
        print("Pose error: $e");
      }

      isProcessing = false;
    });
  }

  /// ==============================
  /// FEEDBACK GERAKAN
  /// ==============================
  void giveFeedback() {
    totalFrames.value++;

    bool isCorrect = currentPose.value == targetPose;

    if (isCorrect) {
      correctFrames.value++;
    }

    /// cooldown TTS 3 detik
    if (DateTime.now().difference(lastSpeak).inSeconds > 3) {
      speak(isCorrect ? "Gerakan benar" : "Gerakan salah");
      lastSpeak = DateTime.now();
    }
  }

  /// ==============================
  /// TEXT TO SPEECH
  /// ==============================
  void speak(String text) async {
    await tts.setLanguage("id-ID");
    await tts.setSpeechRate(0.45);
    await tts.setPitch(1.0);

    await tts.speak(text);
  }

  /// ==============================
  /// SIMPAN HISTORI (FIXED)
  /// ==============================
  Future<void> simpanHistori(double akurasi, String label) async {
    final userId = box.read('user_id');
    final token = box.read('auth_token');
    final kehamilanId = box.read('kehamilan_id');

    if (kehamilanId == null) {
      Get.snackbar("Error", "Kehamilan aktif tidak ditemukan");
      return;
    }

    if (userId == null || token == null || token.toString().isEmpty) {
      Get.snackbar("Error", "User ID atau token tidak ditemukan");
      return;
    }

    final body = {
      "user_id": userId,
      "kehamilan_id": kehamilanId,
      "label": label,
      "accuracy": akurasi,
      "tanggal": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.historiUrl}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        /// ✅ 1 SUMBER HISTORI
HistoriController historiController;

if (Get.isRegistered<HistoriController>()) {
  historiController = Get.find<HistoriController>();
} else {
  historiController = Get.put(HistoriController());
}

await historiController.refreshHistory();

        Get.snackbar("Sukses", "Histori latihan tersimpan");
      } else if (response.statusCode == 401) {
        /// 🔐 TOKEN EXPIRED
        box.erase();
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          "Gagal",
          "Gagal menyimpan histori: ${response.body}",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }

  /// ==============================
  /// DIALOG HASIL
  /// ==============================
  void showResultDialog({bool isManualStop = false}) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isManualStop ? "Latihan Dihentikan" : "Latihan Selesai",
        ),
        content: Obx(
          () => Text(
            "Akurasi Gerakan: ${accuracy.value.toStringAsFixed(1)} %",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          TextButton(
onPressed: () {
  Future.delayed(const Duration(milliseconds: 300), () {
    Get.until((route) => route.isFirst == false && route.settings.name == Routes.SENAM);
  });
},
            child: const Text("Tutup"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// ==============================
  /// CLEANUP
  /// ==============================
  @override
  void onClose() {
    cameraController?.dispose();
    timer?.cancel();
    super.onClose();
  }

  /// ==============================
  /// STOP MANUAL
  /// ==============================
  void stopExercise() async {
    timer?.cancel();
    await cameraController?.stopImageStream();

    accuracy.value = totalFrames.value > 0
        ? (correctFrames.value / totalFrames.value) * 100
        : 0;

    await simpanHistori(accuracy.value, targetPose);

    speak(
      "Latihan dihentikan. Akurasi kamu ${accuracy.value.toStringAsFixed(1)} persen",
    );

    showResultDialog(isManualStop: true);
  }
}
