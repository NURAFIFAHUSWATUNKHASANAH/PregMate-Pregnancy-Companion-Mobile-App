import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'dart:ui';

class PompaAsiView extends StatefulWidget {
  const PompaAsiView({Key? key}) : super(key: key);

  @override
  State<PompaAsiView> createState() => _PompaAsiViewState();
}

class _PompaAsiViewState extends State<PompaAsiView> {
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
                "Pompa & Simpan ASI",
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
                /// VIDEO PLAYER (SAMA STYLE MENYUSUI)
                Hero(
                  tag: 'video_pompa',
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
                              : Container(
                                  color: kMidnightBlue,
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Colors.white),
                                  ),
                                ),
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
                                    colors: [
                                      Colors.black.withOpacity(0.5),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.6)
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: IconButton(
                                        iconSize: 70,
                                        icon: Icon(
                                          _isPlaying
                                              ? Icons.pause_circle_outline_rounded
                                              : Icons.play_circle_outline_rounded,
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
                                        child: Text(
                                          "${_currentSpeed}x",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
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

                /// HEADER
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PANDUAN PRAKTIS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: kRosePink,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Pompa ASI",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: kMidnightBlue,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: kMidnightBlue.withOpacity(0.05), blurRadius: 10)
                        ],
                      ),
                      child: const Text(
                        "5 Step",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kMidnightBlue,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 25),

                /// STEP (SAMA STYLE MENYUSUI)
                _buildModernStep(1, "Cuci Tangan", "Pastikan tangan dan alat pompa dalam keadaan bersih."),
                _buildModernStep(2, "Posisi Nyaman", "Duduk rileks dan gunakan bra khusus pumping."),
                _buildModernStep(3, "Mulai Pompa", "Mulai dari mode stimulasi lalu ke mode ekspresi."),
                _buildModernStep(4, "Simpan ASI", "Masukkan ke botol/ASI bag steril."),
                _buildModernStep(5, "Label & Simpan", "Tulis tanggal lalu simpan di kulkas/freezer."),

                const SizedBox(height: 20),

                /// TIPS (SUDAH SAMA)
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
                          Icon(Icons.tips_and_updates_rounded, color: kRosePink, size: 22),
                          SizedBox(width: 10),
                          Text(
                            "Tips Agar Berhasil",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildWhiteBullet("Pompa ASI secara rutin setiap 2-3 jam."),
                      _buildWhiteBullet("Pastikan posisi corong pompa nyaman dan tidak sakit."),
                      _buildWhiteBullet("Simpan ASI di wadah steril dan beri label tanggal."),
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

  /// GLASS BUTTON
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

  /// STEP CARD
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
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$num",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kMidnightBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: kMidnightBlue.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BULLET
  Widget _buildWhiteBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: kRosePink, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}