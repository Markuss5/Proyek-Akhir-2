import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/footer_widget.dart';

class DoctorSelectionScreen extends StatefulWidget {
  final String policlinic;

  const DoctorSelectionScreen({
    super.key,
    required this.policlinic,
  });

  @override
  State<DoctorSelectionScreen> createState() => _DoctorSelectionScreenState();
}

class _DoctorSelectionScreenState extends State<DoctorSelectionScreen> {
  String? selectedDoctor;

  // Data dokter sesuai dengan gambar yang diberikan
  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'dr. Yunita V.Tampubolon, SpPD',
      'schedule': '10:00-14:00',
    },
    {
      'name': 'dr. Toman G.M Simamora, SpTHT-KL',
      'schedule': '11:00-19:00',
    },
    {
      'name': 'dr. Yusak Parlaungan Simanjuntak, SpKJ',
      'schedule': '08:00-13:00',
    },
    {
      'name': 'dr. Herbet Pardamean Hutagaol SpP',
      'schedule': '00:00-12:00',
    },
    {
      'name': 'dr. Sintyche E.Marpaung SpOG',
      'schedule': '00:00-13:00',
    },
    {
      'name': 'dr. Reynold Sianturi, SpB',
      'schedule': '09:00-12:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header (sesuai gambar)
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
                              'Silahkan Pilih Dokter',
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

          // Main Content - Daftar Dokter
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
                    const SizedBox(height: 24),

                    // Daftar Dokter - Full Width Cards
                    ...doctors.asMap().entries.map((entry) {
                      final index = entry.key;
                      final doctor = entry.value;
                      final doctorId = 'doctor_${index + 1}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDoctor = doctorId;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 14.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedDoctor == doctorId
                                    ? AppColors.primary
                                    : Colors.grey[400]!,
                                width: selectedDoctor == doctorId ? 2 : 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor['name'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  doctor['schedule'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Tombol Lanjut (muncul jika dokter dipilih)
                    if (selectedDoctor != null)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final doctorIndex =
                                int.parse(selectedDoctor!.split('_')[1]) - 1;
                            final doctorName = doctors[doctorIndex]['name'];

                            Navigator.of(context).pushNamed(
                              '/registration_success',
                              arguments: {
                                'policlinic': widget.policlinic,
                                'doctor': doctorName,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Lanjut',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          const FooterWidget(),
        ],
      ),
    );
  }
}
