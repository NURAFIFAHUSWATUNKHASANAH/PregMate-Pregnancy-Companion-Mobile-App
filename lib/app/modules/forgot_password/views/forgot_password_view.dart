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
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // 🔥 CENTER TITLE DIGANTI
                Center(
                  child: Text(
                    controller.otpRequested.value
                        ? "Verifikasi Akun Anda"
                        : "Atur Ulang Password",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: navyColor,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    controller.otpRequested.value
                        ? "Masukkan kode OTP yang dikirim ke WhatsApp Anda untuk melanjutkan proses reset password."
                        : "Masukkan nomor WhatsApp Anda untuk menerima kode OTP.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // PHONE
                _label("Nomor WhatsApp"),
                const SizedBox(height: 8),
                _field(
                  controller: controller.phoneController,
                  hint: "08xxxxxxxxxx",
                  icon: Icons.phone,
                  enabled: !controller.otpRequested.value,
                ),

                if (controller.otpRequested.value) ...[
                  const SizedBox(height: 20),
                  _label("Kode OTP"),
                  const SizedBox(height: 8),
                  _field(
                    controller: controller.otpController,
                    hint: "Masukkan OTP",
                    icon: Icons.security,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  _label("Password Baru"),
                  const SizedBox(height: 8),
                  Obx(() => _field(
                        controller: controller.newPasswordController,
                        hint: "••••••••",
                        icon: Icons.lock_outline,
                        isPassword: controller.hidePassword.value,
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.hidePassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            controller.hidePassword.value =
                                !controller.hidePassword.value;
                          },
                        ),
                      )),
                ],

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: controller.otpRequested.value
                              ? controller.resetPassword
                              : controller.requestOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navyColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            controller.otpRequested.value
                                ? "Simpan Password Baru"
                                : "Kirim OTP WhatsApp",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF0C2D57),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool enabled = true,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
