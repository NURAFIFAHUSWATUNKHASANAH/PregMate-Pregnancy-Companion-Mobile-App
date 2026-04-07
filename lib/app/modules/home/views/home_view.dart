import 'dart:convert';
import 'package:PregMate/app/modules/tips_newborn/views/tips_newborn_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:PregMate/app/modules/artikel/views/article_detail_view.dart';
import 'package:PregMate/app/modules/diskusi/bindings/diskusi_binding.dart';
import 'package:PregMate/app/modules/diskusi/views/diskusi_view.dart';
import 'package:PregMate/app/modules/meditation/bindings/meditation_binding.dart';
import 'package:PregMate/app/modules/meditation/views/meditation_view.dart';
import 'package:PregMate/app/modules/mood/controllers/mood_controller.dart';
import 'package:PregMate/app/modules/mood/views/mood_view.dart';
import 'package:PregMate/app/modules/nama_bayi/bindings/nama_bayi_binding.dart';
import 'package:PregMate/app/modules/nama_bayi/views/nama_bayi_view.dart';
import 'package:PregMate/app/routes/app_pages.dart';
import 'package:PregMate/config/api_config.dart';
import 'dart:math' as math;
import 'package:PregMate/app/modules/jadwal/controllers/jadwal_controller.dart';
import 'package:PregMate/app/modules/keluhan/controllers/keluhan_controller.dart';
import 'package:PregMate/app/modules/profil/controllers/profil_controller.dart';
import '../controllers/home_controller.dart';
import 'package:PregMate/app/modules/artikel/controllers/artikel_controller.dart';
import 'package:PregMate/app/modules/artikel/views/all_articles_view.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);

  final RxString role = "".obs;

  Future<void> loadRole() async {
    final box = GetStorage();
    role.value = box.read("user_role") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    loadRole();

    Get.lazyPut(() => KeluhanController());
    final profileController = Get.find<ProfileController>();
    final JadwalController jadwalController = Get.put(JadwalController());
    final ArtikelController artikelController = Get.put(ArtikelController());
    artikelController.fetchArtikels();

    _updateTokenFCM();

    const Color primaryColor = Color(0xFF0C2D57);
    const Color secondaryColor = Color(0xFF163E72); // Biru sedikit lebih terang

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Aesthetic Decor
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, secondaryColor],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          // Subtle Circle Pattern
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                /// HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          // ⚡ Ini kunci
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Halo, ${getGreeting()}",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                    profileController.namaC.value,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // 🔹 agar tidak overflow
                                    maxLines: 1,
                                  )),
                            ],
                          ),
                        ),
                        _buildProfileAvatar(Colors.white),
                      ],
                    ),
                  ),
                ),

                /// DASHBOARD KEHAMILAN (Elevated Card)
                SliverToBoxAdapter(
                  child: Obx(() {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                role.value == "pendamping"
                                    ? "Status Kehamilan Pasangan"
                                    : "Status Kehamilan",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor),
                              ),

                              /// 👇 INI MENU TITIK 3 (HANYA UNTUK IBU)
                              Obx(() => role.value == "ibu"
                                  ? PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert,
                                          color: primaryColor),
                                      onSelected: (value) {
                                        if (value == "edit") {
                                          _showEditDialog(context);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: "edit",
                                          child: Text("Edit Data Kehamilan"),
                                        ),
                                      ],
                                    )
                                  : const Icon(Icons.auto_graph_rounded,
                                      color: primaryColor, size: 20)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildDashboardRow(
                            "Usia Janin",
                            "${controller.usiaMinggu} Minggu ${controller.usiaHari} Hari",
                            Icons.child_friendly_rounded,
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildDashboardInfoSmall("Trimester",
                                      controller.trimester.toString())),
                              Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.grey[200]),
                              Expanded(
                                  child: _buildDashboardInfoSmall(
                                      "HPL", controller.hpl.toString())),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Obx(() {
                            double progress = controller.usiaMinggu.value / 40;
                            if (progress > 1) progress = 1;
                            return Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.blue[50],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            primaryColor),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Progress",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600])),
                                    Text("${(progress * 100).toInt()}%",
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ),

                /// MENU GRID
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Obx(() {
                      List<Widget> menus = [];
                      if (role.value == "ibu") {
                        menus.add(_buildGridMenu(
                            label: "Senam",
                            icon: Icons.self_improvement,
                            color: const Color(0xFF4A90E2),
                            onTap: () => Get.toNamed(Routes.SENAM)));
                        menus.add(_buildGridMenu(
                            label: "Daily Check",
                            icon: Icons.favorite,
                            color: const Color(0xFFFF6B6B),
                            onTap: () {
                              if (!Get.isRegistered<MoodController>())
                                Get.put(MoodController());
                              Get.to(() => MoodView());
                            }));
                        menus.add(_buildGridMenu(
                            label: "Berat Badan",
                            icon: Icons.monitor_weight,
                            color: const Color(0xFF4CAF50),
                            onTap: () => Get.toNamed(Routes.BERAT_BADAN)));
                        menus.add(
                          _buildGridMenu(
                            label: "Forum Bunda",
                            icon: Icons.forum,
                            color: Colors.indigo,
                            onTap: () => Get.to(() => DiskusiView(),
                                binding: DiskusiBinding()),
                          ),
                        );
                        menus.add(_buildGridMenu(
                            label: "Ruang Napas",
                            icon: Icons.spa,
                            color: const Color(0xFF9C27B0),
                            onTap: () => Get.to(() => MeditationView(),
                                binding: MeditationBinding())));
                      }

                      if (role.value == "pendamping") {
                        menus.add(_buildGridMenu(
                            label: "Berat Badan",
                            icon: Icons.monitor_weight,
                            color: const Color(0xFF4CAF50),
                            onTap: () => Get.toNamed(Routes.BERAT_BADAN)));
                        menus.add(_buildGridMenu(
                            label: "History",
                            icon: Icons.history_rounded,
                            color: const Color(0xFF607D8B),
                            onTap: () => Get.toNamed(Routes.HISTORI)));
                      }

                      menus.addAll([
                        _buildGridMenu(
                            label: "Pengingat",
                            icon: Icons.calendar_month,
                            color: const Color(0xFF009688),
                            onTap: () => jadwalController.showJadwalDialog()),
                        _buildGridMenu(
                            label: "Janin",
                            icon: Icons.child_care,
                            color: const Color(0xFFFF9800),
                            onTap: () => Get.toNamed(Routes.UKURAN_JANIN)),
                        _buildGridMenu(
                            label: "Nama",
                            icon: Icons.auto_awesome,
                            color: const Color(0xFF673AB7),
                            onTap: () => Get.to(() => NamaBayiView(),
                                binding: NamaBayiBinding())),
                        _buildGridMenu(
                            label: "Artikel",
                            icon: Icons.description_rounded,
                            color: const Color(0xFF2196F3),
                            onTap: () => Get.to(() => AllArtikelView())),
                        _buildGridMenu(
                          label: "Tas Bersalin",
                          icon: Icons.checklist_rounded,
                          color: const Color(0xFFE91E63),
                          onTap: () {
                            Get.snackbar(
                              "Coming Soon 🚧",
                              "Fitur persiapan persalinan sedang dikembangkan",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
_buildGridMenu(
  label: "Tips Newborn",
  icon: Icons.baby_changing_station_rounded,
  color: const Color(0xFF00BCD4),
  onTap: () {
    // Navigasi menggunakan route name
    Get.toNamed('/tips-newborn');
  },
),
                        // _buildGridMenu(
                        //   label: "Tips Perawatan Newborn",
                        //   icon: Icons.baby_changing_station_rounded,
                        //   color: const Color(
                        //       0xFF00BCD4), // warna biru muda, bisa diganti
                        //   onTap: () {
                        //     Get.snackbar(
                        //       "Coming Soon 🚧",
                        //       "Fitur Perawatan Newborn persalinan sedang dikembangkan",
                        //       snackPosition: SnackPosition.BOTTOM,
                        //     );
                        //   },
                        // ),
                      ]);
                      return GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                        children: menus,
                      );
                    }),
                  ),
                ),

                /// SECTION TITLE ARTIKEL
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edukasi Pilihan",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        TextButton(
                          onPressed: () => Get.to(() => AllArtikelView()),
                          child: const Text("Lihat Semua",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.blue)),
                        )
                      ],
                    ),
                  ),
                ),

                /// HORIZONTAL ARTIKEL
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: Obx(() {
                      if (artikelController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: artikelController.artikels.length > 5
                            ? 5
                            : artikelController.artikels.length,
                        itemBuilder: (context, index) {
                          return _buildModernArticleCard(
                              artikelController.artikels[index]);
                        },
                      );
                    }),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardRow(String title, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: const Color(0xFF0C2D57).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: const Color(0xFF0C2D57)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardInfoSmall(String title, String value) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C2D57))),
      ],
    );
  }

  Widget _buildGridMenu(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(Color color) {
    final profileController = Get.find<ProfileController>();

    return Obx(() {
      final foto = profileController.foto.value;

      return Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white24,
          backgroundImage: (foto.isNotEmpty) ? NetworkImage(foto) : null,
          child: (foto.isEmpty)
              ? const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 26,
                )
              : null,
        ),
      );
    });
  }

  Widget _buildModernArticleCard(artikel) {
    return GestureDetector(
      onTap: () => Get.to(() => ArtikelDetailView(id: artikel.id)),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: artikel.imageUrl.isNotEmpty
                    ? Image.network(artikel.imageUrl,
                        fit: BoxFit.cover, width: double.infinity)
                    : Container(color: Colors.grey[200]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                artikel.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _updateTokenFCM() async {
    final box = GetStorage();
    final userId = box.read('user_id');
    if (userId == null || userId.isEmpty) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse(ApiConfig.updateTokenUri),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_id': userId, 'token': token}),
        );
      }
    } catch (e) {
      debugPrint('Error update token: $e');
    }
  }

  void _showEditDialog(BuildContext context) {
    final c = Get.find<HomeController>();
    final TextEditingController hphtController =
        TextEditingController(text: c.hpht.value);

    // Warna tema dari HomeView Anda
    const Color primaryColor = Color(0xFF0C2D57);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar (Garis kecil di atas)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Update Data Kehamilan",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Masukkan tanggal Hari Pertama Haid Terakhir (HPHT) Anda untuk menghitung usia janin.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Input Field yang Estetik
            GestureDetector(
              onTap: () async {
                final picked = await _pickDate(context, c.hpht.value);
                if (picked != null) {
                  hphtController.text = _formatDate(picked);
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: hphtController,
                  decoration: InputDecoration(
                    labelText: "Tanggal HPHT",
                    labelStyle: const TextStyle(color: primaryColor),
                    prefixIcon: const Icon(Icons.calendar_month_rounded,
                        color: primaryColor),
                    filled: true,
                    fillColor: primaryColor.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      side: const BorderSide(color: primaryColor),
                    ),
                    child: const Text("Batal",
                        style: TextStyle(color: primaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleSubmit(hphtController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Simpan Perubahan",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<bool> _updateKehamilan(String hpht) async {
    final box = GetStorage();
    final token = box.read('auth_token');

    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/pregnancy/update"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"hpht": hpht}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<DateTime?> _pickDate(BuildContext context, String currentValue) async {
    DateTime initialDate = DateTime.now();
    if (currentValue.isNotEmpty) {
      try {
        initialDate = DateTime.parse(currentValue);
      } catch (_) {}
    }

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0C2D57), // Header background
              onPrimary: Colors.white, // Header text
              onSurface: Color(0xFF0C2D57), // Body text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0C2D57)),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _handleSubmit(String hpht) async {
    if (hpht.isEmpty) {
      Get.snackbar("Error", "HPHT tidak boleh kosong");
      return;
    }

    try {
      final selected = DateTime.parse(hpht);
      final today = DateTime.now();

      final selectedDate =
          DateTime(selected.year, selected.month, selected.day);
      final todayDate = DateTime(today.year, today.month, today.day);

      if (selectedDate.isAfter(todayDate)) {
        Get.snackbar("Error", "HPHT tidak boleh melebihi hari ini");
        return;
      }

      /// 🔥 tampilkan loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await _updateKehamilan(hpht);

      /// 🔥 tutup loading
      if (Get.isDialogOpen ?? false) Get.back();

      if (success) {
        /// update dashboard
        await Get.find<HomeController>().fetchDashboardKehamilan();

        /// 🔥 INI KUNCI: tutup bottomSheet
        Get.back();

        Get.snackbar("Sukses", "HPHT berhasil diperbarui");
      } else {
        Get.snackbar("Error", "Gagal update HPHT");
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar("Error", "Format tanggal tidak valid");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Selamat Pagi";
    } else if (hour >= 12 && hour < 15) {
      return "Selamat Siang";
    } else if (hour >= 15 && hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }
}
