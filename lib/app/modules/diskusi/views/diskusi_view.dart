import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/config/api_config.dart';
import '../controllers/diskusi_controller.dart';
import '../models/post_model.dart';
import 'komentar_view.dart';
import 'dart:ui';

// --- UTILITY FUNCTIONS ---
String formatTanggal(String isoDate) {
  try {
    final date = DateTime.parse(isoDate).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m lalu";
    if (diff.inHours < 24) return "${diff.inHours}j lalu";
    if (diff.inDays < 7) return "${diff.inDays}h lalu";
    return "${date.day} ${_bulanIndo(date.month)} ${date.year}";
  } catch (e) {
    return "";
  }
}

String _bulanIndo(int bulan) {
  const namaBulan = [
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des"
  ];
  return namaBulan[bulan];
}

class DiskusiView extends StatelessWidget {
  DiskusiView({Key? key}) : super(key: key);

  final DiskusiController controller = Get.put(DiskusiController());

  // Modern Color Palette
  final Color primaryBlue = const Color(0xFF0C2D57);
  final Color accentBlue = const Color(0xFF4361EE);
  final Color softPink = const Color(0xFFFF8E9E);
  final Color bgLight = const Color(0xFFFBFDFF);
  final Color textDark = const Color(0xFF0F172A);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white.withOpacity(0.8),
          surfaceTintColor: Colors.transparent,
          flexibleSpace: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
          centerTitle: false,
          title: Text(
            "Forum Bunda",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),

