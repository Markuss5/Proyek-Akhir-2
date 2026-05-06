import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/feature/admin/kontrol/adminKontrolView.dart';
import 'package:giliranku/feature/admin/kelola/adminKelolaView.dart';
import 'package:giliranku/feature/admin/kunjungan/adminKunjunganView.dart';
import 'package:giliranku/feature/admin/profil/adminProfilView.dart';

class AdminBerandaView extends StatefulWidget {
  const AdminBerandaView({super.key});

  @override
  State<AdminBerandaView> createState() => _AdminBerandaViewState();
}

class _AdminBerandaViewState extends State<AdminBerandaView> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _BerandaPage(onSwitchTab: _switchTab),
      const AdminKontrolView(),
      const AdminKelolaView(),
      const AdminKunjunganView(),
      const AdminProfilView(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _BerandaPage extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _BerandaPage({required this.onSwitchTab});

  @override
  State<_BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<_BerandaPage> {
  bool _isLoading = true;
  int _pasienHariIni = 0;
  int _dokterAktif = 0;
  int _jumlahPoli = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    final data = await ApiDataSource().fetchDashboardStats();
    if (mounted) {
      setState(() {
        _pasienHariIni = (data?['pasien_hari_ini'] as int?) ?? 0;
        _dokterAktif   = (data?['dokter_aktif']    as int?) ?? 0;
        _jumlahPoli    = (data?['jumlah_poliklinik'] as int?) ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        color: const Color(0xFF2F9E8F),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _buildDashboardCard(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuCard(
                            icon: Icons.notifications_active_rounded,
                            title: 'Notifikasi\nKontrol',
                            subtitle: 'Pengingat pasien',
                            color: const Color(0xFF2F9E8F),
                            onTap: () => widget.onSwitchTab(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMenuCard(
                            icon: Icons.local_hospital_rounded,
                            title: 'Kelola\nPoliklinik',
                            subtitle: 'Data Poli & Layanan',
                            color: const Color(0xFF5C6BC0),
                            onTap: () => widget.onSwitchTab(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenuCard(
                            icon: Icons.bar_chart_rounded,
                            title: 'Laporan\nKunjungan',
                            subtitle: 'Statistik kunjungan',
                            color: const Color(0xFFFF7043),
                            onTap: () => widget.onSwitchTab(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMenuCard(
                            icon: Icons.calendar_month_rounded,
                            title: 'Jadwal\nDokter',
                            subtitle: 'Atur jadwal praktek',
                            color: const Color(0xFF66BB6A),
                            onTap: () => widget.onSwitchTab(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildOperationalHours(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF2F9E8F),
      child: Stack(
        children: [
          Positioned(
            bottom: -30, right: -30,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            top: -20, left: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 160,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.medical_services, color: Colors.white, size: 32),
                            SizedBox(width: 8),
                            Text('GiliranKu',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text('Dashboard Admin',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Selamat datang kembali! 👋',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dashboard Card ──────────────────────────────────────────────────────────
  Widget _buildDashboardCard() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()))
            : Row(
                children: [
                  _buildStatCard(
                    '$_pasienHariIni', 'Pasien\nHari Ini',
                    const Color(0xFFE8F5E9), const Color(0xFF4CAF50)),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '$_dokterAktif', 'Dokter\nAktif',
                    const Color(0xFFE3F2FD), const Color(0xFF2196F3)),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    '$_jumlahPoli', 'Jumlah\nPoliklinik',
                    const Color(0xFFFFF3E0), const Color(0xFFFF9800)),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(
      String value, String label, Color bgColor, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: accentColor)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[700], height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13, height: 1.3)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalHours() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD7EDEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.access_time_rounded,
                color: Color(0xFF2F9E8F), size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jam Operasional',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 4),
                Text('Senin - Sabtu: 08:00 - 16:00 WIB',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('IGD: 24 Jam',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2F9E8F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Buka',
                style: TextStyle(
                    color: Color(0xFF2F9E8F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  static const _primaryColor = Color(0xFF25A699);

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Beranda'),
    _NavItem(icon: Icons.notifications_active_rounded, label: 'Kontrol'),
    _NavItem(icon: Icons.description_rounded, label: 'Kelola'),
    _NavItem(icon: Icons.apartment_rounded, label: 'Kunjungan'),
    _NavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 0.5),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
                color: Colors.grey.withOpacity(0.12), width: 0.5),
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? _primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _items[i].icon,
                            key: ValueKey('icon_${i}_$isActive'),
                            size: 24,
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : Colors.grey.shade500,
                          ),
                          child: Text(_items[i].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}