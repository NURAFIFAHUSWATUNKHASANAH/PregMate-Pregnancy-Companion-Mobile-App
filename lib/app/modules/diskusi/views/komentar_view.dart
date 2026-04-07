import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/config/api_config.dart';
import '../controllers/diskusi_controller.dart';
import '../models/post_model.dart';

class KomentarView extends StatelessWidget {
  final Post post;

  KomentarView({required this.post});

  final DiskusiController controller = Get.find();
  final TextEditingController commentController = TextEditingController();

  final Color primaryBlue = const Color(0xFF0C2D57);
  final Color secondaryBlue = const Color(0xFF4361EE);
  final Color bgLight = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  final Color textGrey = const Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,

      /// =========================
      /// APPBAR
      /// =========================
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
          if (post.userId == controller.userId.value)
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: primaryBlue),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: "edit",
                  child: Text("Edit Diskusi"),
                ),
                const PopupMenuItem(
                  value: "delete",
                  child: Text("Hapus Diskusi"),
                ),
              ],
              onSelected: (value) {
                if (value == "edit") {
                  _showEditDialog();
                }

                if (value == "delete") {
                  Get.defaultDialog(
                    title: "Hapus Diskusi",
                    middleText: "Yakin ingin menghapus diskusi ini?",
                    textConfirm: "Hapus",
                    textCancel: "Batal",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      controller.deletePost(post.id);
                      Get.back();
                      Get.back();
                    },
                  );
                }
              },
            ),
        ],
      ),

      /// =========================
      /// BODY
      /// =========================
      body: Column(
        children: [

          Expanded(
            child: Obx(() {

              /// ambil post terbaru dari controller
              final updatedPost = controller.posts.firstWhere(
                (p) => p.id == post.id,
                orElse: () => post,
              );

              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [

                  /// ================================
                  /// POST HEADER
                  /// ================================
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
                              radius: 20,
                              backgroundColor: bgLight,
                              backgroundImage:
                                  updatedPost.userPhoto != null &&
                                          updatedPost.userPhoto!.isNotEmpty
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
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Penanya Utama",
                                  style: TextStyle(
                                    color: secondaryBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  /// ================================
                  /// LABEL KOMENTAR
                  /// ================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          "Komentar",
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
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

                  /// ================================
                  /// LIST KOMENTAR
                  /// ================================
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: updatedPost.comments.length,
                    itemBuilder: (context, index) {

                      final c = updatedPost.comments[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            CircleAvatar(
                              radius: 16,
                              backgroundColor: bgLight,
                              backgroundImage:
                                  c.userPhoto != null &&
                                          c.userPhoto!.isNotEmpty
                                      ? NetworkImage(
                                          "${ApiConfig.baseUrl}/${c.userPhoto}")
                                      : null,
                              child: (c.userPhoto == null ||
                                      c.userPhoto!.isEmpty)
                                  ? Icon(Icons.person,
                                      size: 16, color: textGrey)
                                  : null,
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    c.user,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textDark,
                                        fontSize: 14),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    c.content,
                                    style: TextStyle(
                                        color: textGrey,
                                        fontSize: 14,
                                        height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),

          /// ================================
          /// INPUT KOMENTAR
          /// ================================
          Container(
            padding: EdgeInsets.fromLTRB(
                20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
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
                    ),

                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Berikan tanggapan Bunda...",
                        hintStyle: TextStyle(
                            color: textGrey.withOpacity(0.6), fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                GestureDetector(
                  onTap: () async {

                    if (commentController.text.isNotEmpty) {

                      await controller.addComment(
                        post.id,
                        commentController.text,
                      );

                      commentController.clear();
                    }
                  },

                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryBlue,
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// EDIT DIALOG
  /// =========================
  void _showEditDialog() {

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

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {

              controller.editPost(
                post.id,
                editController.text,
              );

              Get.back();
              Get.back();

            },

            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}