import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/config/api_config.dart';

import '../controllers/diskusi_controller.dart';
import '../models/post_model.dart';
import 'komentar_view.dart';

String formatTanggal(String isoDate) {
  try {
    final date = DateTime.parse(isoDate).toLocal();
    final now = DateTime.now();

    final diff = now.difference(date);

    if (diff.inSeconds < 60) {
      return "Baru saja";
    } else if (diff.inMinutes < 60) {
      return "${diff.inMinutes} menit lalu";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} jam lalu";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} hari lalu";
    } else {
      return "${date.day} ${_bulanIndo(date.month)} ${date.year}";
    }
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

  final Color primaryBlue = const Color(0xFF0C2D57);
  final Color secondaryBlue = const Color(0xFF4361EE);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            "Forum Bunda",
            style: TextStyle(
              color: primaryBlue,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_rounded, color: primaryBlue),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            labelColor: primaryBlue,
            indicatorColor: primaryBlue,
            tabs: const [
              Tab(text: "Semua Diskusi"),
              Tab(text: "Diskusi Saya"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            /// =====================
            /// TAB 1: SEMUA DISKUSI (LIST VIEW)
            /// =====================
            Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerLoading();
              }
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  final post = controller.posts[index];
                  return _buildPostCard(post);
                },
              );
            }),

            /// =====================
            /// TAB 2: DISKUSI SAYA (GRID VIEW - ALA IG)
            /// =====================
            Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerLoading();
              }

              return Column(
                children: [
                  _buildPostInput(),
                  Expanded(
                    child: controller.myPosts.isEmpty
                        ? const Center(
                            child: Text("Belum ada diskusi yang Anda buat"),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 kolom kesamping
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1, // Kotak sempurna
                            ),
                            itemCount: controller.myPosts.length,
                            itemBuilder: (context, index) {
                              final post = controller.myPosts[index];
                              return _buildGridPostCard(post);
                            },
                          ),
                  )
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// GRID POST CARD (KHUSUS TAB DISKUSI SAYA)
  /// =========================
  Widget _buildGridPostCard(Post post) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => KomentarView(post: post),
          transition: Transition.cupertino,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Prioritas tampilkan gambar, jika tidak ada tampilkan teks konten
              post.image != null && post.image!.isNotEmpty
                  ? Image.network(
                      "${ApiConfig.baseUrl}${post.image}",
                      fit: BoxFit.cover,
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      color: secondaryBlue.withOpacity(0.05),
                      child: Center(
                        child: Text(
                          post.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: textDark),
                        ),
                      ),
                    ),

              // Overlay Icon Like di pojok bawah
              Positioned(
                bottom: 4,
                left: 6,
                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.pink, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      post.likes.toString(),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// INPUT POST
  /// =========================
  Widget _buildPostInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => controller.selectedImage.value != null
              ? Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(controller.selectedImage.value!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () => controller.selectedImage.value = null,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox()),
          Row(
            children: [
              Obx(() => CircleAvatar(
                    radius: 22,
                    backgroundColor: bgLight,
                    backgroundImage: controller.fotoUser.value.isNotEmpty
                        ? NetworkImage(
                            "${ApiConfig.baseUrl}/${controller.fotoUser.value}")
                        : null,
                    child: controller.fotoUser.value.isEmpty
                        ? Icon(Icons.person_rounded, color: textGrey)
                        : null,
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.postController,
                  decoration: InputDecoration(
                    hintText: "Apa kabar hari ini, Bunda?",
                    hintStyle: TextStyle(color: textGrey.withOpacity(0.6)),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                onPressed: () => controller.pickImage(),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                style: IconButton.styleFrom(foregroundColor: secondaryBlue),
              ),
              ElevatedButton(
                onPressed: () => controller.addPost(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: const Text("Posting",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// =========================
  /// POST CARD (UNTUK TAB SEMUA DISKUSI)
  /// =========================
  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  post.userPhoto != null && post.userPhoto!.isNotEmpty
                      ? NetworkImage("${ApiConfig.baseUrl}/${post.userPhoto}")
                      : null,
              child: (post.userPhoto == null || post.userPhoto!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(post.user,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              formatTanggal(post.tanggal),
              style: const TextStyle(fontSize: 11),
            ),
            trailing: post.userId == controller.userId.value
                ? PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: "edit",
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Text("Hapus"),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == "delete") {
                        Get.defaultDialog(
                          title: "Hapus Post",
                          middleText: "Yakin ingin menghapus postingan?",
                          textConfirm: "Hapus",
                          textCancel: "Batal",
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            controller.deletePost(post.id);

                            Get.back();
                          },
                        );
                      }

                      if (value == "edit") {
                        _showEditDialog(post);
                      }
                    },
                  )
                : const SizedBox(),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.content,
                style: TextStyle(color: textDark, height: 1.4),
              ),
            ),
          if (post.image != null && post.image!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  "${ApiConfig.baseUrl}${post.image}",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildActionBtn(
                  icon: post.likedBy.contains(controller.userId.value)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: post.likes.toString(),
                  color: Colors.pink,
                  onTap: () => controller.likePost(post.id),
                ),
                const SizedBox(width: 12),
                _buildActionBtn(
                  icon: Icons.mode_comment_outlined,
                  label: "Diskusi",
                  color: secondaryBlue,
                  onTap: () {
                    Get.to(
                      () => KomentarView(post: post),
                      transition: Transition.cupertino,
                      duration: const Duration(milliseconds: 400),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Opacity(
          opacity: 0.5,
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(backgroundColor: bgLight),
                title: Container(height: 10, color: bgLight),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: bgLight, borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Post post) {
    TextEditingController editController =
        TextEditingController(text: post.content);

    Get.defaultDialog(
      title: "Edit Diskusi",
      content: Column(
        children: [
          TextField(
            controller: editController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Edit diskusi...",
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              controller.editPost(
                post.id,
                editController.text,
              );

              Get.back();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
