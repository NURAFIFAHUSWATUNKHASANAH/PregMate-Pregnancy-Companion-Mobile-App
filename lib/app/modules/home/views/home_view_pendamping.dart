import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:PregMate/config/api_config.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import 'package:PregMate/app/modules/artikel/controllers/artikel_controller.dart';
import 'package:PregMate/app/modules/artikel/views/all_articles_view.dart';
import 'package:PregMate/app/modules/artikel/views/article_detail_view.dart';

class HomeViewPendamping extends StatelessWidget {
  HomeViewPendamping({Key? key}) : super(key: key);

  final ProfileController profileController = Get.find<ProfileController>();
  final ArtikelController artikelController = Get.put(ArtikelController());

  @override
  Widget build(BuildContext context) {
    artikelController.fetchArtikels();
    _updateTokenFCM();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            /// HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo Pendamping,",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Obx(() => Text(
                              profileController.namaC.value,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0C2D57),
                              ),
                            )),
                      ],
                    ),

                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline,
                          color: Color(0xFF0C2D57)),
                    )
                  ],
                ),
              ),
            ),

            /// HERO BANNER
            SliverToBoxAdapter(
              child: _buildHeroBanner(),
            ),

            /// MENU KHUSUS AYAH
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [

                    _buildMenu(
                      label: "Pantau Ibu",
                      icon: Icons.favorite_outline,
                      color: Colors.redAccent,
                      onTap: () {
                        Get.snackbar("Info", "Fitur monitoring ibu");
                      },
                    ),

                    _buildMenu(
                      label: "Jadwal Ibu",
                      icon: Icons.calendar_today,
                      color: Colors.teal,
                      onTap: () {
                        Get.snackbar("Info", "Lihat jadwal latihan ibu");
                      },
                    ),

                    _buildMenu(
                      label: "Tips Ayah",
                      icon: Icons.lightbulb_outline,
                      color: Colors.orange,
                      onTap: () {
                        Get.snackbar("Info", "Tips mendampingi ibu");
                      },
                    ),

                    _buildMenu(
                      label: "Mood Ibu",
                      icon: Icons.emoji_emotions_outlined,
                      color: Colors.pinkAccent,
                      onTap: () {
                        Get.snackbar("Info", "Mood ibu hari ini");
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// ARTIKEL SECTION
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    const Text(
                      "Edukasi Kehamilan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),

                    TextButton(
                      onPressed: () => Get.to(() => AllArtikelView()),
                      child: const Text("Lihat Semua"),
                    ),
                  ],
                ),
              ),
            ),

            /// LIST ARTIKEL
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: Obx(() {

                  if (artikelController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: artikelController.artikels.length > 5
                        ? 5
                        : artikelController.artikels.length,
                    itemBuilder: (context, index) {
                      return _buildArticleCard(
                        artikelController.artikels[index],
                      );
                    },
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 30),
            ),
          ],
        ),
      ),
    );
  }

  /// HERO BANNER
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0C2D57),
            Color(0xFF4CAF50),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Dukungan Ayah\nSangat Berarti\nUntuk Ibu & Bayi.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// MENU
  Widget _buildMenu({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  /// CARD ARTIKEL
  Widget _buildArticleCard(artikel) {
    return GestureDetector(
      onTap: () => Get.to(() => ArtikelDetailView(id: artikel.id)),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          children: [

            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: artikel.imageUrl.isNotEmpty
                    ? Image.network(
                        artikel.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(color: Colors.grey[200]),
              ),
            ),

            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      artikel.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      "Baca Artikel >",
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// UPDATE TOKEN FCM
  Future<void> _updateTokenFCM() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('_id');

    if (userId == null || userId.isEmpty) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse(ApiConfig.updateTokenUri),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'token': token,
          }),
        );
      }
    } catch (e) {
      debugPrint('Error update token: $e');
    }
  }
}