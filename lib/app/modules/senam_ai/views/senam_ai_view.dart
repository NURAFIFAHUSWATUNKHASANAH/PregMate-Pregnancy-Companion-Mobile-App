import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';
import '../controllers/senam_ai_controller.dart';

class SenamAiView extends StatefulWidget {
  final CameraDescription camera;
  final String targetPose;

  const SenamAiView({
    super.key,
    required this.camera,
    required this.targetPose,
  });

  @override
  State<SenamAiView> createState() => _SenamAiViewState();
}

class _SenamAiViewState extends State<SenamAiView> {
  final controller = Get.find<SenamAiController>();
  late VideoPlayerController videoController;

  String getVideoPathFromName(String namaGerakan) {
    switch (namaGerakan.toLowerCase()) {
      case 'cat cow': return 'assets/CatCow.mp4';
      case 'birddog':
      case 'bird dog': return 'assets/BirdDog.mp4';
      case 'child pose': return 'assets/ChildPose.mp4';
      case 'side lying leg lift': return 'assets/SideLyingLegLeft.mp4';
      default: return 'assets/tutorial.mp4';
    }
  }

  @override
  void initState() {
    super.initState();
    controller.targetPose = widget.targetPose;
    controller.initCamera(widget.camera);
    controller.startTimer();

    videoController = VideoPlayerController.asset(
      getVideoPathFromName(widget.targetPose),
    )..initialize().then((_) {
        videoController.setLooping(true);
        videoController.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    videoController.dispose();
    // CameraController di-dispose di dalam controller biasanya, 
    // tapi pastikan tidak terjadi leak.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// 1. FULLSCREEN CAMERA PREVIEW
          _buildCameraPreview(),

          /// 2. OVERLAY GRADIENT
          _buildTopBottomGradient(),

          /// 3. TOP BAR (Info Gerakan)
          _buildTopBar(),

          /// 4. VIDEO TUTORIAL (Rotated 90 Degrees)
          _buildFloatingTutorial(),

          /// 5. BOTTOM HUD (Timer & Stop)
          _buildBottomHUD(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      if (!controller.isCameraReady.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.cameraController!.value.previewSize!.height,
            height: controller.cameraController!.value.previewSize!.width,
            child: CameraPreview(controller.cameraController!),
          ),
        ),
      );
    });
  }

  Widget _buildTopBottomGradient() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.2, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "GERAKAN DIPILIH",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.targetPose.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900, // Perbaikan dari FontWeight.black
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white10,
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingTutorial() {
    if (!videoController.value.isInitialized) return const SizedBox();
    return Positioned(
      top: 130,
      right: 20,
      child: Container(
        width: 180,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              /// ROTATED VIDEO 90 DEGREES
              SizedBox.expand(
                child: RotatedBox(
                  quarterTurns: 1, // Memutar 90 derajat searah jarum jam
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: videoController.value.size.width,
                      height: videoController.value.size.height,
                      child: VideoPlayer(videoController),
                    ),
                  ),
                ),
              ),
              
              /// LABEL OVERLAY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                ),
                child: const Text(
                  "GUIDE",
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHUD() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8E9E).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.timer_rounded, color: Color(0xFFFF8E9E), size: 24),
                      ),
                      const SizedBox(width: 15),
                      Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "DURASI",
                            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDuration(controller.seconds.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace', // Menggunakan font bawaan untuk timer
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                
                GestureDetector(
                  onTap: () => controller.stopExercise(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5F6D), Color(0xFFFF8E9E)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF5F6D).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Text(
                      "SELESAI",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
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

  String _formatDuration(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }
}