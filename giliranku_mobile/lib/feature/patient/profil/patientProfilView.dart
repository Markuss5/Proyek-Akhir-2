import 'package:flutter/material.dart';
import 'package:giliranku/feature/auth/loginView.dart';
import 'package:giliranku/feature/patient/profil/editProfilView.dart';
import 'package:giliranku/core/services/sessionService.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/feature/patient/riwayat/riwayatView.dart';

class PatientProfilView extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int)? onSwitchTab;
  const PatientProfilView({super.key, this.patientData, this.onSwitchTab});

  @override
  State<PatientProfilView> createState() => _PatientProfilViewState();
}

class _PatientProfilViewState extends State<PatientProfilView> {
  late Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.patientData != null
        ? Map<String, dynamic>.from(widget.patientData!)
        : null;
  }

  bool get _isLoggedIn => _data != null && _data!.containsKey('nik');
  String get _name => _isLoggedIn ? (_data!['patient_name'] ?? 'Pasien') : 'Tamu';
  String get _nik => _isLoggedIn ? (_data!['nik'] ?? '-') : '-';
  String get _noRM =>
      _isLoggedIn && _data!['no_rm'] != null && _data!['no_rm'] != ''
          ? _data!['no_rm']
          : '-';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuCard(
                    context,
                    isProfile: true,
                    icon: Icons.person_rounded,
                    title: _name,
                    subtitle: 'Lihat dan edit profil Anda',
                    onTap: () async {
                      if (!_isLoggedIn) {
                        _showLoginAlert();
                        return;
                      }
                      final result = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilView(patientData: _data!)),
                      );
                      if (result != null) setState(() => _data = result);
                    },
                  ),

                  if (_isLoggedIn) ...[
                    _buildMedisCard(),
                  ],

                  _buildMenuCard(
                    context,
                    icon: Icons.history_rounded,
                    title: 'Riwayat Antrian',
                    subtitle: 'Riwayat kunjungan Anda di RSUD Porsea',
                    onTap: () {
                      if (!_isLoggedIn) {
                        _showLoginAlert();
                        return;
                      }
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatView()));
                    },
                  ),

                  _buildMenuCard(
                    context,
                    icon: _isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                    title: _isLoggedIn ? 'Keluar' : 'Masuk',
                    subtitle: _isLoggedIn ? 'Logout dari akun' : 'Masuk ke akun Anda',
                    iconColor: _isLoggedIn ? Colors.red : const Color(0xFF0D9B86),
                    onTap: () {
                      if (_isLoggedIn) {
                        _showLogoutDialog();
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0DB89E), Color(0xFF0A6B5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onSwitchTab != null) {
                widget.onSwitchTab!(0);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Profil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0D9B86),
    bool isProfile = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(15),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: isProfile && _isLoggedIn 
              ? Center(child: Text(_name[0].toUpperCase(), style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 18)))
              : Icon(icon, color: iconColor, size: 24),
          ),
          title: Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)
          ),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildMedisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF0DB89E).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Medis', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _infoRow('NIK', _nik),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _infoRow('No. Rekam Medis', _noRM),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  void _showLoginAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 30),
                ),
                const SizedBox(height: 16),
                const Text("Fitur Terkunci", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Silakan masuk ke akun Anda terlebih dahulu agar fitur dapat diakses",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginView()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white, 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text("Masuk", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionService().logout();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginView()), (r) => false);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}