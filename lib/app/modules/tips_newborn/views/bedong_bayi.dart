import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class BedongBayiView extends StatefulWidget {
  const BedongBayiView({Key? key}) : super(key: key);

  @override
  State<BedongBayiView> createState() => _BedongBayiViewState();
}

class _BedongBayiViewState extends State<BedongBayiView> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Load video dari assets
    _controller = VideoPlayerController.asset('assets/bedong.mp4')
      ..initialize().then((_) {
        setState(() {});
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
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color kMidnightBlue = Color(0xFF0C2D57);
    const Color kRosePink = Color(0xFFFF8E9E);
    const Color kSoftBg = Color(0xFFFBFBFF);

    return Scaffold(
      backgroundColor: kSoftBg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kMidnightBlue.withOpacity(0.05),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: kMidnightBlue),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          "Tutorial Bedong",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VIDEO PLAYER
            if (_controller.value.isInitialized)
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: Colors.black,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: VideoPlayer(_controller),
                      ),
                      if (!_isPlaying)
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Icon(Icons.play_arrow_rounded, color: kMidnightBlue, size: 40),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: kMidnightBlue,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            const SizedBox(height: 32),

            // STEP BY STEP
            const Text(
              "Langkah Pemakaian",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kMidnightBlue,
              ),
            ),
            const SizedBox(height: 20),
            _buildStepItem(1, "Siapkan kain bedong bersih, lebar dan panjang sesuai bayi.", kMidnightBlue),
            _buildStepItem(2, "Letakkan bayi di atas kain bedong dengan kepala di atas lipatan.", kMidnightBlue),
            _buildStepItem(3, "Lipatan kain bagian kanan ke tubuh bayi, pastikan tangan bayi di bawah kain.", kMidnightBlue),
            _buildStepItem(4, "Lipatan kain bagian bawah kaki ke atas, rapatkan dengan lembut.", kMidnightBlue),
            _buildStepItem(5, "Lipatan kain bagian kiri ke tubuh bayi, pastikan rapat namun nyaman.", kMidnightBlue),
            const SizedBox(height: 32),

            // TIPS
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kRosePink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kRosePink.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb_rounded, color: kRosePink),
                      SizedBox(width: 8),
                      Text(
                        "Tips Aman",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: kMidnightBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint("Pastikan bayi tidak terlalu ketat, bisa bergerak sedikit."),
                  _buildBulletPoint("Gunakan kain berbahan lembut (katun/muslin)."),
                  _buildBulletPoint("Hidung & mulut bayi harus selalu bebas."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(int number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "$number",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFFFF8E9E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF0C2D57)),
            ),
          ),
        ],
      ),
    );
  }
}