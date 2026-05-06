import 'package:flutter/material.dart';

import 'booking/booking_lookup_view.dart';
import 'consultation/consultation_menu_view.dart';
import 'pharmacy/pharmacy_queue_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width >= 900
        ? 3
        : width >= 640
            ? 2
            : 2;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE7F7F1),
                  Color(0xFFF2FBF8),
                  Color(0xFFFFFFFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -30,
            child: _HaloCircle(
              size: 140,
              color: const Color(0xFFBDEBDC),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: _HaloCircle(
              size: 160,
              color: const Color(0xFFCFEFE3),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _DashboardHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.05,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _DashboardCard(action: actions[index]);
                      },
                      childCount: actions.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: _InfoBanner(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_DashboardAction> _buildActions(BuildContext context) {
    return [
      _DashboardAction(
        title: 'Antrian Konsultasi',
        subtitle: 'BPJS & Umum',
        icon: Icons.medical_services_outlined,
        color: const Color(0xFF54D9B4),
        accent: const Color(0xFF2FAA85),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ConsultationMenuView(),
            ),
          );
        },
      ),
      _DashboardAction(
        title: 'Antrian Farmasi',
        subtitle: 'Ambil nomor obat',
        icon: Icons.local_pharmacy_outlined,
        color: const Color(0xFF6EE0C3),
        accent: const Color(0xFF3BB894),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PharmacyQueueView(),
            ),
          );
        },
      ),
      _DashboardAction(
        title: 'Cetak Antrian',
        subtitle: 'Kode booking',
        icon: Icons.qr_code_2_outlined,
        color: const Color(0xFF7FE4CA),
        accent: const Color(0xFF43BFA0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BookingLookupView(),
            ),
          );
        },
      ),
    ];
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A0F8C6D),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Image.asset(
                  'lib/assets/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RSUD Porsea',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A3D2E),
                        ),
                  ),
                  Text(
                    'Sistem Antrian Terpadu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4C7B6A),
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Pilih layanan yang Anda butuhkan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A3D2E),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cek antrian, farmasi, atau cetak tiket booking dengan cepat.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF557A6B),
                ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final _DashboardAction action;

  const _DashboardCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: action.onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                action.color.withOpacity(0.95),
                action.accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A0F8C6D),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD2EDE2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Color(0xFF2FAE86),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tetap sehat bersama kami',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan nomor antrian sesuai poli agar pelayanan lebih cepat.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5D7C70),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HaloCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _HaloCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.45),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DashboardAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color accent;
  final VoidCallback onTap;

  const _DashboardAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.accent,
    required this.onTap,
  });
}
