import 'package:flutter/material.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/theme/theme.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

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

  factory HospitalData.fromJson(Map<String, dynamic> json) {
    return HospitalData(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      vision: json['vision'] ?? '',
      mission: List<String>.from(json['mission'] ?? []),
      opHours: Map<String, String>.from(json['op_hours'] ?? {}),
      facilities: List<String>.from(json['facilities'] ?? []),
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class InformasiView extends StatefulWidget {
  const InformasiView({super.key});

  @override
  State<InformasiView> createState() => _InformasiViewState();
}

class _InformasiViewState extends State<InformasiView> {
  HospitalData? profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await ApiDataSource().getInformasi();
    if (mounted) {
      setState(() {
        profile = data != null ? HospitalData.fromJson(data) : null;
        _isLoading = false;
      });
    }
  }

  Future<void> _openMaps() async {
    final Uri url = Uri.parse(
      'geo:0,0?q=RSUD+Porsea+Toba',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('Gagal memuat data informasi.')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppHeader(
            mode: HeaderMode.page,
            title: 'Informasi RS',
            subtitle: 'RSUD Porsea',
            pageIcon: Iconsax.info_circle,
          ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tentang ${profile!.name}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 10),
                        Text(
                          profile!.description,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Visi'),
                        Text(profile!.vision,
                            style: const TextStyle(
                                color: AppColors.textPrimary, height: 1.4)),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Misi'),
                        ...profile!.mission.asMap().entries.map((e) {
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
                  const SizedBox(height: 20),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jam Operasional',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 15),
                        ...profile!.opHours.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(e.key,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary)),
                                  Text(e.value,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: e.key == 'IGD'
                                              ? AppColors.primary
                                              : AppColors.textPrimary)),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fasilitas Utama',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 15),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 3.0,
                          children: profile!.facilities
                              .map((f) => _buildFacilityChip(Icons.medical_services, f))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kontak & Lokasi',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 15),
                        _buildContactItem(Icons.location_on, profile!.address),
                        _buildContactItem(Icons.phone, profile!.phone),
                        _buildContactItem(Icons.email, profile!.email),
                        const SizedBox(height: 15),
                        InkWell(
                        onTap: _openMaps,
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_rounded,
                                  color: AppColors.primary, size: 40),
                              const SizedBox(height: 8),
                              Text('Buka di Google Maps',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      )
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

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary)),
    );
  }

  Widget _buildFacilityChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}