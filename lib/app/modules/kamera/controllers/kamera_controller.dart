import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/rekomendasi/controllers/rekomendasi_controller.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:PregMate/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:PregMate/app/modules/histori/controllers/histori_controller.dart';
// Tambahkan di bagian bawah kamera_controller.dart
import 'package:PregMate/app/modules/home/controllers/home_controller.dart';

class KameraController extends GetxController {
  late CameraController cameraController;
  late Interpreter interpreter;
  late List<String> labels;
  late PoseDetector poseDetector;
  late FlutterTts flutterTts;

  RxBool isCameraInitialized = false.obs;
  RxString predictedLabel = ''.obs;
  RxInt timer = 30.obs;
  RxDouble finalAccuracy = 0.0.obs;
  RxList<Pose> currentPoses = <Pose>[].obs;

  Timer? countdownTimer;
  bool isDetecting = false;
  bool lastSpokenCorrect = false;

  Map<String, int> predictionCounts = {};
  int totalPredictions = 0;

 String selectedLabel = "";
  int widgetIndex = 0;
  DateTime? _lastWrongSpeakTime;

  @override
  void onInit() {
    super.onInit();
    flutterTts = FlutterTts();
  }

  Future<void> initialize({required String label, required int index}) async {
    selectedLabel = label;
    widgetIndex = index;

    await loadLabels();
    await loadModel();
    await initializeCamera();
    startCountdown();
  }

  Future<void> loadLabels() async {
    final rawLabels = await rootBundle.loadString('assets/model/label.txt');
    labels = rawLabels
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> loadModel() async {
    interpreter =
        await Interpreter.fromAsset('assets/model/model_pyshiocare.tflite');
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);

    cameraController = CameraController(frontCamera, ResolutionPreset.medium,
        enableAudio: false);
    await cameraController.initialize();

    poseDetector = PoseDetector(
        options: PoseDetectorOptions(mode: PoseDetectionMode.stream));

    isCameraInitialized.value = true;
    cameraController.startImageStream(processCameraImage);
  }

  void processCameraImage(CameraImage image) async {
    if (isDetecting || timer.value <= 0) return;
    isDetecting = true;

    try {
      final input = await convertCameraImageToInput(image);
      if (input == null) {
        isDetecting = false;
        return;
      }

      final poses = await extractPoses(image);
      if (poses.isNotEmpty) currentPoses.value = poses;

      var output = List.filled(labels.length, 0.0).reshape([1, labels.length]);
      interpreter.run(input, output);

      int maxIndex = 0;
      double maxScore = output[0][0];
      for (int i = 1; i < labels.length; i++) {
        if (output[0][i] > maxScore) {
          maxIndex = i;
          maxScore = output[0][i];
        }
      }

      String newPrediction = labels[maxIndex];
      predictedLabel.value = newPrediction;
      print(
          "🎯 Prediction: $newPrediction | Target: $selectedLabel | Score: $maxScore");

      totalPredictions++;
      if (newPrediction == selectedLabel) {
        predictionCounts[newPrediction] =
            (predictionCounts[newPrediction] ?? 0) + 1;

        if (!lastSpokenCorrect) {
          await flutterTts.speak("Gerakan benar");
          lastSpokenCorrect = true;
        }
      } else {
        if (lastSpokenCorrect) {
          await flutterTts.speak("Gerakan salah");
          lastSpokenCorrect = false;
        } else {
          // Ucapkan "Gerakan salah" setiap 3 detik sekali saat gerakan salah terus-menerus
          if (_lastWrongSpeakTime == null ||
              DateTime.now().difference(_lastWrongSpeakTime!) >
                  Duration(seconds: 3)) {
            await flutterTts.speak("Gerakan salah");
            _lastWrongSpeakTime = DateTime.now();
          }
        }
      }
    } catch (e) {
      print("Error in detection: $e");
    }

    isDetecting = false;
  }

  Future<List<List<double>>?> convertCameraImageToInput(
      CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());

