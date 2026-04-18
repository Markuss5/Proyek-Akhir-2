import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'profil_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
=======
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/pages/splash/auth/home/patient_profil_tab.dart';
import 'package:giliranku/pages/splash/auth/home/informasi_view.dart';
import 'package:giliranku/pages/splash/auth/home/patient_notifikasi_page.dart';
import 'package:giliranku/pages/splash/auth/antrian/antrian_page.dart';

// Shared widgets
import 'package:giliranku/widgets/app_colors.dart';
import 'package:giliranku/widgets/header.dart';
import 'package:giliranku/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  const HomePage({super.key, this.patientData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    super.initState();
    _pages = [
      _BerandaTab(patientData: widget.patientData, onSwitchTab: _switchTab),
      const informasiView(),
      const _PlaceholderTab(title: 'Antrian', icon: Icons.calendar_month_rounded),
      PatientProfilTab(patientData: widget.patientData),
    ];
  }
>>>>>>> Stashed changes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // --- HEADER HIJAU YANG DIPERBAIKI ---
          Stack(
            alignment: Alignment.center,
            children: [
              // Menggunakan Transform.scale agar lengkungan meluber ke samping (efek lebar)
              Transform.scale(
                scaleX: 1.5, // Melebarkan container ke samping luar layar
                child: Container(
                  height: 280, 
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
              
              // Logo GiliranKu
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 200, // Ukuran lebar logo ditingkatkan agar lebih jelas
                  fit: BoxFit.contain, 
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "Logo tidak ditemukan",
                      style: TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),

            const SizedBox(height: 25),

            // --- PENGINGAT JANJI TEMU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Pengingat Janji Temu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Hari ini",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2F9E8F).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7EDEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications, color: Color(0xFF2F9E8F)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Poli Paru - dr. Budi Santoso",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            "ID: PA2-2024-1257",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      "09:45",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
=======
      backgroundColor: AppColors.surface,
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// ─────────────────────────────────────────
// BERANDA TAB
// ─────────────────────────────────────────
class _BerandaTab extends StatelessWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _BerandaTab({this.patientData, required this.onSwitchTab});

  bool get _isLoggedIn => patientData != null && patientData!.containsKey('nik');
  String? get _nik     => _isLoggedIn ? patientData!['nik'] : null;
  String get _name     => _isLoggedIn ? (patientData!['patient_name'] ?? 'Pasien') : 'Tamu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header shared ──
          SliverToBoxAdapter(
            child: AppHeader(
              patientName: _name,
              isLoggedIn: _isLoggedIn,
              showGreeting: true,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 34, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Pengingat ──
                _ReminderCard(
                  isLoggedIn: _isLoggedIn,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PatientNotifikasiPage(nik: _nik))),
>>>>>>> Stashed changes
                ),
                const SizedBox(height: 28),

                // ── Layanan ──
                const _SectionTitle('Layanan'),
                const SizedBox(height: 14),
                _buildMenuGrid(context),
                const SizedBox(height: 28),

                // ── Info RS ──
                const _SectionTitle('Info Rumah Sakit'),
                const SizedBox(height: 14),
                _buildHospitalCard(),
                const SizedBox(height: 16),
              ]),
            ),

            const SizedBox(height: 18),

            // --- LAYANAN ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Layanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.25, 
                children: [
                  _menuItem(Icons.calendar_month, "Ambil Antrian"),
                  _menuItem(Icons.notifications, "Nontifikasi"),
                 _menuItem(
                    Icons.apartment, 
                    "Informasi", 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilView()),
                      );
                    },
                  ),
                  
                  _menuItem(Icons.person, "Profil"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- JAM OPRASIONAL ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2F9E8F).withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7EDEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.apartment, color: Color(0xFF2F9E8F)),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Jam Oprasional",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          "Senin - Sabtu: 08:00 - 16:00 WIB",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          "IGD: 24 Jam",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Beranda aktif
      onTap: (index) {
        if (index == 1) { // Index 1 adalah tombol 'Informasi'
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilView()),
          );
        }
        // Tambahkan logika index lain jika perlu (misal index 3 untuk Profil)
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
        BottomNavigationBarItem(icon: Icon(Icons.apartment), label: "Informasi"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Antrian"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
      ],
    ),
    );
  }

Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap, // Menjalankan fungsi saat diklik
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2F9E8F)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD7EDEB),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2F9E8F), size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2F9E8F),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
<<<<<<< Updated upstream
    ),
  );
}}
=======
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      _MenuData(
        icon: Icons.confirmation_number_rounded,
        label: 'Ambil Antrian',
        gradient: [AppColors.primary, AppColors.primaryLight],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AntrianPage())),
      ),
      _MenuData(
        icon: Icons.notifications_rounded,
        label: 'Notifikasi',
        gradient: [AppColors.gold, const Color(0xFFFFAA00)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PatientNotifikasiPage(nik: _nik))),
      ),
      _MenuData(
        icon: Icons.apartment_rounded,
        label: 'Informasi RS',
        gradient: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        onTap: () => onSwitchTab(1),
      ),
      _MenuData(
        icon: Icons.person_rounded,
        label: 'Profil Saya',
        gradient: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
        onTap: () => onSwitchTab(3),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.5,
      children: menus.map((m) => _MenuCard(data: m)).toList(),
    );
  }

  Widget _buildHospitalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RSUD Porsea',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                      SizedBox(height: 2),
                      Text('Rumah Sakit Umum Daerah Porsea',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _infoRow(Icons.location_on_rounded, 'Alamat',
                    'Jl. Sutomo No.5, Porsea, Toba, Sumatera Utara',
                    const Color(0xFF3B82F6)),
                _divider(),
                _infoRow(Icons.access_time_rounded, 'Jam Operasional',
                    'Senin–Sabtu: 08:00–16:00 WIB\nIGD: 24 Jam',
                    AppColors.gold),
                _divider(),
                _infoRow(Icons.phone_rounded, 'Telepon', '(0632) 331088',
                    const Color(0xFF22C55E)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 3),
              Text(value,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.divider),
  );
}

// ─────────────────────────────────────────
// REMINDER CARD
// ─────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onTap;
  const _ReminderCard({required this.isLoggedIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.gold.withValues(alpha: 0.12),
            AppColors.gold.withValues(alpha: 0.04),
          ]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.notifications_active_rounded, color: AppColors.gold, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Pengingat Janji Temu',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(6)),
                      child: const Text('Hari ini',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    isLoggedIn ? 'Periksa jadwal kontrol rutin Anda' : 'Masuk untuk melihat jadwal kontrol',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// MENU CARD
// ─────────────────────────────────────────
class _MenuData {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _MenuData({required this.icon, required this.label, required this.gradient, required this.onTap});
}

class _MenuCard extends StatelessWidget {
  final _MenuData data;
  const _MenuCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: data.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(data.icon, color: Colors.white, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(data.label,
                  style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary, height: 1.3,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SECTION TITLE
// ─────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800,
              color: AppColors.textPrimary, letterSpacing: -0.4,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────
// PLACEHOLDER TAB
// ─────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderTab({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 44, color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, letterSpacing: -0.5,
                )),
            const SizedBox(height: 6),
            const Text('Segera hadir',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
>>>>>>> Stashed changes
