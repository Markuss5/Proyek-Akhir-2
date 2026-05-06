import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/feature/patient/antrian/antrianMenuView.dart';
import 'package:giliranku/feature/patient/informasi/informasiMenuView.dart';
import 'package:iconsax/iconsax.dart';
import 'package:giliranku/feature/patient/profil/patientProfilView.dart';
import 'package:giliranku/feature/patient/notifikasi/notifikasiView.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/core/widgets/navbar.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';

class HomeView extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  const HomeView({super.key, this.patientData});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _BerandaTab(patientData: widget.patientData, onSwitchTab: _switchTab),
      InformasiMenuPage(onSwitchTab: _switchTab),
      AntrianMenuView(onSwitchTab: _switchTab, patientData: widget.patientData),
      PatientProfilView(patientData: widget.patientData, onSwitchTab: _switchTab),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          _switchTab(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: pages[_currentIndex],
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: _switchTab,
        ),
      ),
    );
  }
}

class _BerandaTab extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _BerandaTab({this.patientData, required this.onSwitchTab});

  @override
  State<_BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<_BerandaTab> {
  bool get _isLoggedIn => widget.patientData != null && widget.patientData!.containsKey('nik');
  String? get _nik     => _isLoggedIn ? widget.patientData!['nik'] : null;
  String get _name     => _isLoggedIn ? (widget.patientData!['patient_name'] ?? 'Pasien') : 'Tamu';

  Map<String, dynamic>? _infoData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    final info = await ApiDataSource().getInformasi();
    if (mounted) {
      setState(() {
        _infoData = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchInfo,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
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

                if (!_isLoading && _infoData != null)
                  _OperasionalBadge(infoData: _infoData!)
                else
                  const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
                
                const SizedBox(height: 10),

                _ReminderCard(
                  isLoggedIn: _isLoggedIn,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NotifikasiView(nik: _nik))),
                ),
                const SizedBox(height: 22),
                const _SectionHeader(title: 'Layanan Utama', sub: 'Pilih layanan yang tersedia'),
                const SizedBox(height: 10),
                _MenuGrid(
                  nik: _nik,
                  patientData: widget.patientData,
                  onSwitchTab: widget.onSwitchTab,
                ),
                const SizedBox(height: 14),
                const _SectionHeader(title: 'Info Rumah Sakit', sub: 'RSUD Porsea'),
                const SizedBox(height: 12),
                if (!_isLoading && _infoData != null)
                  _HospitalCard(infoData: _infoData!)
                else
                  const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
              ]),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _OperasionalBadge extends StatelessWidget {
  final Map<String, dynamic> infoData;
  const _OperasionalBadge({required this.infoData});

  @override
  Widget build(BuildContext context) {
    final opHours = infoData['op_hours'] as Map<String, dynamic>?;
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;
    
    final String todaySchedule = isSunday 
        ? (opHours?['Minggu'] ?? 'Libur (Kecuali IGD)')
        : (opHours?['Senin - Sabtu'] ?? '08:00 - 16:00 WIB');
    
    bool isOpen = false;
    if (!todaySchedule.toLowerCase().contains('libur')) {
      try {
        final parts = todaySchedule.split('-');
        if (parts.length >= 2) {
          final start = parts[0].trim().split(':');
          final endStr = parts[1].replaceAll('WIB', '').trim().split(':');
          
          final startH = int.parse(start[0]);
          final startM = int.parse(start[1]);
          final endH = int.parse(endStr[0]);
          final endM = int.parse(endStr[1]);

          final nowTime = now.hour * 60 + now.minute;
          final startTime = startH * 60 + startM;
          final endTime = endH * 60 + endM;

          isOpen = nowTime >= startTime && nowTime <= endTime;
        } else {
          isOpen = true;
        }
      } catch (_) {
        isOpen = true;
      }
    }

    final statusText = isOpen ? 'Sedang Buka' : 'Rumah Sakit Sedang Tutup';
    final statusColor = isOpen ? const Color(0xFF22C55E) : AppColors.error;
    final String dayPrefix = isSunday ? 'Minggu' : 'Senin - Sabtu';

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
            decoration: BoxDecoration(
                color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(statusText,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor)),
          const SizedBox(width: 6),
          const Text('·',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$dayPrefix, $todaySchedule',
              style: const TextStyle(
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

class _MenuGrid extends StatelessWidget {
  final String? nik;
  final Map<String, dynamic>? patientData;
  final void Function(int) onSwitchTab;

  const _MenuGrid({this.nik, this.patientData, required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final menus = [
      _MenuData(
        icon: Iconsax.calendar_add,
        label: 'Ambil Antrian',
        desc: 'Daftar online',
        colors: [const Color(0xFF0D9B86), const Color(0xFF0FC49E)],
        onTap: () => onSwitchTab(2),
      ),
      _MenuData(
        icon: Iconsax.notification_status,
        label: 'Notifikasi',
        desc: 'Pengingat jadwal',
        colors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotifikasiView(nik: nik)),
        ),
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

    final screenW = MediaQuery.of(context).size.width;
    final cardW   = (screenW - 40 - 12) / 2;
    final cardH   = cardW * 0.72;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: cardW / cardH,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: menus.map((m) => _MenuCard(data: m)).toList(),
    );
  }
}

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
        clipBehavior: Clip.hardEdge, 
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: data.colors.first.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
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

class _HospitalCard extends StatelessWidget {
  final Map<String, dynamic> infoData;
  const _HospitalCard({required this.infoData});

  @override
  Widget build(BuildContext context) {
    final String name = infoData['name'] ?? 'RSUD Porsea';
    final String address = infoData['address'] ?? 'Jl. Patuan Nagari, Porsea, Kab. Toba';
    final String phone = infoData['phone'] ?? '(0632) 41012';
    
    final opHoursMap = infoData['op_hours'] as Map<String, dynamic>?;
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;
    final String opHours = isSunday 
        ? 'Minggu: ${opHoursMap?['Minggu'] ?? 'Libur'}'
        : 'Senin-Sabtu: ${opHoursMap?['Senin - Sabtu'] ?? '08:00-16:00 WIB'}';

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
                  child: const Icon(Iconsax.hospital, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                      const Text('Rumah Sakit Umum Daerah',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _InfoRow(
                    icon: Iconsax.location,
                    value: address,
                    color: AppColors.primary),
                const _Divider(),
                _InfoRow(
                    icon: Iconsax.clock,
                    value: opHours,
                    color: AppColors.gold),
                const _Divider(),
                _InfoRow(
                    icon: Iconsax.call,
                    value: phone,
                    color: const Color(0xFF3B82F6)),
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

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: AppColors.divider),
      );
}