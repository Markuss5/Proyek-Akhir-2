import 'package:flutter/material.dart';
import 'package:giliranku_mobile/widgets/app_colors.dart';

// 1. DATA MODEL
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
    'Kualitas Layanan: Menyelenggarakan perbaikan berkelanjutan terhadap mutu layanan untuk kepuasan pasien.',
  ],
  opHours: {
    'Senin - Sabtu': '08:00 - 16:00 WIB',
    'IGD': '24 Jam',
  },
  facilities: ['Poliklinik', 'Rawat Inap', 'IGD 24 Jam', 'Laboratorium'],
  address: 'Jl. Sisingamangaraja, Porsea, Kab. Toba, Sumatera Utara',
  phone: '(0632) 21234',
  email: 'info@rsudporsea.go.id',
);

// 3. VIEW
class InformasiView extends StatefulWidget {
  const InformasiView({super.key});

  @override
  State<InformasiView> createState() => _InformasiViewState();
}

class _InformasiViewState extends State<InformasiView> {
  // Alias agar lebih mudah memanggil data dummy di bawah
  final profile = rsudPorseaData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PETAK ---
            Container(
              height: 155,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -20, right: -20, child: _circle(130, 0.06)),
                  Positioned(bottom: 20, left: -10, child: _circle(90, 0.04)),
                  
                  // TOMBOL KEMBALI
                  Positioned(
                    top: 45, 
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2), 
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          profile.name.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  // Section: Tentang
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tentang ${profile.name}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        Text(
                          profile.description,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section: Visi Misi
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Visi'),
                        Text(profile.vision,
                            style: const TextStyle(
                                color: AppColors.textPrimary, height: 1.4)),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Misi'),
                        ...profile.mission.asMap().entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text('${e.key + 1}. ${e.value}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    height: 1.4,
                                    fontSize: 13.5)),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section: Fasilitas
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fasilitas',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.8,
                          children: [
                            _buildFacilityChip(Icons.medical_services_outlined, 'Poliklinik'),
                            _buildFacilityChip(Icons.bed_outlined, 'Rawat Inap'),
                            _buildFacilityChip(Icons.local_hospital_outlined, 'IGD 24 Jam'),
                            _buildFacilityChip(Icons.biotech_outlined, 'Laboratorium'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Section: Kontak & Maps
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kontak & Alamat',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 15),
                        _buildContactItem(Icons.location_on_rounded, profile.address),
                        _buildContactItem(Icons.phone_rounded, profile.phone),
                        _buildContactItem(Icons.email_rounded, profile.email),
                        const SizedBox(height: 15),
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.divider.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.map_rounded, color: AppColors.primary),
                              ),
                              const SizedBox(height: 10),
                              const Text('lihat di Google Maps',
                                  style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ],
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
    );
  }

  // --- HELPER WIDGETS ---
  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }

  Widget _buildFacilityChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider)),
              child: Text(text,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}