class ItemChecklist {
  String name;
  String detail;
  bool isChecked;

  ItemChecklist({
    required this.name,
    this.detail = "",
    this.isChecked = false,
  });

  Map<String, dynamic> toJson(String category) {
    return {
      "name": name,
      "detail": detail,
      "category": category,
      "isChecked": isChecked,
    };
  }

  factory ItemChecklist.fromJson(Map<String, dynamic> json) {
    return ItemChecklist(
      name: json["name"] ?? "",
      detail: json["detail"] ?? "",
      isChecked: json["isChecked"] ?? false,
    );
  }
}