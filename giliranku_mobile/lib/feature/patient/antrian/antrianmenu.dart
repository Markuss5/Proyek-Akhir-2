import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/feature/patient/antrian/antrian_view.dart';
import 'package:giliranku/feature/patient/antrian/antrian_bpjs_view.dart';
import 'package:iconsax/iconsax.dart';

class AntrianMenuView extends StatelessWidget {
  const AntrianMenuView({super.key});

  void _keBpjs(BuildContext context) {
  HapticFeedback.lightImpact();
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AntrianBpjsView()),
  );
}

  void _keUmum(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AntrianView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              mode: HeaderMode.page,
              title: 'Ambil Antrian',
              subtitle: 'RSUD Porsea',
              pageIcon: Iconsax.ticket,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih Jenis Pasien',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sesuaikan dengan kepesertaan Anda',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Kartu BPJS
                    _TipeCard(
                      icon: Iconsax.shield_tick,
                      title: 'Pasien BPJS',
                      subtitle: 'Peserta JKN / KIS',
                      color: const Color(0xFF0D9B86),
                      onTap: () => _keBpjs(context), // ← belum ada halamannya
                    ),
                    const SizedBox(height: 12),

                    // Kartu Umum
                    _TipeCard(
                      icon: Iconsax.people,
                      title: 'Pasien Umum',
                      subtitle: 'Pembayaran mandiri',
                      color: const Color(0xFF6366F1),
                      onTap: () => _keUmum(context), // ← ke AntrianView
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _TipeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}