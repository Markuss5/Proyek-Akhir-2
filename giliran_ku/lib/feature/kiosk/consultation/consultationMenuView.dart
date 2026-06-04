import 'package:flutter/material.dart';

import 'consultationBpjsView.dart';
import 'consultationGeneralView.dart';

class ConsultationMenuView extends StatelessWidget {
  const ConsultationMenuView({super.key});

  static const Color _topColor = Color(0xFF17A889);
  static const Color _botColor = Color(0xFF0A7D67);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _botColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Antrian Konsultasi'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE6F5F0),
              Color(0xFFF0FAF6),
              Color(0xFFFAFFFE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pilih jenis pasien',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF063D2C),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sesuaikan dengan status rujukan agar tiket keluar lebih cepat.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF2E7A60),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'PILIHAN PASIEN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _topColor,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _ConsultationOptionCard(
              title: 'Pasien BPJS',
              subtitle: 'Gunakan NIK atau No BPJS',
              icon: Icons.shield_outlined,
              topColor: _topColor,
              botColor: _botColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsultationBpjsView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            _ConsultationOptionCard(
              title: 'Pasien Umum',
              subtitle: 'Pilih poli dan dokter tujuan',
              icon: Icons.person_outline,
              topColor: _topColor,
              botColor: _botColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConsultationGeneralView(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC3E8D8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5F0E6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF0A7D67),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pastikan data pasien valid agar nomor antrian keluar sesuai poli.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF2E6B55),
                          ),
                    ),
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

class _ConsultationOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color topColor;
  final Color botColor;
  final VoidCallback onTap;

  const _ConsultationOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.topColor,
    required this.botColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [topColor, botColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}