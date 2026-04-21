import 'package:flutter/material.dart';
import 'package:giliranku_mobile/pages/splash/auth/login.dart';
import 'package:giliranku_mobile/pages/splash/auth/home/edit_profile_page.dart';

class PatientProfilTab extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const PatientProfilTab({super.key, this.patientData});

  @override
  State<PatientProfilTab> createState() => _PatientProfilTabState();
}

class _PatientProfilTabState extends State<PatientProfilTab> {
  late Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _data = widget.patientData != null ? Map<String, dynamic>.from(widget.patientData!) : null;
  }

  bool get _isLoggedIn => _data != null && _data!.containsKey('nik');

  Future<void> _openEditProfile() async {
    if (!_isLoggedIn) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilePage(patientData: _data!),
      ),
    );

    if (result != null) {
      setState(() => _data = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header with teal background
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2F9E8F),
                ),
              ),
              // Profile card overlapping the header
              Positioned(
                left: 24,
                right: 24,
                top: 100,
                child: GestureDetector(
                  onTap: _isLoggedIn ? _openEditProfile : null,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 32,
                            color: Color(0xFF2F9E8F),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLoggedIn
                                    ? (_data!['patient_name'] ?? 'Pasien')
                                    : 'Tamu',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoggedIn
                                    ? 'Lengkapi data anda'
                                    : 'Masuk untuk melihat data lengkap',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _isLoggedIn ? const Color(0xFF2F9E8F) : Colors.grey[500],
                                  fontWeight: _isLoggedIn ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isLoggedIn)
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Spacer for the overlapping card
          const SizedBox(height: 80),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Medical Info Card
                  if (_isLoggedIn) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Medis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('NIK', _data!['nik'] ?? '-'),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'No. BPJS',
                            (_data!['no_bpjs'] != null && _data!['no_bpjs'].toString().isNotEmpty)
                                ? _data!['no_bpjs']
                                : '-',
                          ),
                          const Divider(height: 24),
                          _buildInfoRow(
                            'Golongan Darah',
                            (_data!['golongan_darah'] != null && _data!['golongan_darah'].toString().isNotEmpty)
                                ? _data!['golongan_darah']
                                : '-',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],

                  // Pengaturan
                  _buildMenuTile(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    subtitle: 'Notifikasi, bahasa',
                    onTap: () {},
                  ),

                  const SizedBox(height: 12),

                  // Keluar / Login
                  _buildMenuTile(
                    icon: _isLoggedIn ? Icons.logout : Icons.login,
                    title: _isLoggedIn ? 'Keluar' : 'Masuk',
                    subtitle: _isLoggedIn ? 'Logout dari akun' : 'Masuk ke akun Anda',
                    iconColor: _isLoggedIn ? Colors.red : const Color(0xFF2F9E8F),
                    onTap: () {
                      if (_isLoggedIn) {
                        _showLogoutDialog(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF2F9E8F),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
