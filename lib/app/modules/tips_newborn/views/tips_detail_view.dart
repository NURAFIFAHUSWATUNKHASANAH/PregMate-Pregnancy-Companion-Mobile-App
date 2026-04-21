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

  @override
  void initState() {
    super.initState();

    final url = widget.data.videoUrl.trim();

    // 🔥 SAFE INIT VIDEO
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
      if (_speed == 0.5) {
        _speed = 1.0;
      } else if (_speed == 1.0) {
        _speed = 1.5;
      } else if (_speed == 1.5) {
        _speed = 2.0;
      } else {
        _speed = 0.5;
      }

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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: kMidnightBlue),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= VIDEO =================
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // VIDEO
                    (_controller != null && _isReady)
                        ? AspectRatio(
                            aspectRatio:
                                _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                                color: kRosePink),
                          ),

                    // PLAY BUTTON
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        color: Colors.black26,
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // SPEED
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _changeSpeed,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_speed}x",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= TITLE =================
            Text(
              widget.data.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: kMidnightBlue,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              widget.data.desc,
              style: TextStyle(
                fontSize: 14,
                color: kMidnightBlue.withOpacity(0.6),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // ================= HEADER =================
            const Text(
              "Panduan Langkah",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kMidnightBlue,
              ),
            ),

            const SizedBox(height: 12),

            // ================= STEPS =================
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.data.steps.isEmpty
                  ? 0
                  : widget.data.steps.length,
              itemBuilder: (context, index) {
                return _stepCard(
                  index + 1,
                  widget.data.steps[index],
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= STEP CARD =================
  Widget _stepCard(int no, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [

          // NUMBER
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: kRosePink,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "$no",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Langkah $no",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: kMidnightBlue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  desc,
                  style: TextStyle(
                    color: kMidnightBlue.withOpacity(0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}