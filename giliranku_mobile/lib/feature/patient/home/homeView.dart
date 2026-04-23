import 'package:flutter/material.dart';
import 'package:giliranku/feature/patient/informasi/informasiMenuView.dart';
import 'package:iconsax/iconsax.dart';

// Import sesuai folder kamu
import 'package:giliranku/feature/patient/profil/patientProfilTab.dart';
import 'package:giliranku/feature/patient/notifikasi/notifikasiView.dart';
import 'package:giliranku/feature/patient/antrian/antrianView.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/core/widgets/navbar.dart';

class HomeView  extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  const HomeView({super.key, this.patientData});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Logika switch tab 
  void _switchTab(int index) => setState(() => _currentIndex = index);

@override
  Widget build(BuildContext context) {
  final List<Widget> pages = [
    _BerandaTab(patientData: widget.patientData, onSwitchTab: _switchTab),
    const InformasiMenuPage(),
    const AntrianView(), // ← ganti ini
    PatientProfilView(patientData: widget.patientData),
  ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      // 2. Panggil 'pages' yang baru saja dibuat di atas
      body: pages[_currentIndex], 
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// ─────────────────────────────────────────
// BERANDA TAB (ISI UTAMA HALAMAN HOME)
// ─────────────────────────────────────────
class _BerandaTab extends StatelessWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _BerandaTab({this.patientData, required this.onSwitchTab});

  // Logika pengecekan login tetap sama
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
          SliverToBoxAdapter(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scaleX: 1.5,
                  child: Container(
                    height: 280,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F9E8F), // Warna hijau RSUD Porsea
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(180),
                        bottomRight: Radius.circular(180),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                
                     Image.asset(
                        'assets/images/logo.png',
                        height: 90,
                        width: 90,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Iconsax.hospital, color: Colors.white, size: 60),
                      ),
                      const SizedBox(height: 12),
                      // Sapaan menggunakan data login kamu
                      Text(
                        "Halo, $_name",
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- ISI KONTEN (LOGIKA & LAYOUT KAMU) ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ReminderCard(
                  isLoggedIn: _isLoggedIn,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotifikasiView(nik: _nik))),
                ),
                const SizedBox(height: 28),
                const _SectionTitle('Layanan'),
                const SizedBox(height: 14),
                _buildMenuGrid(context),
                const SizedBox(height: 28),
                const _SectionTitle('Info Rumah Sakit'),
                const SizedBox(height: 14),
                _buildHospitalCard(),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Grid Menu menggunakan data mapping kamu
  Widget _buildMenuGrid(BuildContext context) {
    final menus = [
      _MenuData(
        icon: Iconsax.calendar_1,
        label: 'Ambil Antrian',
        gradient: [AppColors.primary, AppColors.primaryLight],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AntrianView())),
      ),
      _MenuData(
        icon: Iconsax.notification,
        label: 'Notifikasi',
        gradient: [AppColors.gold, const Color(0xFFFFAA00)],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotifikasiView(nik: _nik))),
      ),
      _MenuData(
        icon: Iconsax.info_circle,
        label: 'Informasi RS',
        gradient: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        onTap: () => onSwitchTab(1),
      ),
      _MenuData(
        icon: Iconsax.user,
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
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _infoRow(Iconsax.location, 'Alamat', 'Jl. Sutomo No.5, Porsea, Toba'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            _infoRow(Iconsax.clock, 'Operasional', 'Senin–Sabtu: 08:00–16:00 WIB'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.divider),
            ),
            _infoRow(Iconsax.call, 'Telepon', '(0632) 331088'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// WIDGET PENDUKUNG (TETAP SAMA SEPERTI KODEMU)
// ─────────────────────────────────────────

class _MenuData {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  _MenuData({required this.icon, required this.label, required this.gradient, required this.onTap});
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
          boxShadow: [BoxShadow(color: data.gradient.first.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: data.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
              ),
            ),
            const SizedBox(width: 12),
            Icon(data.icon, color: data.gradient.first, size: 22),
            const SizedBox(width: 10),
            Expanded(child: Text(data.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          ],
        ),
      ),
    );
  }
}

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Iconsax.notification_status5, color: AppColors.gold, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengingat Janji Temu', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(
                    isLoggedIn ? 'Cek jadwal kontrol rutin Anda' : 'Masuk untuk melihat jadwal kontrol',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final IconData icon;
  const _PlaceholderTab({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 48, color: AppColors.textMuted), const SizedBox(height: 12), Text(title, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold))]));
  }
}