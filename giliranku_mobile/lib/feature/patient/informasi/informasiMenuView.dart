import 'package:flutter/material.dart';
import 'package:giliranku/feature/patient/informasi/informasiView.dart';
import 'package:giliranku/feature/patient/informasi/informasi_dokter.dart';
import 'package:giliranku/feature/patient/informasi/informasiPoliklinikView.dart';
import 'package:giliranku/feature/patient/home/homeView.dart';

class InformasiMenuPage extends StatelessWidget {
  const InformasiMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // HEADER MENU 
            _buildMenuHeader(context),

            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildMenuCard(
                    context,
                    icon: Icons.apartment_rounded,
                    title: 'Informasi Rumah Sakit',
                    subtitle:
                        'Profil, visi & misi, kontak, dan jam operasional RSUD Porsea',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const InformasiView()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.medical_services_outlined,
                    title: 'Informasi Poliklinik',
                    subtitle:
                        'Daftar poliklinik beserta layanan yang tersedia',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const InformasiPoliklinikView()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    icon: Icons.person_search_rounded,
                    title: "Informasi Dokter",
                    subtitle:
                        "Informasi dokter dan jadwal praktek di setiap poliklinik",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InformasiDokterPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER KHUSUS MENU
  Widget _buildMenuHeader(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0DB89E),
            Color(0xFF0A6B5C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          // Button BACK
          GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeView()),
              (route) => false,
            );
          },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: Colors.white, size: 18),
            ),
          ),

          const SizedBox(width: 12),

          //  TITLE
          const Expanded(
            child: Text(
              "Pusat Informasi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          //  ICON MENU
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.grid_view_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0D9B86)),
        ),
        title:
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}