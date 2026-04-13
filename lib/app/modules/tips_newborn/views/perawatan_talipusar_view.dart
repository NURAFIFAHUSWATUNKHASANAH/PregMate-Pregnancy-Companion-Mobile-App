import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class PerawatanTaliPusarView extends StatefulWidget {
  const PerawatanTaliPusarView({Key? key}) : super(key: key);

  @override
  State<PerawatanTaliPusarView> createState() => _PerawatanTaliPusarViewState();
}

class _PerawatanTaliPusarViewState extends State<PerawatanTaliPusarView> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  double _currentSpeed = 1.0;
  bool _showControls = true;

  static const Color kMidnightBlue = Color(0xFF0C2D57);
  static const Color kRosePink = Color(0xFFFF8E9E);
  static const Color kSoftBg = Color(0xFFF8F9FF);

  @override
  void initState() {
    super.initState();

    // sementara pakai video menyusui dulu
    _controller = VideoPlayerController.asset('assets/menyusui.mp4')
      ..initialize().then((_) {
        setState(() {});
      });

    _startHideControls();
  }

  void _startHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showControls = true;
      } else {
        _controller.play();
        _isPlaying = true;
        _startHideControls();
      }
    });
  }

  void _changeSpeed() {
    setState(() {
      _currentSpeed = _currentSpeed >= 2.0 ? 1.0 : _currentSpeed + 0.5;
      _controller.setPlaybackSpeed(_currentSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftBg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: kMidnightBlue),
            onPressed: () => Get.back(),
          ),
        ),
        title: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Perawatan Tali Pusar",
                style: TextStyle(
                  color: kMidnightBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: kRosePink.withOpacity(0.05),
            ),
          ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// VIDEO
                _buildVideo(),

                const SizedBox(height: 40),

                /// HEADER
                Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PANDUAN KESEHATAN",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: kRosePink,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Tali Pusar Bayi",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: kMidnightBlue,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _badge("5 Step"),
                  ],
                ),

                const SizedBox(height: 25),

                /// STEPS
                _step(1, "Jaga Kebersihan", "Cuci tangan sebelum menyentuh area tali pusar bayi."),
                _step(2, "Biarkan Kering", "Jangan menutup tali pusar terlalu rapat."),
                _step(3, "Bersihkan Lembut", "Gunakan kasa steril jika dianjurkan tenaga medis."),
                _step(4, "Hindari Alkohol", "Tidak perlu alkohol kecuali rekomendasi dokter."),
                _step(5, "Pantau Infeksi", "Waspadai bau, kemerahan, atau nanah."),

                const SizedBox(height: 20),

                /// TIPS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kMidnightBlue, Color(0xFF1A4D8B)],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: kMidnightBlue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.health_and_safety, color: kRosePink),
                          SizedBox(width: 10),
                          Text(
                            "Tips Penting",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _bullet("Tali pusar akan lepas sendiri dalam 1–3 minggu."),
                      _bullet("Jangan menarik atau mengelupas paksa."),
                      _bullet("Hubungi dokter jika ada tanda infeksi."),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// VIDEO
  Widget _buildVideo() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: kMidnightBlue.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const Center(child: CircularProgressIndicator()),

            GestureDetector(
              onTap: () {
                setState(() => _showControls = !_showControls);
              },
              child: AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: IconButton(
                      iconSize: 70,
                      icon: Icon(
                        _isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _step(int n, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: kRosePink,
            child: Text("$n", style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: kRosePink, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}