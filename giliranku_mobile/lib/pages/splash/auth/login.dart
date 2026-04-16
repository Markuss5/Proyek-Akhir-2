import 'package:flutter/material.dart';
import 'package:giliranku/pages/splash/auth/home/home_page.dart';
import 'package:giliranku/pages/splash/auth/admin_login.dart';
import 'package:giliranku/services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _masukPasien() async {
    final nik = _nikController.text.trim();
    final nama = _namaController.text.trim();

    if (nik.isEmpty || nama.isEmpty) {
      _showError("Mohon isi NIK dan Nama Lengkap");
      return;
    }
    if (nik.length != 16) {
      _showError("NIK harus 16 digit");
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiService.loginPasien(nik, nama);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result == null) {
      _showError("Tidak dapat terhubung ke server. Pastikan backend berjalan.");
      return;
    }

    if (result.containsKey('error')) {
      _showError(result['error']);
      return;
    }

    // Login success — navigate to home with patient data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(patientData: result),
      ),
    );
  }

  void _lewatkan() {
    // Skip login, go to patient home as guest
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void _masukSebagaiAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginPage()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nikController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(color: Colors.grey[200]),

          // Shape atas
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Color(0xFF2F9E8F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
          ),

          // Konten
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.local_hospital, size: 80, color: Colors.white);
                  },
                ),

                const SizedBox(height: 8),
                const SizedBox(height: 40),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F9E8F),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // NIK
                          _buildInput(
                            controller: _nikController,
                            title: "Nomor Induk Kependudukan",
                            hint: "Masukkan 16 digit NIK",
                            keyboardType: TextInputType.number,
                          ),

                          const SizedBox(height: 20),

                          // Nama
                          _buildInput(
                            controller: _namaController,
                            title: "Nama Lengkap",
                            hint: "Masukkan Nama Lengkap",
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _masukPasien,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text("Masuk"),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF2F9E8F),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: _lewatkan,
                                  child: const Text("Lewatkan"),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          GestureDetector(
                            onTap: _masukSebagaiAdmin,
                            child: const Text(
                              "Masuk Sebagai Admin",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String title,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}