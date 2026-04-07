import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/kamera/views/kamera_view.dart';

class InformasiDialog extends StatelessWidget {
  final Map<String, dynamic> terapi;
  final int index;

  const InformasiDialog({Key? key, required this.terapi, required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = terapi["gambar"];
    String peringatan = terapi["peringatan"] ?? '';
    const Color primaryColor = Color(0xFF0C2D57);

    // Tetap mempertahankan logika gambar bawaan Anda
    Widget imageWidget;
    if (Uri.tryParse(imageUrl)?.hasAbsolutePath ?? false) {
      imageWidget = Image.network(
        imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/default_image.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias, // Memastikan gambar mengikuti border radius
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 360,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image dengan Close Button Overlay
            Stack(
              children: [
                imageWidget,
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.3),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ],
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Panduan Terapi",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Warning Message yang lebih halus
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.gpp_maybe_rounded, color: Colors.red, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Lakukan gerakan sesuai instruksi!",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Deskripsi
                    Text(
                      terapi["deskripsi"] ?? "Deskripsi tidak tersedia",
                      style: const TextStyle(
                        fontSize: 15, 
                        color: Color(0xFF475569),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Peringatan Logika tetap sama
                    if (peringatan.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "⚠️ Peringatan Penting",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              peringatan,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Tombol Aksi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Get.to(() => KameraView(terapi: terapi, index: index));
                        },
                        child: const Text(
                          "Mulai Terapi",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}