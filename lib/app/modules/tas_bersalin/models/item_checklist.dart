class ItemChecklist {
  String name;
  String detail;
  bool isChecked;
  String type; // 🔥 wajib / optional

  ItemChecklist({
    required this.name,
    this.detail = "",
    this.isChecked = false,
    this.type = "optional",
  });

  Map<String, dynamic> toJson(String category) {
    return {
      "name": name,
      "detail": detail,
      "category": category,
      "isChecked": isChecked,
      "type": type,
    };
  }

  factory ItemChecklist.fromJson(Map<String, dynamic> json) {
    return ItemChecklist(
      name: json["name"] ?? "",
      detail: json["detail"] ?? "",
      isChecked: json["isChecked"] ?? false,
      type: json["type"] ?? "optional",
    );
  }
}