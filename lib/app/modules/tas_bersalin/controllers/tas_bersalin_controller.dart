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

  ItemChecklist({
    required this.name,
    this.detail = "",
    this.isChecked = false,
  });
}

class TasBersalinController extends GetxController {
  String userId = "";
  String kehamilanId = "";

  var ibuList = <ItemChecklist>[].obs;
  var bayiList = <ItemChecklist>[].obs;
  var pendampingList = <ItemChecklist>[].obs;

@override
void onInit() {
  super.onInit();

  userId = box.read("user_id") ?? "";
  kehamilanId = box.read("kehamilan_id") ?? "";

  print("DEBUG USER_ID: $userId");
  print("DEBUG KEHAMILAN_ID: $kehamilanId");

  loadDefaultData();
  fetchFromServer();
}

Future<void> fetchFromServer() async {
  // 1. Cek validitas kehamilanId sebelum tembak API
  if (kehamilanId.isEmpty || kehamilanId == "null") {
    print("⚠️ Fetch dibatalkan: kehamilanId kosong");
    return;
  }

  final token = box.read("auth_token") ?? "";

  try {
    final response = await http.get(
      Uri.parse("${ApiConfig.tasBersalinUrl}?kehamilan_id=$kehamilanId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json", // Tambahkan ini
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data["data"];

      for (var item in items) {
        final category = item["category"];
        final name = item["name"];
        final isChecked = item["isChecked"] ?? false;
        final detail = item["detail"] ?? "";

        final list = getList(category);
        final match = list.firstWhereOrNull((e) => e.name == name);

        if (match != null) {
          match.isChecked = isChecked;
          match.detail = detail;
        }
      }
      // Refresh semua list
      ibuList.refresh();
      bayiList.refresh();
      pendampingList.refresh();
    } else {
      print("❌ Server error ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    print("❌ fetch error: $e");
  }
}

  Future<void> toggleItem(ItemChecklist item, String category) async {
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

  await http.post(
    Uri.parse(ApiConfig.tasBersalinToggleUrl),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: body,
  );

  // 🔥 AUTO SYNC CROSS DEVICE
  fetchFromServer();
}

  // ================= LOCAL STORAGE =================
  void saveLocal(String category) {
    List<ItemChecklist> list = getList(category);

    box.write(
      category,
      list
          .map((e) => {
                "name": e.name,
                "detail": e.detail,
                "isChecked": e.isChecked,
              })
          .toList(),
    );
  }

  void loadLocal() {
    loadCategory("ibu", ibuList);
    loadCategory("bayi", bayiList);
    loadCategory("pendamping", pendampingList);
  }

  void loadCategory(String key, RxList<ItemChecklist> list) {
    final stored = box.read(key);

    if (stored is List) {
      for (var item in list) {
        final match = stored.firstWhereOrNull(
          (e) => e["name"] == item.name,
        );

        if (match != null) {
          item.isChecked = match["isChecked"] ?? false;
        }
      }
    }
  }

  // ================= DEFAULT DATA =================
  void loadDefaultData() {
  ibuList.value = [
    ItemChecklist(name: "Buku KIA", detail: "Wajib dibawa saat kontrol & persalinan"),
    ItemChecklist(name: "KTP", detail: "Identitas ibu"),
    ItemChecklist(name: "KK (Kartu Keluarga)", detail: "Administrasi RS"),
    ItemChecklist(name: "BPJS / Asuransi", detail: "Jika ada"),
    ItemChecklist(name: "Surat Rujukan", detail: "Jika dirujuk"),
    ItemChecklist(name: "Hasil USG", detail: "Riwayat kehamilan"),
    ItemChecklist(name: "Baju Ibu (Longgar)", detail: "2-3 set"),
    ItemChecklist(name: "Kain Batik / Kain Panjang (Tapih)", detail: "Untuk setelah melahirkan / tradisional"),
    ItemChecklist(name: "Kemben / Stagen", detail: "Penahan perut (tradisional)"),
    ItemChecklist(name: "Pembalut Bersalin", detail: "Post partum"),
    ItemChecklist(name: "Kain Jarik", detail: "Pengganti selimut atau gendong tradisional"),
    ItemChecklist(name: "Selimut Ibu", detail: "Penghangat"),
    ItemChecklist(name: "Handuk", detail: "2 pcs"),
    ItemChecklist(name: "Perlengkapan Mandi", detail: "Sabun, sikat gigi, dll"),
    ItemChecklist(name: "Bra Menyusui", detail: "Minimal 2"),
    ItemChecklist(name: "Minyak Telon / Minyak Kayu Putih", detail: "Perawatan tradisional"),
    ItemChecklist(name: "Herbal Tradisional (opsional)", detail: "Kunyit, jamu pasca melahirkan"),
  ];

  bayiList.value = [
    ItemChecklist(name: "Baju Bayi Lengan Panjang", detail: "3-5 pcs"),
    ItemChecklist(name: "Baju Bayi Lengan Pendek", detail: "3-5 pcs"),
    ItemChecklist(name: "Popok Kain / PosPak", detail: "1-2 pack"),
    ItemChecklist(name: "Kain Bedong", detail: "3-5 lembar"),
    ItemChecklist(name: "Selimut Bayi", detail: "1-2 pcs"),
    ItemChecklist(name: "Topi Bayi", detail: "Menjaga suhu tubuh"),
    ItemChecklist(name: "Sarung Tangan & Kaki Bayi", detail: "Agar tidak tergores"),
    ItemChecklist(name: "Kain Tapih Bayi", detail: "Kain panjang tradisional untuk gendong"),
    ItemChecklist(name: "Gendongan Tradisional (Kain Jarik)", detail: "Alternatif stroller"),
    ItemChecklist(name: "Handuk Bayi", detail: "Khusus bayi"),
    ItemChecklist(name: "Tisu Basah Bayi", detail: "Non alkohol"),
    ItemChecklist(name: "Gunting Kuku Bayi", detail: "Aman"),
    ItemChecklist(name: "Perlak Bayi", detail: "Anti bocor"),
    ItemChecklist(name: "Kapas & Air Hangat", detail: "Perawatan tali pusar"),
  ];

  pendampingList.value = [
    ItemChecklist(name: "Charger HP", detail: "Wajib"),
    ItemChecklist(name: "Powerbank", detail: "Cadangan"),
    ItemChecklist(name: "Uang Cash", detail: "Darurat"),
    ItemChecklist(name: "KTP Pendamping", detail: "Identitas"),
    ItemChecklist(name: "Baju Ganti", detail: "1-2 set"),
    ItemChecklist(name: "Sandal Jepit", detail: "Nyaman"),
    ItemChecklist(name: "Selimut Tipis", detail: "Jika dingin"),
    ItemChecklist(name: "Snack / Makanan Ringan", detail: "Menunggu proses"),
    ItemChecklist(name: "Air Minum", detail: "Tetap terhidrasi"),
    ItemChecklist(name: "Obat Pribadi", detail: "Jika punya riwayat penyakit"),
    ItemChecklist(name: "Sarung / Kain Tradisional", detail: "Bisa dipakai duduk / ibadah"),
  ];
}

  List<ItemChecklist> getList(String category) {
    if (category == "ibu") return ibuList;
    if (category == "bayi") return bayiList;
    return pendampingList;
  }

  double getProgress(List<ItemChecklist> list) {
    if (list.isEmpty) return 0;
    return list.where((e) => e.isChecked).length / list.length;
  }
}