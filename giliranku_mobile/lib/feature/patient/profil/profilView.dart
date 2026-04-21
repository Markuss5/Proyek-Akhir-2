import 'package:flutter/material.dart';

// 1. DATA MODEL (Sesuai Step 2.5 & 2.7 di Sequence Diagram)
// Ini adalah objek yang menampung data informasi RS
class HospitalData {
  final String name;
  final String description;
  final String vision;
  final List<String> mission;
  final Map<String, String> opHours;
  final List<String> facilities;
  final String address;
  final String phone;
  final String email;

  HospitalData({
    required this.name,
    required this.description,
    required this.vision,
    required this.mission,
    required this.opHours,
    required this.facilities,
    required this.address,
    required this.phone,
    required this.email,
  });
}

// 2. DATA DUMMY
final HospitalData rsudPorseaData = HospitalData(
  name: 'RSUD Porsea',
  description:
      'RSUD Porsea adalah Rumah Sakit Umum Daerah milik Pemerintah Kabupaten Toba, Sumatera Utara, yang berstatus Tipe C dan telah terakreditasi Paripurna. Terletak di Parparean, Porsea, RSUD ini berfungsi sebagai pusat rujukan utama di Kabupaten Toba, menawarkan layanan unggulan seperti operasi katarak Phacoemulsification, laparoscopy, dan dental panoramic.',
  vision:
      'Menjadi rumah sakit unggulan yang memberikan pelayanan kesehatan berkualitas dan terjangkau bagi masyarakat.',
  mission: [
    'Pelayanan Prima: Menyelenggarakan pelayanan kesehatan yang cepat, tepat, ramah, dan aman.',
    'SDM Profesional: Meningkatkan kompetensi dan integritas tenaga kesehatan.',
    'Sarana & Prasarana: Meningkatkan kualitas fasilitas pendukung pelayanan.',
    'Manajemen Efisien: Menerapkan sistem manajemen yang transparan, efektif, dan akuntabel.',
    'Kualitas Layanan: Melakukan perbaikan berkelanjutan terhadap mutu layanan untuk kepuasan pasien.',
  ],
  opHours: {'Senin - Sabtu': '08:00 - 16:00 WIB', 'IGD': '24 Jam'},
  facilities: ['Poliklinik', 'Rawat Inap', 'IGD 24 Jam', 'Laboratorium'],
  address: 'Jl. Sisingamangaraja, Porsea, Kab. Toba, Sumatera Utara',
  phone: '(0632) 21234',
  email: 'info@rsudporsea.go.id',
);

// 3. VIEW (Sesuai Komponen "ProfilView" di Sequence Diagram)
class ProfilView extends StatelessWidget {
  const ProfilView({super.key});

  @override
  Widget build(BuildContext context) {
    // Sesuai Step 2.8 & 2.9: Menampilkan data ke view
    final profile = rsudPorseaData;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F9E8F),
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil Rumah Sakit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Section: Tentang ---
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang ${profile.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profile.description,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Section: Visi Misi ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD7EDEB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Visi'),
                  Text(profile.vision, style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Misi'),
                  ...profile.mission.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${e.key + 1}. ${e.value}',
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Section: Jam Operasional ---
            _buildWhiteCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFD7EDEB),
                    child: Icon(Icons.access_time, color: Color(0xFF2F9E8F)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jam Operasional',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...profile.opHours.entries.map(
                          (e) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                e.value,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: e.key == 'IGD'
                                      ? const Color(0xFF2F9E8F)
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Section: Fasilitas ---
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3.5,
                    children: profile.facilities
                        .map((f) => _buildFacilityChip(f))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Section: Kontak ---
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kontak & Alamat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _buildContactItem(Icons.location_on, profile.address),
                  _buildContactItem(Icons.phone, profile.phone),
                  _buildContactItem(Icons.email, profile.email),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2F9E8F),
        ),
      ),
    );
  }

  Widget _buildFacilityChip(String text) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD7EDEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF2F9E8F),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F9E8F)),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}
