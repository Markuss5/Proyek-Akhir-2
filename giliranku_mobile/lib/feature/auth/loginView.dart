import 'package:flutter/material.dart';
import 'package:giliranku/feature/patient/home/homeView.dart';
import 'package:giliranku/feature/auth/adminLoginView.dart';
import 'package:giliranku/core/repositories/pasienRepository.dart';
import 'package:giliranku/core/repositories/kontrolRutinRepository.dart';
import 'package:giliranku/core/services/sessionService.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _nikCtrl = TextEditingController();
  final TextEditingController _namaCtrl = TextEditingController();

  final FocusNode _nikFocus = FocusNode();
  final FocusNode _namaFocus = FocusNode();

  bool _isLoading = false;

  final _pasienRepo = PasienRepository();
  final _kontrolRepo = KontrolRutinRepository();
  final _sessionService = SessionService();

  Future<void> _masukPasien() async {
    final nik = _nikCtrl.text.trim();
    final nama = _namaCtrl.text.trim();

    if (nik.isEmpty || nama.isEmpty) {
      _showError('Mohon isi NIK dan Nama Lengkap');
      return;
    }
    if (nik.length != 16) {
      _showError('NIK harus 16 digit');
      return;
    }

    setState(() => _isLoading = true);
    final patient = await _pasienRepo.login(nik, nama);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (patient == null) {
      _showError('Tidak dapat terhubung ke server.');
      return;
    }
    if (patient.nik.isEmpty) {
      _showError(patient.phone ?? 'Login gagal');
      return;
    }

    await _sessionService.savePatient(patient);
    _kontrolRepo.resyncNotifications(nik);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeView(patientData: patient.toMap())),
    );
  }

  Future<void> _lewatkan() async {
    await _sessionService.saveGuest();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  void _masukSebagaiAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginView()),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    _nikFocus.dispose();
    _namaFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25A699),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Masuk",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          "Silakan isi data untuk melanjutkan",
                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 20),

                        _buildInput(
                          controller: _nikCtrl,
                          focusNode: _nikFocus,
                          nextFocus: _namaFocus,
                          hint: 'NIK (16 digit)',
                          icon: Icons.credit_card,
                          keyboardType: TextInputType.number,
                        ),

                        const SizedBox(height: 12),

                        _buildInput(
                          controller: _namaCtrl,
                          focusNode: _namaFocus,
                          hint: 'Nama lengkap',
                          icon: Icons.person,
                        ),

                        const SizedBox(height: 20),

                        // 🔥 BUTTON FIX (BIRU + TEXT JELAS)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed:
                                _isLoading ? null : _masukPasien,
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Masuk",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                  color: Color(0xFF25A699)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _lewatkan,
                            child: const Text("Lewatkan"),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: GestureDetector(
                            onTap: _masukSebagaiAdmin,
                            child: const Text(
                              "Masuk sebagai Admin",
                              style: TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction:
          nextFocus != null ? TextInputAction.next : TextInputAction.done,
      onSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      style: const TextStyle(color: Colors.black),
      cursorColor: const Color(0xFF25A699),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF25A699)),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}