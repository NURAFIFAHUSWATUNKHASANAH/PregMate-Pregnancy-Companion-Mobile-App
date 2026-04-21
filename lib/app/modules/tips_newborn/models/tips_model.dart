class TipsModel {
  final String id;
  final String title;
  final String desc;
  final String videoUrl;
  final List<String> steps;

  TipsModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.videoUrl,
    required this.steps,
  });

  factory TipsModel.fromJson(Map<String, dynamic> json) {
    return TipsModel(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      desc: (json["desc"] ?? "").toString(),

      // 🔥 FIX BIAR AMAN DARI BACKEND BERBEDA FIELD
      videoUrl: (json["video_url"] ?? json["video"] ?? "").toString(),

      // 🔥 FIX NULL SAFETY
      steps: (json["steps"] != null)
          ? List<String>.from(json["steps"])
          : [],
    );
  }
}