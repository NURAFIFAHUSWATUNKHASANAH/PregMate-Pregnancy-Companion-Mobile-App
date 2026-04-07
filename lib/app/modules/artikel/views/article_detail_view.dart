import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/artikel_controller.dart';
import 'package:PregMate/models/artikel_model.dart';

class ArtikelDetailView extends StatelessWidget {
  final String id;
  final ArtikelController controller = Get.find();

  ArtikelDetailView({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Artikel?>(
      future: controller.fetchArtikelDetail(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF0C2D57))),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(elevation: 0, backgroundColor: Colors.transparent),
            body: const Center(child: Text("Artikel tidak ditemukan")),
          );
        }

        final artikel = snapshot.data!;
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // AppBar Modern dengan Gambar Imersif
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                elevation: 0,
                stretch: true,
                backgroundColor: const Color(0xFF0C2D57),
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (artikel.imageUrl.isNotEmpty)
                        Image.network(
                          artikel.imageUrl,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: const Color(0xFF0C2D57)),
                      // Gradient overlay agar teks di AppBar tetap terbaca
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black54,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Konten Artikel
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  transform: Matrix4.translationValues(0, -30, 0), // Menarik konten ke atas gambar
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori atau Tag (Opsional)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C2D57).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Kesehatan & Fisioterapi",
                            style: TextStyle(
                              color: Color(0xFF0C2D57),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Judul Artikel
                        Text(
                          artikel.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.5,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info Penulis/Waktu (Dummy placeholder untuk estetika)
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFFE2E8F0),
                              child: Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Tim PhysioCare • 2 menit baca",
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(thickness: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 24),

                        // Isi Konten
                        Text(
                          artikel.content,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF475569),
                            height: 1.8,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 100), // Spasi bawah agar tidak terpotong navigation bar
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}