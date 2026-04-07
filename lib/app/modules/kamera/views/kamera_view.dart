import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/rekomendasi/controllers/rekomendasi_controller.dart';
import '../controllers/kamera_controller.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:video_player/video_player.dart';

class KameraView extends StatefulWidget {
  final Map<String, dynamic> terapi;
  final int index;

  KameraView({Key? key, required this.terapi, required this.index})
      : super(key: key);
  @override
  State<KameraView> createState() => _KameraViewState();
}

class _KameraViewState extends State<KameraView> {
  final KameraController controller = Get.put(KameraController());
  final rekomendasiController = Get.find<RekomendasiController>();
  late VideoPlayerController _videoController;
  var completed = false;

  // Ambil path video berdasarkan nama gerakan
  String getVideoPathFromName(String namaGerakan) {
    switch (namaGerakan.toLowerCase()) {
      case 'cat cow':
        return 'assets/CatCow.mp4';
      case 'birddog':
      case 'bird dog':
        return 'assets/BirdDog.mp4';
      case 'child pose':
        return 'assets/ChildPose.mp4';
      case 'side lying leg lift':
        return 'assets/SideLyingLegLeft.mp4';
      default:
        return 'assets/tutorial.mp4';
    }
  }

  @override
  void initState() {
    super.initState();

    controller.initialize(label: widget.terapi["nama"], index: widget.index);

    _videoController =
        VideoPlayerController.asset(getVideoPathFromName(widget.terapi["nama"]))
          ..initialize().then((_) {
            _videoController.setLooping(true);
            _videoController.play();
            setState(() {});
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    controller.cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (!controller.isCameraInitialized.value ||
            !_videoController.value.isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            // Kamera preview
            Positioned.fill(
              child: CameraPreview(controller.cameraController),
            ),

            // Landmark pose
            Positioned.fill(
              child: CustomPaint(
                painter: PoseLandmarkPainter(controller.currentPoses.value),
              ),
            ),

            // Tombol kembali di pojok kiri atas
            Positioned(
              top: 40,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),

            // Video tutorial diputar vertikal (rotate 90 derajat)
            Positioned(
              top: 80,
              right: 80,
              width: 20,
              height: 130,
              child: Transform.rotate(
                angle: 90 * 3.1415926535 / 180,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            ),

            // Sisa waktu
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                // Sisa waktu
                child: Obx(() {
                  if (controller.timer.value == 0 && !completed) {
                    completed = true;

                    // Update progress di controller Rekomendasi
                    final rekomendasiController =
                        Get.find<RekomendasiController>();
                    rekomendasiController.markTerapiAsCompleted(widget.index);
                    rekomendasiController.terapiList
                        .refresh(); // force rebuild UI

                    // Tampilkan snackbar
                    Get.snackbar(
                      "Selesai",
                      "Terapi ${widget.terapi["nama"]} selesai!",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );

                    // Tutup KameraView setelah delay sedikit supaya UI snackbar muncul
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Get.back(); // kembali ke RekomendasiView
                    });
                  }

                  return Text(
                    'Sisa Waktu: ${controller.timer.value} detik',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  );
                }),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class PoseLandmarkPainter extends CustomPainter {
  final List<Pose> poses;

  PoseLandmarkPainter(this.poses);

  final Paint _landmarkPaint = Paint()
    ..color = Colors.green
    ..strokeWidth = 4
    ..style = PaintingStyle.fill;

  final Paint _linePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final List<List<PoseLandmarkType>> _connections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftHeel],
    [PoseLandmarkType.leftHeel, PoseLandmarkType.leftFootIndex],
    [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightHeel],
    [PoseLandmarkType.rightHeel, PoseLandmarkType.rightFootIndex],
    [PoseLandmarkType.leftEye, PoseLandmarkType.rightEye],
    [PoseLandmarkType.leftEar, PoseLandmarkType.leftEye],
    [PoseLandmarkType.rightEar, PoseLandmarkType.rightEye],
  ];

  Offset _translateLandmark(PoseLandmark landmark, Size size) {
    return Offset(landmark.x * size.width, landmark.y * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var pose in poses) {
      final landmarks = pose.landmarks;

      for (var pair in _connections) {
        final point1 = landmarks[pair[0]];
        final point2 = landmarks[pair[1]];
        if (point1 != null && point2 != null) {
          final offset1 = _translateLandmark(point1, size);
          final offset2 = _translateLandmark(point2, size);
          canvas.drawLine(offset1, offset2, _linePaint);
        }
      }

      for (var landmark in landmarks.values) {
        final offset = _translateLandmark(landmark, size);
        canvas.drawCircle(offset, 4, _landmarkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
