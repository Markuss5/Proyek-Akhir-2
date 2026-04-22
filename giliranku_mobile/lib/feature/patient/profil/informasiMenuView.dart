import 'package:flutter/material.dart';
import 'package:giliranku/feature/patient/profil/informasiView.dart';

class InformasiMenuPage extends StatelessWidget {
  const InformasiMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF25A699),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pusat Informasi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuCard(
                  context,
                  icon: Icons.apartment_rounded,
                  title: 'Informasi Rumah Sakit',
                  subtitle: 'Profil, visi & misi, kontak, dan jam operasional RSUD Porsea',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InformasiView()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.medical_services_outlined,
                  title: 'Informasi Poliklinik',
                  subtitle: 'Daftar poliklinik beserta layanan yang tersedia',
                  onTap: () {
                    // Navigasi poliklinik jika sudah ada
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.person_search_rounded,
                  title: "Informasi Dokter",
                  subtitle: "Informasi dokter dan jadwal praktek di setiap poliklinik",
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => InformasiDokterPage()),
                    // );
                  },
                ),
              ],
            ),
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
            color: Colors.black.withValues(alpha: 0.02),
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
          child: Icon(icon, color: const Color(0xFF25A699)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}