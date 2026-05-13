import 'package:PregMate/app/modules/meditation/controllers/meditation_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui';

class BreathingSessionView extends StatefulWidget {
  final String title;
  final int duration;

  // ✅ TAMBAHAN
  final int inhaleDuration;
  final int exhaleDuration;

  const BreathingSessionView({
    super.key,
    required this.title,
    required this.duration,
    required this.inhaleDuration,
    required this.exhaleDuration,
  });

  @override
  State<BreathingSessionView> createState() =>
      _BreathingSessionViewState();
}

class _BreathingSessionViewState
    extends State<BreathingSessionView>
    with SingleTickerProviderStateMixin {

  // =========================
  // ANIMATION
  // =========================
  late AnimationController _controller;

  // =========================
  // TIMER
  // =========================
  Timer? _sessionTimer;
  Timer? _breathingTimer;

  int remainingSeconds = 0;
  int breathingCounter = 0;

  String breathingText = "Siap?";

  bool isInhaling = true;
  bool isStarted = false;

  @override
  void initState() {
    super.initState();

    remainingSeconds = widget.duration;

    // ✅ COUNTER AWAL
    breathingCounter = widget.inhaleDuration;

    // =========================
    // CONTROLLER
    // =========================
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.inhaleDuration,
      ),
    );

    // =========================
    // LISTENER TARIK / HEMBUS
    // =========================
    _controller.addStatusListener((status) {

      // =========================
      // TARIK SELESAI
      // =========================
      if (status == AnimationStatus.completed) {

        setState(() {
          breathingText = "Hembuskan";
          isInhaling = false;

          // ✅ COUNTER HEMBUS
          breathingCounter = widget.exhaleDuration;
        });

        // ✅ DURASI HEMBUS
        _controller.duration = Duration(
          seconds: widget.exhaleDuration,
        );

        _controller.reverse();
      }

      // =========================
      // HEMBUS SELESAI
      // =========================
      else if (status == AnimationStatus.dismissed) {

        if (isStarted) {

          setState(() {
            breathingText = "Tarik Napas";
            isInhaling = true;

            // ✅ COUNTER TARIK
            breathingCounter = widget.inhaleDuration;
          });

          // ✅ DURASI TARIK
          _controller.duration = Duration(
            seconds: widget.inhaleDuration,
          );

          _controller.forward();
        }
      }
    });
  }

  // =========================
  // START SESSION
  // =========================
  void startSession() {

    setState(() {
      isStarted = true;
      breathingText = "Tarik Napas";

      // ✅ RESET COUNTER
      breathingCounter = widget.inhaleDuration;
    });

    _controller.forward();

    _startSessionTimer();
    _startBreathingCounter();
  }

  // =========================
  // TIMER DURASI SESI
  // =========================
  void _startSessionTimer() {

    _sessionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        if (remainingSeconds > 0) {

          setState(() {
            remainingSeconds--;
          });

        } else {

          timer.cancel();

          _controller.stop();

          _showCompletionDialog();
        }
      },
    );
  }

  // =========================
  // TIMER COUNTER NAPAS
  // =========================
  void _startBreathingCounter() {

    _breathingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {

        if (!mounted) return;

        setState(() {

          if (breathingCounter > 1) {

            breathingCounter--;

          } else {

            // ✅ RESET SESUAI FASE
            breathingCounter = isInhaling
                ? widget.exhaleDuration
                : widget.inhaleDuration;
          }
        });
      },
    );
  }

  // =========================
  // DIALOG SELESAI
  // =========================
  void _showCompletionDialog() {

    final meditationC =
        Get.find<MeditationController>();

    double durasiMenit =
        widget.duration / 60;

    meditationC.kirimNotifSelesaiRelaksasi(
      label: widget.title,
      durasiMenit: durasiMenit,
    );

    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Sesi Selesai",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Luar biasa Bunda! Anda telah meluangkan waktu untuk ketenangan diri.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text(
              "Sama-sama",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  // =========================
  // FORMAT TIMER
  // =========================
  String formatTime(int seconds) {

    int minutes = seconds ~/ 60;
    int secs = seconds % 60;

    return
        "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {

    _controller.dispose();

    _sessionTimer?.cancel();

    _breathingTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    const Color kMidnightBlue =
        Color(0xFF0C2D57);

    const Color kRosePink =
        Color(0xFFFF8E9E);

    double progress =
        1 - (remainingSeconds / widget.duration);

    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),

        centerTitle: true,

        backgroundColor: Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),

          onPressed: () => Get.back(),
        ),
      ),

      body: Stack(
        children: [

          // =========================
          // BACKGROUND
          // =========================
          Container(
            width: double.infinity,

            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,

                colors: isInhaling
                    ? [
                        kMidnightBlue,
                        const Color(0xFF1A4D8C),
                      ]
                    : [
                        const Color(0xFF1A4D8C),
                        kMidnightBlue,
                      ],
              ),
            ),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                // =========================
                // TIMER
                // =========================
                Text(
                  formatTime(remainingSeconds),

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 50,
                  ),

                  child: LinearProgressIndicator(
                    value: progress,

                    backgroundColor:
                        Colors.white10,

                    color:
                        kRosePink.withOpacity(0.8),

                    minHeight: 4,
                  ),
                ),

                const SizedBox(height: 50),

                // =========================
                // TARIK / HEMBUS
                // =========================
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 600,
                  ),

                  child: Text(
                    breathingText,

                    key: ValueKey(
                      breathingText,
                    ),

                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // COUNTER
                // =========================
                Text(
                  isStarted
                      ? breathingCounter.toString()
                      : "-",

                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                // =========================
                // GRAPH
                // =========================
                AnimatedBuilder(
                  animation: _controller,

                  builder: (context, child) {

                    return Container(
                      height: 250,

                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: Stack(
                        alignment: Alignment.center,

                        children: [

                          // GLOW
                          CustomPaint(
                            size: const Size(
                              double.infinity,
                              250,
                            ),

                            painter:
                                BreathingWavePainter(
                              animationValue:
                                  _controller.value,

                              color:
                                  kRosePink.withOpacity(
                                0.2,
                              ),

                              isGlow: true,
                            ),
                          ),

                          // LINE
                          CustomPaint(
                            size: const Size(
                              double.infinity,
                              250,
                            ),

                            painter:
                                BreathingWavePainter(
                              animationValue:
                                  _controller.value,

                              color: kRosePink,
                            ),
                          ),

                          // ICON
                          Positioned(
                            bottom:
                                50 +
                                (_controller.value * 120),

                            child: Container(
                              padding:
                                  const EdgeInsets.all(12),

                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withOpacity(
                                  0.15,
                                ),

                                shape: BoxShape.circle,

                                border: Border.all(
                                  color: Colors.white30,
                                ),

                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        kRosePink.withOpacity(
                                      0.3,
                                    ),

                                    blurRadius: 15,

                                    spreadRadius: 2,
                                  )
                                ],
                              ),

                              child: const Icon(
                                Icons.spa,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                _buildSelesaiButton(),
              ],
            ),
          ),

          // =========================
          // OVERLAY AWAL
          // =========================
          if (!isStarted)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),

                child: Container(
                  color:
                      kMidnightBlue.withOpacity(0.6),

                  child: Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        const Icon(
                          Icons.spa_outlined,
                          color: kRosePink,
                          size: 80,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Ambil Posisi Nyaman",

                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Tekan tombol di bawah untuk memulai",

                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: startSession,

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                kRosePink,

                            foregroundColor:
                                Colors.white,

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 18,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                            ),

                            elevation: 15,

                            shadowColor:
                                kRosePink.withOpacity(
                              0.5,
                            ),
                          ),

                          child: const Text(
                            "MULAI SEKARANG",

                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,

                              letterSpacing: 1.5,

                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // =========================
  // BUTTON BATAL
  // =========================
  Widget _buildSelesaiButton() {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 80,
      ),

      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(20),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5,
            sigmaY: 5,
          ),

          child: Container(
            height: 50,

            width: double.infinity,

            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(0.08),

              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(
                color: Colors.white12,
              ),
            ),

            child: TextButton(
              onPressed: () => Get.back(),

              child: const Text(
                "BATALKAN",

                style: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM PAINTER
// ==========================================

class BreathingWavePainter extends CustomPainter {

  final double animationValue;

  final Color color;

  final bool isGlow;

  BreathingWavePainter({
    required this.animationValue,
    required this.color,
    this.isGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          isGlow ? 8.0 : 4.0
      ..strokeCap = StrokeCap.round;

    if (isGlow) {

      paint.maskFilter =
          const MaskFilter.blur(
        BlurStyle.normal,
        10,
      );
    }

    final path = Path();

    double baseY =
        size.height * 0.8;

    path.moveTo(0, baseY);

    for (double i = 0;
        i <= size.width;
        i++) {

      double relativeX =
          i / size.width;

      double sinValue =
          math.sin(relativeX * math.pi);

      double y =
          baseY -
          (sinValue *
              (animationValue *
                  size.height *
                  0.6));

      path.lineTo(i, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
      covariant BreathingWavePainter oldDelegate) {

    return oldDelegate.animationValue !=
        animationValue;
  }
}