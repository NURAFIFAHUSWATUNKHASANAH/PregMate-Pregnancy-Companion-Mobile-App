import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../models/tips_model.dart';

class TipsDetailView extends StatefulWidget {
  final TipsModel data;

  const TipsDetailView({super.key, required this.data});

  @override
  State<TipsDetailView> createState() => _TipsDetailViewState();
}

class _TipsDetailViewState extends State<TipsDetailView> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isReady = false;
  double _speed = 1.0;

  static const Color kMidnightBlue = Color(0xFF0C2D57);
  static const Color kRosePink = Color(0xFFFF8E9E);
  static const Color kSoftBg = Color(0xFFF8F9FD);
  static const Color kAccentGold = Color(0xFFFFD1D1);

  @override
  void initState() {
    super.initState();
    final url = widget.data.videoUrl.trim();
    if (url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _isReady = true);
        }).catchError((e) {
          debugPrint("VIDEO ERROR: $e");
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _changeSpeed() {
    if (_controller == null) return;
    setState(() {
      _speed = _speed >= 2.0 ? 0.5 : _speed + 0.5;
      _controller!.setPlaybackSpeed(_speed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftBg,
      appBar: AppBar(
        backgroundColor: kSoftBg,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kMidnightBlue),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Tips Newborn",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= VIDEO PLAYER =================
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: kMidnightBlue.withOpacity(0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_controller != null && _isReady)
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      )
                    else
                      const Center(child: CircularProgressIndicator(color: kRosePink)),
                    
                    // Overlay & Controls
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        color: Colors.black.withOpacity(_isPlaying ? 0 : 0.35),
                        child: AnimatedScale(
                          scale: _isPlaying ? 0.8 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                            size: 70,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ),
                    ),

                    // Speed Control
                    Positioned(
                      top: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: _changeSpeed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            "${_speed}x",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ================= INFO SECTION =================
            Text(
              widget.data.title.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kMidnightBlue,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.data.desc,
              style: TextStyle(
                fontSize: 15,
                color: kMidnightBlue.withOpacity(0.6),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // ================= PANDUAN HEADER =================
            Row(
              children: [
                Container(
                  width: 6,
                  height: 24,
                  decoration: BoxDecoration(
                    color: kRosePink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Langkah-langkah",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: kMidnightBlue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // ================= STEPS LIST (CARD STYLE) =================
            ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.data.steps.length,
              itemBuilder: (context, index) {
                return _stepItem(
                  index + 1,
                  widget.data.steps[index],
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _stepItem(int no, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kMidnightBlue.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sidebar Number
              Container(
                width: 60,
                decoration: const BoxDecoration(
                  color: kRosePink,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "STEP",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$no",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "LANGKAH $no",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: kMidnightBlue,
                          fontSize: 13,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(
                          color: kMidnightBlue.withOpacity(0.7),
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}