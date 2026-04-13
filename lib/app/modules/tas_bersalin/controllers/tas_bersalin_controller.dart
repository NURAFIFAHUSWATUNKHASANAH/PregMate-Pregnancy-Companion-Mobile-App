import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();



class ItemChecklist {
  String name;
  String detail;
  bool isChecked;

  ItemChecklist({
    required this.name, 
    this.detail = "", 
    this.isChecked = false
  });
}

class TasBersalinController extends GetxController {
  // --- KATEGORI IBU (Lengkap & Lokal) ---
  var ibuList = <ItemChecklist>[
    // Dokumen Penting (Crucial buat Administrasi RS & Akte)
    ItemChecklist(name: "Buku KIA (Buku Pink)", detail: "Wajib bawa! Rekam jejak kehamilan & imunisasi."),
    ItemChecklist(name: "KTP Suami Istri (Asli & Fotokopi)", detail: "Siapkan minimal 10 lembar untuk BPJS & Akte."),
    ItemChecklist(name: "Kartu Keluarga / KK (Fotokopi)", detail: "Syarat utama pengurusan akte kelahiran bayi."),
    ItemChecklist(name: "Kartu BPJS / Asuransi", detail: "Pastikan faskes sudah sesuai rujukan."),
    ItemChecklist(name: "Surat Nikah (Fotokopi)", detail: "Sering diminta pihak RS untuk registrasi bayi."),

    // Pakaian & Pasca Melahirkan
    ItemChecklist(name: "Daster Busui Friendly", detail: "5 set. Pilih kancing depan untuk memudahkan menyusui."),
    ItemChecklist(name: "Kain Jarik / Kain Batik", detail: "4-6 lembar. Sangat multifungsi di RS/Rumah Bersalin."),
    ItemChecklist(name: "Pembalut Nifas (Maternity)", detail: "2-3 pack. Pilih yang panjangnya 40cm+."),
    ItemChecklist(name: "Celana Dalam Katun Nyaman", detail: "1 lusin. Pilih yang high-waist jika rencana Caesar."),
    ItemChecklist(name: "CD Sekali Pakai", detail: "1 pack. Praktis saat pendarahan nifas sedang banyak."),
    ItemChecklist(name: "Bra Menyusui", detail: "4 buah. Tanpa kawat agar kelenjar susu tidak tertekan."),
    ItemChecklist(name: "Gurita Ibu / Korset Modern", detail: "2 buah. Membantu perut tidak terasa 'kosong' pasca lahiran."),
    ItemChecklist(name: "Kaos Kaki & Jaket", detail: "Sering menggigil pasca induksi atau operasi."),
    ItemChecklist(name: "Pakaian Pulang", detail: "Pilih yang longgar dan nyaman di perut."),

    // Toiletries & Self Care
    ItemChecklist(name: "Alat Mandi Lengkap", detail: "Sabun, shampo, sikat gigi, odol, face wash."),
    ItemChecklist(name: "Skincare & Make Up Tipis", detail: "Biar tetap segar saat difoto bareng debay."),
    ItemChecklist(name: "Lip Balm & Nipple Cream", detail: "Mencegah bibir pecah & puting lecet di hari pertama."),
    ItemChecklist(name: "Ikat Rambut & Bando", detail: "Wajib! Biar rambut tidak ganggu saat berjuang/menyusui."),
  ].obs;

  // --- KATEGORI BAYI (Super Detail Newborn) ---
  var bayiList = <ItemChecklist>[
    // Sandang Bayi
    ItemChecklist(name: "Baju Bayi (Newborn)", detail: "8 set. Campur lengan pendek, panjang, dan kutung."),
    ItemChecklist(name: "Celana Bayi", detail: "8 buah. Pilih bahan katun yang sudah ber-SNI."),
    ItemChecklist(name: "Kain Bedong", detail: "6-8 lembar. Bisa jadi alas tidur atau selimut tambahan."),
    ItemChecklist(name: "Sarung Tangan & Kaki", detail: "5 pasang. Lindungi bayi dari kuku tajamnya sendiri."),
    ItemChecklist(name: "Topi Bayi", detail: "3 buah. Menjaga suhu tubuh bayi agar tetap stabil."),
    ItemChecklist(name: "Selimut Bayi / Apron", detail: "2 buah. Satu untuk di RS, satu untuk pulang."),
    
    // Kebersihan & Kesehatan
    ItemChecklist(name: "Popok Sekali Pakai (NB)", detail: "1 pack isi 24-40. Cari yang ada notch pusat."),
    ItemChecklist(name: "Popok Kain (Tali/Perekat)", detail: "1 lusin. Jika kulit bayi sensitif di hari-hari awal."),
    ItemChecklist(name: "Minyak Telon & Baby Oil", detail: "Khas Indonesia, biar bayi hangat dan harum."),
    ItemChecklist(name: "Kapas Bulat (Cotton Balls)", detail: "2 pack. Rendam air hangat untuk bersihkan pup bayi."),
    ItemChecklist(name: "Tisu Basah & Tisu Kering", detail: "Pilih yang non-perfume/alkohol."),
    ItemChecklist(name: "Handuk Bayi Lembut", detail: "2 buah. Bahan microfiber sangat disarankan."),
    ItemChecklist(name: "Washlap", detail: "3 buah. Untuk menyeka bayi sebelum boleh mandi."),
    ItemChecklist(name: "Sisir Bayi & Gunting Kuku", detail: "Kadang kuku bayi lahir sudah panjang dan tajam."),
  ].obs;

