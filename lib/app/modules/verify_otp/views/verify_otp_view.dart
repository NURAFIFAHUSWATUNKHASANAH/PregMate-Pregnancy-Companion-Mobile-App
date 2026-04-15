import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verify_otp_controller.dart';

class VerifyOtpView extends GetView<VerifyOtpController> {
  const VerifyOtpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      body: Stack(
        children: [
          // Dekorasi background (biar sama kayak login)
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: const Color(0xFF0C2D57).withOpacity(0.05),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        "Verifikasi OTP",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0C2D57),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Masukkan kode OTP yang telah dikirim ke email Anda.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Label OTP
                      _buildLabel("Kode OTP"),
                      const SizedBox(height: 8),

                      // Input OTP (style sama kayak login)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: TextField(
  controller: controller.otpController,
  keyboardType: TextInputType.number,
  maxLength: 6,
  textAlign: TextAlign.center, // Tetap gunakan ini
  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8), // Tambah letterSpacing agar lebih cantik
  decoration: InputDecoration(
    counterText: "",
    hintText: "••••••",
    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16, letterSpacing: 8),
    
    // Icon kiri
    prefixIcon: const Icon(
      Icons.verified_user_outlined,
      color: Color(0xFF0C2D57),
      size: 20,
    ),
    
    // TAMBAHKAN INI: Icon transparan di kanan supaya teks terdorong ke tengah dengan adil
    suffixIcon: const Icon(
      Icons.verified_user_outlined,
      color: Colors.transparent, 
      size: 20,
    ),

    contentPadding: const EdgeInsets.symmetric(vertical: 18),
    // ... sisa border sama
  ),
),
                      ),

                      const SizedBox(height: 30),

                      // Button / Loading
                      Obx(() {
                        return controller.isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0C2D57),
                                ),
                              )
                            : _buildPrimaryButton(
                                onPressed: controller.verifyOtp,
                                label: "Verifikasi",
                              );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== HELPER ==================

  Widget _buildLabel(String text) {
    return const Text(
      "Kode OTP",
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0C2D57),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C2D57).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C2D57),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}