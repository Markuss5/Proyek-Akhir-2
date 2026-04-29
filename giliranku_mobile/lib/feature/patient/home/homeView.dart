import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/feature/patient/informasi/informasiMenuView.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/feature/patient/profil/patientProfilTab.dart';
import 'package:giliranku/feature/patient/notifikasi/notifikasiView.dart';
import 'package:giliranku/feature/patient/antrian/antrian_view.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/core/widgets/navbar.dart';
import 'package:giliranku/core/widgets/header.dart';

/// MAIN ENTRY: HOME VIEW
/// Menangani navigasi utama (Bottom Interaction) dan State Management Tab
class HomeView extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  const HomeView({super.key, this.patientData});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Fungsi untuk berpindah antar tab navigasi
  void _switchTab(int index) {
    HapticFeedback.lightImpact(); // Memberikan feedback getar halus
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // List halaman utama yang diakses melalui Bottom Navbar
    final List<Widget> pages = [
      _BerandaTab(patientData: widget.patientData, onSwitchTab: _switchTab),
      const InformasiMenuPage(),
      const AntrianView(),
      PatientProfilView(patientData: widget.patientData),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// SECTION: BERANDA TAB
/// Komponen utama yang menampilkan Header, Layanan, dan Info RS
// ─────────────────────────────────────────────────────────────────────────────
class _BerandaTab extends StatelessWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _BerandaTab({this.patientData, required this.onSwitchTab});

  // Logika pengecekan status login pasien
  bool get _isLoggedIn => patientData != null && patientData!.containsKey('nik');
  String? get _nik     => _isLoggedIn ? patientData!['nik'] : null;
  String get _name     => _isLoggedIn ? (patientData!['patient_name'] ?? 'Pasien') : 'Tamu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header — AppHeader menangani SafeArea sendiri via MediaQuery
          SliverToBoxAdapter(
            child: AppHeader(
              mode: HeaderMode.home,
              patientName: _name,
              isLoggedIn: _isLoggedIn,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Status buka
                _OperasionalBadge(), // Indikator status buka RS
                const SizedBox(height: 10),

                // Kartu pengingat
                _ReminderCard(
                  isLoggedIn: _isLoggedIn,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NotifikasiView(nik: _nik))),
                ),
                const SizedBox(height: 22),

                // Grid Menu: 4 Layanan Utama (2x2)
                _SectionHeader(title: 'Layanan Utama', sub: 'Pilih layanan yang tersedia'),
                const SizedBox(height: 0),
                _MenuGrid(nik: _nik, onSwitchTab: onSwitchTab),
                const SizedBox(height: 14),

                // Footer Section: Informasi RSUD Porsea
                _SectionHeader(title: 'Info Rumah Sakit', sub: 'RSUD Porsea'),
                const SizedBox(height: 12),
                _HospitalCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// ATOMIC WIDGETS
/// Komponen kecil yang bersifat reusable atau spesifik untuk tampilan Beranda
// ─────────────────────────────────────────────────────────────────────────────
// 1. Grid Menu Utama (Dikalibrasi untuk mencegah Overflow)
class _OperasionalBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF22C55E), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text('Sedang Buka',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF22C55E))),
          const SizedBox(width: 6),
          const Text('·',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(width: 6),
          const Expanded(
            child: Text(
              'Senin–Sabtu  08:00 – 16:00 WIB',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Iconsax.clock, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String sub;
  const _SectionHeader({required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3)),
        const SizedBox(height: 2),
        Text(sub,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MENU GRID — 2×2 layanan utama
// childAspectRatio dikalibrasi agar tidak overflow
// ─────────────────────────────────────────────────────────────────────────────
class _MenuGrid extends StatelessWidget {
  final String? nik;
  final void Function(int) onSwitchTab;

  const _MenuGrid({this.nik, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    // Konfigurasi data menu (Icon, Label, Aksi)
    final menus = [
      _MenuData(
        icon: Iconsax.calendar_add,
        label: 'Ambil Antrian',
        desc: 'Daftar online',
        colors: [const Color(0xFF0D9B86), const Color(0xFF0FC49E)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AntrianView())),
      ),
      _MenuData(
        icon: Iconsax.notification_status,
        label: 'Notifikasi',
        desc: 'Pengingat jadwal',
        colors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => NotifikasiView(nik: nik))),
      ),
      _MenuData(
        icon: Iconsax.document_text,
        label: 'Informasi RS',
        desc: 'Info & layanan',
        colors: [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
        onTap: () => onSwitchTab(1),
      ),
      _MenuData(
        icon: Iconsax.profile_circle,
        label: 'Profil Saya',
        desc: 'Data & riwayat',
        colors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
        onTap: () => onSwitchTab(3),
      ),
    ];

    // Kalkulasi rasio grid agar responsif di berbagai ukuran layar
    final screenW = MediaQuery.of(context).size.width;
    final cardW   = (screenW - 40 - 12) / 2; // padding 20 kiri-kanan + gap 12
    final cardH   = cardW * 0.72;             // proporsi tinggi card

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: cardW / cardH,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true, // 🔥 WAJIB
      children: menus.map((m) => _MenuCard(data: m)).toList(),
    );
  }
}

// ─── Menu card individual ─────────────────────────────────────────────────────
class _MenuData {
  final IconData icon;
  final String label;
  final String desc;
  final List<Color> colors;
  final VoidCallback onTap;

  const _MenuData({
    required this.icon,
    required this.label,
    required this.desc,
    required this.colors,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final _MenuData data;
  const _MenuCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        data.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: data.colors.first.withValues(alpha: 0.10),
              blurRadius: 14, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dekorasi bulat di pojok kanan bawah
            Positioned(
              right: -14, bottom: -14,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.colors.first.withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon gradient
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: data.colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 18),
                  ),

                  // Label & deskripsi — di bawah
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.label,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 1),
                      Text(data.desc,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w400),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REMINDER CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ReminderCard extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onTap;
  const _ReminderCard({required this.isLoggedIn, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gold.withValues(alpha: 0.12),
              AppColors.gold.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.30), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.notification_status5,
                  color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengingat Janji Temu',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    isLoggedIn
                        ? 'Cek jadwal kontrol rutin Anda'
                        : 'Masuk untuk melihat jadwal kontrol',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Iconsax.arrow_right_3,
                  color: AppColors.gold, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOSPITAL CARD — info kontak & jam operasional
// ─────────────────────────────────────────────────────────────────────────────
class _HospitalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header kartu
          Container(
           padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Iconsax.hospital,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 11),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RSUD Porsea',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    Text('Rumah Sakit Umum Daerah',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),

          // Info rows
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _InfoRow(
                    icon: Iconsax.location,
                    value: 'Jl. Sutomo No.5, Porsea, Toba',
                    color: AppColors.primary),
                const _Divider(),
                _InfoRow(
                    icon: Iconsax.clock,
                    value: 'Senin–Sabtu: 08:00–16:00 WIB',
                    color: AppColors.gold),
                const _Divider(),
                _InfoRow(
                    icon: Iconsax.call,
                    value: '(0632) 331088',
                    color: Color(0xFF3B82F6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _InfoRow({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// Komponen Pembatas (Divider) Custom
class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppColors.divider),
      );
}