      final rotation = InputImageRotationValue.fromRawValue(
            cameraController.description.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final poses = await poseDetector.processImage(inputImage);
      if (poses.isEmpty) return null;

      final pose = poses.first;
      List<List<double>> landmarks = [];

      // Ambil semua landmark pose (x, y, z) dan normalisasi terhadap lebar/gambar
      for (var type in PoseLandmarkType.values) {
        final lm = pose.landmarks[type];
        if (lm != null) {
          final x = lm.x / imageSize.width;
          final y = lm.y / imageSize.height;
          final z = (lm.z ?? 0.0) / imageSize.width;
          landmarks.add([x, y, z]);
        } else {
          landmarks
              .add([0.0, 0.0, 0.0]); // fallback jika landmark tidak tersedia
        }
      }

      // ✅ Ubah bentuk menjadi 1x99 (flattened)
      return [landmarks.expand((e) => e).toList()];
    } catch (e) {
      print("❌ Error converting image to input: $e");
      return null;
    }
  }

  Future<List<Pose>> extractPoses(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize =
          Size(image.width.toDouble(), image.height.toDouble());
      final rotation = InputImageRotationValue.fromRawValue(
            cameraController.description.sensorOrientation,
          ) ??
          InputImageRotation.rotation0deg;

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      return await poseDetector.processImage(inputImage);
    } catch (e) {
      print("Error extracting poses: $e");
      return [];
    }
  }

  void startCountdown() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timerObj) async {
      if (timer.value <= 0) {
        cameraController.stopImageStream();
        countdownTimer?.cancel();

        calculateFinalAccuracy(); // ✅ Hitung akurasi
        await simpanHistori(
            finalAccuracy.value, selectedLabel); // ✅ Simpan histori
        await flutterTts.speak(
            "Sesi selesai. Akurasi kamu ${finalAccuracy.value.toStringAsFixed(2)} persen");

        Get.find<RekomendasiController>().markTerapiAsCompleted(Get.arguments?['index'] ?? 0);

        showResultDialog(); // ✅ Tampilkan hasil (opsional)
      } else {
        timer.value--;
      }
    });
  }

  void calculateFinalAccuracy() {
    if (totalPredictions == 0) {
      finalAccuracy.value = 0.0;
      return;
    }

    final correct = predictionCounts[selectedLabel] ?? 0;
    finalAccuracy.value = (correct / totalPredictions) * 100;
  }

void showResultDialog() {
  Get.dialog(AlertDialog(
    title: const Text('Hasil Deteksi'),
    content: Obx(() => Text(
          'Akurasi gerakan "$selectedLabel": ${finalAccuracy.value.toStringAsFixed(2)}%',
        )),
    actions: [
      TextButton(
        onPressed: () {
          // Tutup dialog
          Get.back(); 

          // Tutup semua route CameraView / latihan dan kembali ke RekomendasiView
          Get.offAllNamed('/rekomendasi');
        },
        child: const Text('Tutup'),
      ),
    ],
  ));

  if (finalAccuracy.value >= 70) {
    flutterTts.speak("Gerakan $selectedLabel sudah benar. Bagus!");
  } else {
    flutterTts.speak("Gerakan $selectedLabel perlu diperbaiki.");
  }
}

  Future<void> simpanHistori(double akurasi, String label) async {
    final prefs = await SharedPreferences.getInstance();
    // final userId = prefs.getString('_id');
    final userId = prefs.getString('user_id');
    if (userId == null) {
      Get.snackbar("Error", "User ID tidak ditemukan");
      return;
    }

    final body = {
      "user_id": userId,
      "label": label,
      "accuracy": akurasi,
      "tanggal": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/histori'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Get.find<HistoriController>().fetchHistory();
        Get.snackbar("Sukses", "Data histori berhasil disimpan");
        final HomeController homeController = Get.find<HomeController>();
        // await homeController.getTotalLatihanDanWaktu();
      } else {
        Get.snackbar("Gagal", "Gagal menyimpan histori");
      }
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }
}