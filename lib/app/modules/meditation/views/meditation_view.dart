import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/meditation_controller.dart';
import 'breathing_session_view.dart';

class MeditationView extends GetView<MeditationController> {
  const MeditationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color kMidnightBlue = Color(0xFF0C2D57);
    const Color kRosePink = Color(0xFFFF8E9E);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kMidnightBlue.withOpacity(0.05),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 18, color: kMidnightBlue),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const Text(
          "Relaksasi Bunda",
          style: TextStyle(
            color: kMidnightBlue,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: kRosePink),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: controller.breathingSessions.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final session = controller.breathingSessions[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildMeditationCard(
                context,
                title: session["title"] ?? "Meditasi",
                desc: session["description"] ?? "Ketuk untuk memulai sesi",
                duration: "${session["duration"] ?? 60} dtk",
                blue: kMidnightBlue,
                pink: kRosePink,
                onTap: () {
                  Get.to(() => BreathingSessionView(
                        title: session["title"] ?? "Meditasi",
                        duration: session["duration"] ?? 60,
                        inhaleDuration: session["inhale_duration"] ?? 4,
                        exhaleDuration: session["exhale_duration"] ?? 4,
                      ));
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildMeditationCard(
    BuildContext context, {
    required String title,
    required String desc,
    required String duration,
    required Color blue,
    required Color pink,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: blue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Illustration
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.self_improvement, color: pink, size: 32),
                ),
                const SizedBox(width: 20),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: blue.withOpacity(0.5),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Duration Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: blue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 14, color: blue.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: blue.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Play Button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
