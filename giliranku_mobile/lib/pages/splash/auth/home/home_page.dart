import 'package:flutter/material.dart';
import 'package:giliranku/pages/splash/auth/home/patient_profil_tab.dart';
import 'package:giliranku/pages/splash/auth/home/profil_view.dart';
import 'package:giliranku/pages/splash/auth/home/patient_notifikasi_page.dart';
import 'package:giliranku/pages/splash/auth/antrian/antrian_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? patientData;

  const HomePage({super.key, this.patientData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      _BerandaTab(
        patientData: widget.patientData,
        onSwitchTab: _switchTab,
      ),
      const ProfilView(),
      const _PlaceholderTab(title: 'Antrian', icon: Icons.calendar_today),
      PatientProfilTab(patientData: widget.patientData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2F9E8F),
          unselectedItemColor: Colors.grey[500],
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Beranda"),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: "Informasi"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: "Antrian"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profil"),
          ],
        ),
      ),
    );
  }
}

// ============ BERANDA TAB ============
class _BerandaTab extends StatelessWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _BerandaTab({this.patientData, required this.onSwitchTab});

  bool get _isLoggedIn => patientData != null && patientData!.containsKey('nik');

  String? get _nik => _isLoggedIn ? patientData!['nik'] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header with logo
          Stack(
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scaleX: 1.5,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2F9E8F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(180),
                      bottomRight: Radius.circular(180),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        "GiliranKu",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -25),
                      child: Column(
                        children: [
                          // Welcome card
                          Container(
                            width: double.infinity,
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
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F9E8F).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.waving_hand, color: Color(0xFF2F9E8F), size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isLoggedIn
                                            ? "Halo, ${patientData!['patient_name'] ?? 'Pasien'}"
                                            : "Halo, Tamu",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Selamat datang di RSUD Porsea",
                                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Notification card (upcoming kontrol) — tappable → notification page
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientNotifikasiPage(nik: _nik),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF2F9E8F).withValues(alpha: 0.3)),
                                color: const Color(0xFF2F9E8F).withValues(alpha: 0.05),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.notifications_active, color: Color(0xFF2F9E8F)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Pengingat Kontrol",
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _isLoggedIn
                                              ? "Periksa jadwal kontrol rutin Anda"
                                              : "Masuk untuk melihat jadwal kontrol",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Menu Grid
                          const Text("Menu Utama",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.3,
                            children: [
                              _menuCard(
                                Icons.add_circle_outline,
                                "Ambil Antrian",
                                const Color(0xFF2F9E8F),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AntrianPage()),
                                  );
                                },
                              ),
                              _menuCard(
                                Icons.notifications_outlined,
                                "Notifikasi",
                                Colors.amber[700]!,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PatientNotifikasiPage(nik: _nik),
                                    ),
                                  );
                                },
                              ),
                              _menuCard(
                                Icons.info_outline,
                                "Informasi RS",
                                Colors.blue[600]!,
                                () => onSwitchTab(1), // Switch to Informasi tab
                              ),
                              _menuCard(
                                Icons.person_outline,
                                "Profil Saya",
                                Colors.purple[400]!,
                                () => onSwitchTab(3), // Switch to Profil tab
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ===== HOSPITAL PROFILE INFO =====
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Profil Rumah Sakit",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),

                                // Hospital name
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD7EDEB),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.local_hospital, color: Color(0xFF2F9E8F), size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("RSUD Porsea",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                          Text("Rumah Sakit Umum Daerah Porsea",
                                              style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 24),

                                // Address
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.location_on, color: Colors.blue[600], size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Alamat",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text("Jl. Sutomo No.5, Porsea, Toba, Sumatera Utara",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 24),

                                // Operating Hours
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.access_time, color: Colors.orange[700], size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Jam Operasional",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text("Senin - Sabtu: 08:00 - 16:00 WIB",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          Text("IGD: 24 Jam",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const Divider(height: 24),

                                // Phone
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.phone, color: Colors.green, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Telepon",
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text("(0632) 331088",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ============ PLACEHOLDER TAB ============
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[400], fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text("Segera hadir", style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          ],
        ),
      ),
    ),
  );
}}