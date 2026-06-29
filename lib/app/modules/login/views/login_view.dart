import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      body: Stack(
        children: [
          // Dekorasi Background Bulat (Soft Accent)
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
                      // 1. Header Section
                      const Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0C2D57),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Silahkan masuk untuk melanjutkan perjalanan kehamilan Anda.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 2. Input Email
                      _buildLabel("Nomor WhatsApp"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        onChanged: (value) => controller.phone.value = value,
                        hint: "Contoh: 08xxxxxxxxxx",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),

                      // 3. Input Password
                      _buildLabel("Kata Sandi"),
                      const SizedBox(height: 8),
                      Obx(() => _buildTextField(
                            onChanged: (value) =>
                                controller.password.value = value,
                            hint: "••••••••",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureText: controller.isPasswordHidden.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          )),

                      // Lupa Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed('/forgot-password'),
                          child: const Text(
                            "Lupa Password?",
                            style: TextStyle(
                              color: Color(0xFF0C2D57),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. Action Buttons
                      _buildPrimaryButton(
                        onPressed: controller.login,
                        label: "Masuk",
                      ),
                      const SizedBox(height: 16),

                      // _buildGoogleButton(
                      //   onPressed: controller.loginWithGoogle,
                      // ),

                      // const SizedBox(height: 32),

                      // 5. Register Link
                      Center(
                        child: GestureDetector(
                          onTap: () => Get.toNamed('/register'),
                          child: RichText(
                            text: TextSpan(
                              text: "Belum memiliki akun? ",
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 14),
                              children: const [
                                TextSpan(
                                  text: "Daftar Sekarang",
                                  style: TextStyle(
                                    color: Color(0xFF0C2D57),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
    required Function(String) onChanged,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
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
        keyboardType: keyboardType,
        onChanged: onChanged,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF0C2D57), size: 20),
          suffixIcon: suffixIcon,
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

  Widget _buildPrimaryButton(
      {required VoidCallback onPressed, required String label}) {
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
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGoogleButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Image.asset('assets/google_logo.png', height: 22),
        label: const Text(
          "Masuk dengan Google",
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
