import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/config/api_config.dart';
import '../controllers/diskusi_controller.dart';
import '../models/post_model.dart';

class KomentarView extends StatelessWidget {
  final Post post;

  KomentarView({super.key, required this.post});

  final DiskusiController controller = Get.find();
  final TextEditingController commentController = TextEditingController();

  // Color Palette
  final Color primaryBlue = const Color(0xFF0C2D57);
  final Color secondaryBlue = const Color(0xFF4361EE);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryBlue, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Diskusi Bunda",
          style: TextStyle(
            color: primaryBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Menampilkan menu hanya jika ini postingan milik user yang login
          if (post.userId == controller.userId.value)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: primaryBlue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == "edit") {
                  _showEditDialog(context);
                } else if (value == "delete") {
                  _showDeleteConfirmation();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Edit Diskusi"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Hapus Diskusi",
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              // Reaktif terhadap perubahan data post di controller
              final updatedPost = controller.posts.firstWhere(
                (p) => p.id == post.id,
                orElse: () => post,
              );

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  /// POST DETAIL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: bgLight,
                              backgroundImage: (updatedPost.userPhoto != null &&
                                      updatedPost.userPhoto!.isNotEmpty)
                                  ? NetworkImage(
                                      "${ApiConfig.baseUrl}/${updatedPost.userPhoto}")
                                  : null,
                              child: (updatedPost.userPhoto == null ||
                                      updatedPost.userPhoto!.isEmpty)
                                  ? Icon(Icons.person, color: textGrey)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  updatedPost.user,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textDark,
                                      fontSize: 16),
                                ),
                                Text(
                                  "Penanya Utama",
                                  style: TextStyle(
                                      color: secondaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          updatedPost.content,
                          style: TextStyle(
                              color: textDark, fontSize: 15, height: 1.5),
                        ),
                        if (updatedPost.image != null &&
                            updatedPost.image!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                "${ApiConfig.baseUrl}${updatedPost.image}",
                                width: double.infinity,
                                height: 220,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// SECTION KOMENTAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          "Komentar",
                          style: TextStyle(
                              color: textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            updatedPost.comments.length.toString(),
                            style: TextStyle(
                                color: secondaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// LIST KOMENTAR
                  if (updatedPost.comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                            "Belum ada tanggapan.\nJadilah yang pertama!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textGrey)),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: updatedPost.comments.length,
                      itemBuilder: (context, index) {
                        final c = updatedPost.comments[index];
                        return _buildCommentItem(c, index, updatedPost.id);
                      },
                    ),
                  const SizedBox(
                      height: 100), // Spasi agar tidak tertutup input
                ],
              );
            }),
          ),
        ],
      ),

      /// INPUT BAR
      bottomSheet: _buildInputBar(context),
    );
  }

  Widget _buildCommentItem(dynamic c, int index, String postId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // Ganti Row utama menjadi Column jika ingin konten di bawahnya tetap rapi
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // KUNCINYA DI SINI: Center agar foto dan nama sejajar tengah secara vertikal
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: bgLight,
                backgroundImage:
                    (c.userPhoto != null && c.userPhoto!.isNotEmpty)
                        ? NetworkImage("${ApiConfig.baseUrl}/${c.userPhoto}")
                        : null,
                child: (c.userPhoto == null || c.userPhoto!.isEmpty)
                    ? Icon(Icons.person, size: 16, color: textGrey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.user,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontSize: 14,
                  ),
                ),
              ),
              // Menu titik tiga tetap di pojok kanan sejajar nama
              if (c.userId == controller.userId.value)
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, size: 18, color: textGrey),
                  padding: EdgeInsets
                      .zero, // Menghilangkan padding bawaan agar lebih rapat
                  constraints:
                      const BoxConstraints(), // Memperkecil area klik sensor
                  onSelected: (value) {
                    if (value == "edit") {
                      _showEditCommentDialog(postId, index, c.content);
                    } else if (value == "delete") {
                      _showDeleteCommentConfirmation(postId, index);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: "edit", child: Text("Edit")),
                    PopupMenuItem(value: "delete", child: Text("Hapus")),
                  ],
                ),
            ],
          ),
          const SizedBox(
              height: 8), // Jarak antara Header (Foto+Nama) dengan Isi Komentar
          Padding(
            padding: const EdgeInsets.only(
                left:
                    44), // 16(radius*2) + 12(sizedbox) = 44 agar teks menjorok sejajar nama
            child: Text(
              c.content,
              style: TextStyle(
                color: textGrey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: TextField(
                controller: commentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Berikan tanggapan Bunda...",
                  hintStyle:
                      TextStyle(color: textGrey.withOpacity(0.6), fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              if (commentController.text.trim().isNotEmpty) {
                FocusScope.of(context).unfocus();
                await controller.addComment(
                    post.id, commentController.text.trim());
                commentController.clear();
              }
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: primaryBlue,
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

void _showDeleteCommentConfirmation(String postId, int index) {
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
          // Handle bar untuk estetika bottom sheet
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(
            "Hapus Komentar?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue, // Gunakan variabel warna Anda
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tindakan ini tidak dapat dibatalkan. Apakah Bunda yakin ingin menghapus tanggapan ini?",
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Text("Batal", style: TextStyle(color: textDark)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.deleteComment(postId, index);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.bold)),
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

  void _showEditCommentDialog(String postId, int index, String oldText) {
    final TextEditingController editController =
        TextEditingController(text: oldText);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit Komentar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 20),

              /// INPUT FIELD STYLE DISKUSI
              TextField(
                controller: editController,
                maxLines: 4,
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: "Edit tanggapan Bunda...",
                  hintStyle: TextStyle(color: textGrey.withOpacity(0.6)),
                  filled: true,
                  fillColor: bgLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// BUTTON ACTION (SAMAKAN DENGAN DISKUSI)
              Row(
                children: [
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (editController.text.trim().isNotEmpty) {
                        controller.editComment(
                          postId,
                          index,
                          editController.text.trim(),
                        );
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: MediaQuery.of(Get.context!).viewInsets.bottom,
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmation() {
    Get.defaultDialog(
      title: "Hapus Diskusi",
      middleText:
          "Yakin ingin menghapus diskusi ini? Tindakan ini tidak dapat dibatalkan.",
      textConfirm: "Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deletePost(post.id);
        Get.back(); // Tutup dialog
        Get.back(); // Kembali ke list diskusi
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController editController =
        TextEditingController(text: post.content);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Edit Postingan",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryBlue)),
            const SizedBox(height: 15),
            TextField(
              controller: editController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis perubahan...",
                filled: true,
                fillColor: bgLight,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  if (editController.text.trim().isNotEmpty) {
                    controller.editPost(post.id, editController.text.trim());
                    Get.back();
                  }
                },
                child: const Text("Simpan Perubahan",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