          bottom: TabBar(
            labelColor: primaryBlue,
            unselectedLabelColor: textGrey,
            indicatorColor: primaryBlue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            tabs: const [
              Tab(text: "Eksplorasi"),
              Tab(text: "Diskusi Saya"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: SEMUA DISKUSI
            Obx(() {
              if (controller.isLoading.value) return _buildShimmerLoading();
              return RefreshIndicator(
                onRefresh: () async => controller.fetchPosts(),
                color: primaryBlue,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.posts.length,
                  itemBuilder: (context, index) =>
                      _buildPostCard(controller.posts[index]),
                ),
              );
            }),

            // TAB 2: DISKUSI SAYA
            Obx(() {
              if (controller.isLoading.value) return _buildShimmerLoading();

              return SafeArea(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  children: [
                    _buildPostInput(),
                    controller.myPosts.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: controller.myPosts.length,
                            itemBuilder: (context, index) =>
                                _buildGridPostCard(controller.myPosts[index]),
                          ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              size: 64, color: textGrey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("Belum ada diskusi nih, Bun",
              style: TextStyle(color: textGrey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // --- TAB DISKUSI SAYA: GRID CARD ---
  Widget _buildGridPostCard(Post post) {
    return GestureDetector(
      onTap: () => Get.to(() => KomentarView(post: post),
          transition: Transition.cupertino),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              post.image != null && post.image!.isNotEmpty
                  ? Image.network("${ApiConfig.baseUrl}${post.image}",
                      fit: BoxFit.cover)
                  : Container(
                      padding: const EdgeInsets.all(10),
                      color: accentBlue.withOpacity(0.1),
                      child: Center(
                        child: Text(
                          post.content,
                          maxLines: 4,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              color: primaryBlue,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ]),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Text(post.likes.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
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

  // --- INPUT POST CARD ---
  Widget _buildPostInput() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PREVIEW GAMBAR
            Obx(() => controller.selectedImage.value != null
                ? Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: FileImage(controller.selectedImage.value!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: _buildCloseBtn(
                          () => controller.selectedImage.value = null,
                        ),
                      ),
                    ],
                  )
                : const SizedBox()),

            /// INPUT TEXT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => CircleAvatar(
                      radius: 22,
                      backgroundColor: bgLight,
                      backgroundImage: controller.fotoUser.value.isNotEmpty
                          ? NetworkImage(
                              "${ApiConfig.baseUrl}/${controller.fotoUser.value}")
                          : null,
                      child: controller.fotoUser.value.isEmpty
                          ? Icon(Icons.person_2_rounded, color: textGrey)
                          : null,
                    )),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller.postController,
                    maxLines: null,
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Apa yang Bunda pikirkan?",
                      hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24, thickness: 0.5),

            /// ACTION BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.image_outlined, size: 20, color: accentBlue),
                        const SizedBox(width: 8),
                        Text(
                          "Foto",
                          style: TextStyle(
                            color: accentBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// BUTTON POST
                ElevatedButton(
                  onPressed: () => controller.addPost(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Posting",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SEMUA DISKUSI: MAIN CARD ---
  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: primaryBlue.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: softPink, width: 2)),
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    post.userPhoto != null && post.userPhoto!.isNotEmpty
                        ? NetworkImage("${ApiConfig.baseUrl}/${post.userPhoto}")
                        : null,
                child: (post.userPhoto == null || post.userPhoto!.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
            title: Text(post.user,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    fontSize: 15)),
            subtitle: Text(formatTanggal(post.tanggal),
                style: TextStyle(fontSize: 11, color: textGrey)),
            trailing: post.userId == controller.userId.value
                ? _buildPostMenu(post)
                : null,
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(post.content,
                  style: TextStyle(
                      color: textDark.withOpacity(0.8),
                      fontSize: 15,
                      height: 1.5)),
            ),
          if (post.image != null && post.image!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network("${ApiConfig.baseUrl}${post.image}",
                    width: double.infinity, height: 280, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionBtn(
                  icon: post.likedBy.contains(controller.userId.value)
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  label: post.likes.toString(),
                  color: Colors.pinkAccent,
                  onTap: () => controller.likePost(post.id),
                ),
                const SizedBox(width: 12),
                _buildActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: "Diskusi",
                  color: accentBlue,
                  onTap: () => Get.to(() => KomentarView(post: post),
                      transition: Transition.cupertino),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMenu(Post post) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Icons.more_horiz_rounded, color: textGrey),
      itemBuilder: (context) => [
        const PopupMenuItem(
            value: "edit",
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text("Edit")
            ])),
        const PopupMenuItem(
            value: "delete",
            child: Row(children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              SizedBox(width: 8),
              Text("Hapus", style: TextStyle(color: Colors.red))
            ])),
      ],
      onSelected: (val) {
        if (val == "delete") {
          // GANTI DARI Get.defaultDialog KE SINI:
          _showDeletePostConfirmation(post.id);
        } else {
          _showEditDialog(post);
        }
      },
    );
  }

// --- FUNCTION: DIALOG HAPUS POSTINGAN ---
  void _showDeletePostConfirmation(String postId) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Icon(Icons.delete_sweep_rounded,
                color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              "Hapus Diskusi?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Apakah Bunda yakin ingin menghapus postingan ini secara permanen? Seluruh komentar di dalamnya juga akan ikut terhapus.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textGrey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text("Batal", style: TextStyle(color: textDark)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.deletePost(postId);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text("Hapus Postingan",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildActionBtn(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.black.withOpacity(0.5),
          child: const Icon(Icons.close, size: 16, color: Colors.white)),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        height: 250,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void _showEditDialog(Post post) {
    TextEditingController editController =
        TextEditingController(text: post.content);
    controller.selectedImage.value = null;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Diskusi",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: primaryBlue)),
              const SizedBox(height: 20),
              Obx(() => controller.selectedImage.value != null
                  ? Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: FileImage(controller.selectedImage.value!),
                              fit: BoxFit.cover)),
                    )
                  : const SizedBox()),
              TextField(
                controller: editController,
                maxLines: 4,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: bgLight,
                  hintText: "Edit pesan Bunda...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton.filledTonal(
                      onPressed: () => controller.pickImage(),
                      icon: const Icon(Icons.add_a_photo_rounded)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      controller.editPost(post.id, editController.text);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: const Text("Simpan Perubahan"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
