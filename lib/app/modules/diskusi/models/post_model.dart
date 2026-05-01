class Comment {
  final String userId;
  final String user;
  final String? userPhoto;
  final String content;

  Comment({
    required this.userId,
    required this.user,
    this.userPhoto,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json["user_id"]?.toString() ?? "",
      user: json["user_name"] ?? "Pengguna",
      userPhoto: json["user_photo"],
      content: json["content"] ?? "",
    );
  }
}

class Post {
  final String id;
  final String userId;
  final String user;
  final String? userPhoto;
  final String content;
  final String? image;
  final int likes;
  final List likedBy;
  final List<Comment> comments;
  final String tanggal;

  Post({
    required this.id,
    required this.userId,
    required this.user,
    this.userPhoto,
    required this.content,
    this.image,
    required this.likes,
    required this.likedBy,
    required this.comments,
    required this.tanggal,
  });

  factory Post.fromJson(Map<String, dynamic> json) {

    return Post(
      id: json["_id"]?.toString() ?? "",
      userId: json["user_id"]?.toString() ?? "",

      /// FIX NAMA USER
      user: json["user_name"] ??
            json["nama"] ??
            json["user"] ??
            "Pengguna",

      /// FIX FOTO
      userPhoto: json["user_photo"] ?? json["foto"],

      content: json["content"] ?? "",

      image: json["image"],

      likes: json["likes"] ?? 0,
      likedBy: json["liked_by"] ?? [],

      comments: json["comments"] != null
          ? (json["comments"] as List)
              .map((e) => Comment.fromJson(e))
              .toList()
          : [],
      tanggal: json["tanggal"] ?? "",
    );
  }
}