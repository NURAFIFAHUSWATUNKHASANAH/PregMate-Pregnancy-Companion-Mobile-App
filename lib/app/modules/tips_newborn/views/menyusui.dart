import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class MenyusuiView extends StatefulWidget {
  const MenyusuiView({Key? key}) : super(key: key);

  @override
  State<MenyusuiView> createState() => _MenyusuiViewState();
}

class _MenyusuiViewState extends State<MenyusuiView> {
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
    _controller = VideoPlayerController.asset('assets/menyusui.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
    _startTimerHideControls();
  }

  void _startTimerHideControls() {
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
        _startTimerHideControls();
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
                "Tutorial Menyusui",
                style: TextStyle(
                  color: kMidnightBlue,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
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
            child: CircleAvatar(radius: 100, backgroundColor: kRosePink.withOpacity(0.05)),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 120, left: 24, right: 24, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- VIDEO PLAYER HERO ---
                Hero(
                  tag: 'video_menyusui',
                  child: Container(
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
                              : Container(color: kMidnightBlue, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
                          GestureDetector(
                            onTap: () {
                              setState(() => _showControls = !_showControls);
                              if (_showControls) _startTimerHideControls();
                            },
                            child: AnimatedOpacity(
                              opacity: _showControls ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.black.withOpacity(0.6)],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: IconButton(
                                        iconSize: 70,
                                        icon: Icon(
                                          _isPlaying ? Icons.pause_circle_outline_rounded : Icons.play_circle_outline_rounded,
                                          color: Colors.white,
                                        ),
                                        onPressed: _togglePlayPause,
                                      ),
                                    ),
                                    Positioned(
                                      top: 20,
                                      right: 20,
                                      child: _buildGlassButton(
                                        onTap: _changeSpeed,
                                        child: Text("${_currentSpeed}x", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: VideoProgressIndicator(
                                        _controller,
                                        allowScrubbing: true,
                                        colors: const VideoProgressColors(
                                          playedColor: kRosePink,
                                          bufferedColor: Colors.white24,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                /// --- HEADER PANDUAN ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PANDUAN TEKNIK",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: kRosePink, letterSpacing: 2),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Langkah Menyusui",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kMidnightBlue, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: kMidnightBlue.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: const Text("4 Step", style: TextStyle(fontWeight: FontWeight.bold, color: kMidnightBlue, fontSize: 12)),
                    )
                  ],
                ),

                const SizedBox(height: 25),

                /// --- LIST PANDUAN ---
                _buildModernStep(1, "Posisi Nyaman", "Gunakan posisi cradle hold atau football hold. Pastikan punggung Bunda tersangga dengan baik."),
                _buildModernStep(2, "Pelekatan (Latching)", "Pastikan mulut bayi terbuka lebar dan mencakup sebagian besar areola, bukan hanya puting."),
                _buildModernStep(3, "Gunakan Bantal", "Gunakan bantal menyusui untuk menopang lengan Bunda agar posisi bayi lebih stabil dan sejajar."),
                _buildModernStep(4, "Pantau Isapan", "Biarkan bayi menyusu dengan tenang. Perhatikan gerakan menelan yang ritmis pada leher bayi."),

                const SizedBox(height: 20),

                /// --- TIPS KEAMANAN (GRADIENT CARD) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kMidnightBlue, Color(0xFF1A4D8B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(color: kMidnightBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates_rounded, color: kRosePink, size: 22),
                          SizedBox(width: 10),
                          Text("Tips Agar Berhasil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildWhiteBullet("Susui bayi sesegera mungkin saat muncul tanda lapar."),
                      _buildWhiteBullet("Pastikan perut bayi menempel pada perut Bunda."),
                      _buildWhiteBullet("Ganti posisi payudara setelah bayi kenyang di satu sisi."),
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

  /// HELPER: GLASS BUTTON
  Widget _buildGlassButton({required VoidCallback onTap, required Widget child}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// HELPER: MODERN STEP CARD
  Widget _buildModernStep(int num, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kMidnightBlue.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kRosePink, kRosePink.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: kRosePink.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
              ],
            ),
            child: Center(
              child: Text(
                "$num",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kMidnightBlue),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(fontSize: 13, color: kMidnightBlue.withOpacity(0.6), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// HELPER: WHITE BULLET
  Widget _buildWhiteBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle_rounded, color: kRosePink, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}