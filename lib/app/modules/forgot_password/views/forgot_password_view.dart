import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PregMate/app/modules/forgot_password/controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const navyColor = Color(0xFF0C2D57);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: const Text(
          "Lupa Password",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ilustrasi atau Ikon Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: navyColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 60,
                      color: navyColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Teks Instruksi
                Text(
                  controller.otpRequested.value
                      ? "Verifikasi Identitas"
                      : "Atur Ulang Password",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: navyColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.otpRequested.value
                      ? "Silahkan masukkan kode OTP yang kami kirim ke email Anda dan buat password baru."
                      : "Jangan khawatir! Masukkan email Anda di bawah ini untuk menerima kode verifikasi OTP.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Input Email
                _buildLabel("Alamat Email"),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: controller.emailController,
                  hint: "user@email.com",
                  icon: Icons.email_outlined,
                  enabled: !controller.otpRequested.value,
                ),

                // 4. Input Dinamis (OTP & Password Baru)
                if (controller.otpRequested.value) ...[
                  const SizedBox(height: 20),
                  _buildLabel("Kode OTP"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: controller.otpController,
                    hint: "Masukkan 6 digit kode",
                    icon: Icons.security_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _buildLabel("Password Baru"),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: controller.newPasswordController,
                    hint: "••••••••",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                ],

                const SizedBox(height: 40),

                // 5. Tombol Aksi
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator(color: navyColor))
                      : ElevatedButton(
                          onPressed: controller.otpRequested.value
                              ? controller.resetPassword
                              : controller.requestOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor: navyColor.withOpacity(0.4),
                          ),
                          child: Text(
                            controller.otpRequested.value
                                ? "Simpan Password Baru"
                                : "Kirim Kode OTP",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                
                // 6. Footer
                if (controller.otpRequested.value) ...[
                   const SizedBox(height: 20),
                   Center(
                     child: TextButton(
                       onPressed: controller.requestOtp, // Resend logic
                       child: const Text(
                         "Belum terima kode? Kirim ulang",
                         style: TextStyle(color: navyColor, fontWeight: FontWeight.bold),
                       ),
                     ),
                   )
                ]
              ],
            )),
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0C2D57),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey[100],
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
        controller: controller,
        obscureText: isPassword,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF0C2D57), size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0C2D57), width: 1.5),
          ),
        ),
      ),
    );
  }
}