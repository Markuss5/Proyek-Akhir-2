import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class PolisSelectionScreen extends StatelessWidget {
  final String serviceCategory; // 'consultation' atau 'pharmacy'
  final String patientType; // 'bpjs' atau 'umum'
  final String? patientNik;
  final String? patientName;
  final String? patientDate;
  final String? patientPhone;

  const PolisSelectionScreen({
    super.key,
    required this.serviceCategory,
    required this.patientType,
    this.patientNik,
    this.patientName,
    this.patientDate,
    this.patientPhone,
  });

  final List<String> poliList = const [
    'POLI DALAM',
    'POLI THT',
    'POLI GIGI',
    'POLI ANAK',
    'POLI SYARAF',
    'POLI UMUM',
    'POLI JIWA',
    'POLI BEDAH',
    'POLI MATA',
    'POLI PARU',
    'POLI FORENSIK',
    'RADIOLOGI',
    'POLI KANDUNGAN',
    'ORTHOPEDI',
    'LABORATORIUM',
    'POLI JANTUNG',
    'GIGI ENDODONSI',
    'MIKROBIOLOGI KLINIK',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          SafeArea(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Row with Logo and Texts
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo
                      Image.asset(
                        'Logo Kab.Toba.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Selamat Datang di RSUD Porsea',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Silahkan Pilih Poli',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Date and time - Horizontal
                  Row(
                    children: [
                      // Date
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Senin, 02 Maret 2026',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Time
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '08:32:42',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Content - Grid of Polis
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Back Button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Kembali',
                                style: AppTheme.serviceTitle.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Polis Grid - 3 Columns (Sesuai Gambar)
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                      children: List.generate(
                        poliList.length,
                        (index) {
                          final poli = poliList[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to doctor selection
                              Navigator.of(context).pushNamed(
                                '/doctor_selection',
                                arguments: {
                                  'policlinic': poli,
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                  child: Text(
                                    poli,
                                    textAlign: TextAlign.center,
                                    style: AppTheme.serviceTitle.copyWith(
                                      color: AppColors.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: AppColors.footer,
            child: Center(
              child: Text(
                HospitalInfo.copyright,
                style: AppTheme.footerText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
