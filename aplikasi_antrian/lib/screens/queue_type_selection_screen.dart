import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'bpjs_input_screen.dart';
import 'general_patient_input_screen.dart';
import 'queue_confirmation_screen.dart';

class QueueTypeSelectionScreen extends StatelessWidget {
  final String serviceCategory; // 'consultation' atau 'pharmacy'

  const QueueTypeSelectionScreen({
    super.key,
    this.serviceCategory = 'consultation',
  });

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
                              'Silahkan Pilih Layanan',
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

          // Main Content
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

                    // BPJS Patient Card
                    GestureDetector(
                      onTap: () {
                        // Navigate to BPJS input screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BpjsInputScreen(
                              serviceCategory: serviceCategory,
                              patientType: 'bpjs',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            'Pasien BPJS',
                            style: AppTheme.serviceTitle.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Atau Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Atau',
                            style: AppTheme.serviceDescription.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // General Patient Card
                    GestureDetector(
                      onTap: () {
                        // Navigate to General Patient input screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GeneralPatientInputScreen(
                              serviceCategory: serviceCategory,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Text(
                            'Pasien Umum',
                            style: AppTheme.serviceTitle.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            color: AppColors.footer,
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: Text(
                '© 2026 Institut Teknologi Del. All Rights Reserved.',
                style: AppTheme.footerText.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
