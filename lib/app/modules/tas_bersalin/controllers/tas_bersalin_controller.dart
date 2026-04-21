import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:PregMate/config/api_config.dart';

final box = GetStorage();

class ItemChecklist {
  String name;
  String detail;
  bool isChecked;
  String type;

  ItemChecklist({
    required this.name,
    this.detail = "",
    this.type = "optional",
    this.isChecked = false,
  });
}

class TasBersalinController extends GetxController {
  String userId = "";
  String kehamilanId = "";

  var ibuList = <ItemChecklist>[].obs;
  var bayiList = <ItemChecklist>[].obs;
  var pendampingList = <ItemChecklist>[].obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    userId = box.read("user_id") ?? "";
    kehamilanId = box.read("kehamilan_id") ?? "";

    print("DEBUG USER_ID: $userId");
    print("DEBUG KEHAMILAN_ID: $kehamilanId");

    fetchFromServer();
  }

  // ================= FETCH FULL DATA (MASTER + USER) =================
  Future<void> fetchFromServer() async {
    if (kehamilanId.isEmpty || kehamilanId == "null") {
      print("⚠️ kehamilanId kosong");
      return;
    }

    isLoading.value = true;

    final token = box.read("auth_token") ?? "";

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.tasBersalinUrl}?kehamilan_id=$kehamilanId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List items = data["data"];

        // 🔥 RESET SEMUA LIST
        ibuList.clear();
        bayiList.clear();
        pendampingList.clear();

        for (var item in items) {
          final newItem = ItemChecklist(
            name: item["name"],
            detail: item["detail"] ?? "",
            type: item["type"] ?? "optional",
            isChecked: item["isChecked"] ?? false,
          );

          if (item["category"] == "ibu") {
            ibuList.add(newItem);
          } else if (item["category"] == "bayi") {
            bayiList.add(newItem);
          } else if (item["category"] == "pendamping") {
            pendampingList.add(newItem);
          }
        }

        print("✅ Data berhasil di-load dari server");
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ================= TOGGLE CHECKLIST =================
  Future<void> toggleItem(ItemChecklist item, String category) async {
    // Optimistic update
    item.isChecked = !item.isChecked;

    ibuList.refresh();
    bayiList.refresh();
    pendampingList.refresh();

    final token = box.read("auth_token") ?? "";

    final body = jsonEncode({
      "kehamilan_id": kehamilanId,
      "category": category,
      "name": item.name,
      "detail": item.detail,
      "isChecked": item.isChecked,
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tasBersalinToggleUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print("✅ Toggle sukses");

        // 🔥 sync ulang biar konsisten antar device
        fetchFromServer();
      } else {
        print("❌ Toggle gagal: ${response.body}");
      }
    } catch (e) {
      print("❌ toggle error: $e");
    }
  }

  // ================= GET LIST =================
  List<ItemChecklist> getList(String category) {
    if (category == "ibu") return ibuList;
    if (category == "bayi") return bayiList;
    return pendampingList;
  }

  // ================= PROGRESS =================
double getProgress(List<ItemChecklist> list) {
  final wajibList = list.where((e) => e.type == "wajib").toList();

  if (wajibList.isEmpty) return 0;

  final done = wajibList.where((e) => e.isChecked).length;

  return done / wajibList.length;
}
}