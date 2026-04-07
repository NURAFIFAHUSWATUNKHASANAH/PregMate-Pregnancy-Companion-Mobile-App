import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:PregMate/app/modules/diskusi/models/post_model.dart';
import 'package:PregMate/config/api_config.dart';

class DiskusiController extends GetxController {

  /// =========================
  /// STORAGE (GET STORAGE ONLY)
  /// =========================
  final box = GetStorage();

  /// =========================
  /// STATE
  /// =========================
  var posts = <Post>[].obs;
  var myPosts = <Post>[].obs;
  var isLoading = true.obs;

  var namaUser = "".obs;
  var fotoUser = "".obs;
  var userId = "".obs;

  TextEditingController postController = TextEditingController();

  var selectedImage = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();

  /// =========================
  /// INIT
  /// =========================
  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  @override
  void onClose() {
    postController.dispose();
    super.onClose();
  }

  /// =========================
  /// LOAD USER (GET STORAGE)
  /// =========================
  Future<void> loadUser() async {

    userId.value = box.read("user_id") ?? "";
    namaUser.value = box.read("user_nama") ?? "";
    fotoUser.value = box.read("user_foto") ?? "";

    if (userId.value.isNotEmpty) {
      await fetchUserProfile();
      await fetchPosts();
    }
  }

  /// =========================
  /// GET TOKEN
  /// =========================
  String? getToken() {
    return box.read("auth_token");
  }

  /// =========================
  /// FETCH PROFILE
  /// =========================
  Future<void> fetchUserProfile() async {
    try {

      final token = getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/user/${userId.value}"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        namaUser.value = data["nama"] ?? "Pengguna";
        fotoUser.value = data["foto"] ?? "";

        box.write("user_nama", namaUser.value);
        box.write("user_foto", fotoUser.value);
      }

    } catch (e) {
      print("ERROR PROFILE: $e");
    }
  }

  /// =========================
  /// FETCH POSTS + FILTER OWNER
  /// =========================
  Future<void> fetchPosts() async {
    try {

      isLoading.value = true;

      final response = await http.get(
        Uri.parse(ApiConfig.diskusiUrl),
      );

      if (response.statusCode == 200) {

        List data = jsonDecode(response.body);

        posts.value = data.map((e) => Post.fromJson(e)).toList();

        /// 🔥 FIX: hanya post milik user
        myPosts.value = posts.where((post) {
          return post.userId.toString().trim() ==
              userId.value.toString().trim();
        }).toList();
      }

    } catch (e) {
      print("ERROR FETCH POSTS: $e");
    }

    isLoading.value = false;
  }

  /// =========================
  /// PICK IMAGE
  /// =========================
  Future pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  /// =========================
  /// ADD POST
  /// =========================
  Future<void> addPost() async {
    try {

      final token = getToken();

      var request = http.MultipartRequest(
        "POST",
        Uri.parse(ApiConfig.diskusiUrl),
      );

      request.headers["Authorization"] = "Bearer $token";

      request.fields["user_id"] = userId.value;
      request.fields["content"] = postController.text;

      if (selectedImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "image",
            selectedImage.value!.path,
          ),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        postController.clear();
        selectedImage.value = null;
        fetchPosts();
      }

    } catch (e) {
      print("ERROR ADD POST: $e");
    }
  }

  /// =========================
  /// ADD COMMENT
  /// =========================
  Future<void> addComment(String postId, String content) async {
    try {

      final token = getToken();

      await http.post(
        Uri.parse(ApiConfig.commentUrl(postId)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId.value,
          "content": content
        }),
      );

      fetchPosts();

    } catch (e) {
      print("ERROR COMMENT: $e");
    }
  }

  /// =========================
  /// LIKE
  /// =========================
  Future<void> likePost(String postId) async {
    try {

      final token = getToken();

      await http.post(
        Uri.parse(ApiConfig.likeUrl(postId)),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "user_id": userId.value,
        }),
      );

      fetchPosts();

    } catch (e) {
      print("ERROR LIKE: $e");
    }
  }

  /// =========================
  /// DELETE (ONLY OWNER SAFE)
  /// =========================
  Future<void> deletePost(String postId) async {
    try {

      final token = getToken();

      final response = await http.delete(
        Uri.parse("${ApiConfig.diskusiUrl}/$postId"),
        headers: {
          "Authorization": "Bearer $token",
          "user_id": userId.value,
        },
      );

      if (response.statusCode == 200) {
        fetchPosts();
      }

    } catch (e) {
      print("ERROR DELETE: $e");
    }
  }

  /// =========================
  /// EDIT (ONLY OWNER SAFE)
  /// =========================
  Future<void> editPost(String postId, String content) async {
    try {

      final token = getToken();

      final response = await http.put(
        Uri.parse("${ApiConfig.diskusiUrl}/$postId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "user_id": userId.value,
        },
        body: jsonEncode({
          "content": content,
        }),
      );

      if (response.statusCode == 200) {
        fetchPosts();
      }

    } catch (e) {
      print("ERROR EDIT: $e");
    }
  }
}