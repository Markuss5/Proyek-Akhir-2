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
      _showError('Tidak dapat terhubung ke server. Pastikan backend berjalan.');
      return;
    }
    if (patient.nik.isEmpty) {
      _showError(patient.phone ?? 'Login gagal');
      return;
    }

    // Persist session so re-opens skip login
    await _sessionService.savePatient(patient);
    // Resync local notifications in background
    _kontrolRepo.resyncNotifications(nik);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeView(patientData: patient.toMap())),
    );
  }

  Future<void> _lewatkan() async {
    // Save guest session — next launch lands on HomeView directly
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  void dispose() {
    _nikCtrl.dispose();
    _namaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.grey[200]),
          Container(
            height: 300,
            decoration: const BoxDecoration(
              color: Color(0xFF25A699),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25A699),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildInput(
                            controller: _nikCtrl,
                            title: 'Nomor Induk Kependudukan',
                            hint: 'Masukkan 16 digit NIK',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _buildInput(
                            controller: _namaCtrl,
                            title: 'Nama Lengkap',
                            hint: 'Masukkan Nama Lengkap',
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
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
                                      : const Text('Masuk'),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF25A699),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: _lewatkan,
                                  child: const Text('Lewatkan'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _masukSebagaiAdmin,
                            child: const Text(
                              'Masuk Sebagai Admin',
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
          ),
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
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
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