  // --- KATEGORI AYAH/PENDAMPING (Logistik & Support) ---
  var pendampingList = <ItemChecklist>[
    // Personal Ayah
    ItemChecklist(name: "Baju Ganti & Underwear", detail: "3 set. Jangan lupa jaket karena RS sangat dingin."),
    ItemChecklist(name: "Alat Mandi Pendamping", detail: "Biar Ayah tetap segar saat urus administrasi."),
    ItemChecklist(name: "Alat Ibadah", detail: "Sajadah, Sarung, Mukena/Peci."),
    ItemChecklist(name: "Sandal Santai", detail: "Biar kaki tidak capek bolak-balik urus obat."),

    // Gadget & Support
    ItemChecklist(name: "Charger HP & Powerbank", detail: "Paling penting! Untuk kabari keluarga besar."),
    ItemChecklist(name: "Uang Tunai (Cash)", detail: "Uang pas & receh untuk parkir, kantin, atau fotokopi."),
    ItemChecklist(name: "Camilan Berenergi", detail: "Kurma, biskuit, roti. Ayah juga butuh tenaga."),
    ItemChecklist(name: "Air Mineral Dus/Galon", detail: "Stok minum untuk Ibu dan tamu yang datang."),
    ItemChecklist(name: "Aromaterapi / Minyak Urut", detail: "Untuk bantu pijat oksitosin Ibu agar ASI lancar."),
    
    // Dokumentasi Momen
    ItemChecklist(name: "Kamera / HP Memory Lega", detail: "Hapus foto lama, siapkan ruang buat ribuan foto debay."),
    ItemChecklist(name: "Tripod Mini", detail: "Opsional, biar bisa foto bertiga bareng Ibu & Bayi."),
  ].obs;

@override
void onInit() {
  super.onInit();
  loadData();
}

  // Logika toggle reaktif
void toggleItem(ItemChecklist item, String category) {
  item.isChecked = !item.isChecked;

  saveData(category);

  ibuList.refresh();
  bayiList.refresh();
  pendampingList.refresh();
}

void saveData(String category) {
  List<Map<String, dynamic>> data;

  if (category == "ibu") {
    data = ibuList.map((e) => {
      "name": e.name,
      "isChecked": e.isChecked
    }).toList();
  } else if (category == "bayi") {
    data = bayiList.map((e) => {
      "name": e.name,
      "isChecked": e.isChecked
    }).toList();
  } else {
    data = pendampingList.map((e) => {
      "name": e.name,
      "isChecked": e.isChecked
    }).toList();
  }

  box.write(category, data);
}

void loadData() {
  loadCategory("ibu", ibuList);
  loadCategory("bayi", bayiList);
  loadCategory("pendamping", pendampingList);
}

void loadCategory(String key, RxList<ItemChecklist> list) {
  final stored = box.read(key);

  if (stored != null && stored is List) {
    for (var item in list) {
      Map<String, dynamic>? found;

      try {
        found = stored
            .cast<Map>()
            .firstWhere((e) => e["name"] == item.name)
            .cast<String, dynamic>();
      } catch (e) {
        found = null;
      }

      if (found != null) {
        item.isChecked = found["isChecked"] ?? false;
      }
    }
  }
}

  // Hitung progres (0.0 sampai 1.0)
  double getProgress(List<ItemChecklist> list) {
    if (list.isEmpty) return 0.0;
    int checked = list.where((e) => e.isChecked).length;
    return checked / list.length;
  }
}