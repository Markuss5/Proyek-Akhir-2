import 'package:flutter/material.dart';
import 'package:giliranku_mobile/pages/splash/auth/home/informasi_view.dart';

class InformasiMenuPage extends StatelessWidget {
  const InformasiMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header dengan Logo
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2F9E8F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 90,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // List Menu
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
                    // Navigasi ke halaman poliklinik nanti
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.person_search_outlined,
                  title: 'Informasi Dokter',
                  subtitle: 'Informasi dokter dan jadwal praktek di setiap poliklinik',
                  onTap: () {
                    // Navigasi ke halaman dokter nanti
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, 
      {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2F9E8F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF2F9E8F)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}