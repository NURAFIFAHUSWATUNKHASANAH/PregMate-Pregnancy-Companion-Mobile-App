class Artikel {
  final String id;
  final String title;
  final String content;
  final String imageUrl;
   final String createdAt;

  Artikel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
