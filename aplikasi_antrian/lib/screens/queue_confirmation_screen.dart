import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../services/print_service.dart';

class QueueConfirmationScreen extends StatefulWidget {
  final String queueNumber;
  final String serviceType; // 'bpjs' atau 'umum'
  final String serviceCategory; // 'consultation' atau 'pharmacy'

  const QueueConfirmationScreen({
    super.key,
    required this.queueNumber,
    required this.serviceType,
    this.serviceCategory = 'consultation',
  });

  @override
  State<QueueConfirmationScreen> createState() =>
      _QueueConfirmationScreenState();
}

class _QueueConfirmationScreenState extends State<QueueConfirmationScreen> {
  bool _isPrinting = false;

  Future<void> _printTicket() async {
    setState(() => _isPrinting = true);

    try {
      final result = await PrintService.printOrExportQueueTicket(
        queueNumber: widget.queueNumber,
        patientName: 'Pasien Terdaftar',
        clinicName: widget.serviceCategory == 'consultation'
            ? 'POLI KONSULTASI'
            : 'FARMASI',
        doctorName: 'Dr. Dokter',
        scheduleInfo: 'Jadwal Pelayanan',
      );

      if (mounted) {
        if (result['success'] as bool) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Berhasil print/export nomor antrian'),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal print/export'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with wavy design
          SafeArea(
            child: Stack(
              children: [
                // Teal background - make it shorter
                Container(
                  height: 80,
                  color: AppColors.primary,
                ),
                // Wavy decoration
                Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: WaveClipper(),
                    size: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Success badge with checkmark
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Success title
                    Text(
                      'Pendaftaran Berhasil',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerTitle.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Queue ticket card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        children: [
                          // Hospital name
                          Text(
                            'RSUD Porsea',
                            style: AppTheme.serviceTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Queue type
                          Text(
                            _getQueueTypeLabel(),
                            style: AppTheme.serviceDescription.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),

                          // Queue type label
                          Text(
                            'Nomor Antrian ${_getQueueTypeLabel().split(' ').join(' ')}',
                            style: AppTheme.serviceDescription.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Container(
                            height: 1,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 16),

                          // Queue number - Large
                          Column(
                            children: [
                              Text(
                                widget.queueNumber,
                                style: AppTheme.headerTitle.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nomor',
                                style: AppTheme.serviceDescription.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Container(
                            height: 1,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(height: 16),

                          // Estimated time
                          Column(
                            children: [
                              Text(
                                'Estimasi Waktu Antrian',
                                style: AppTheme.serviceDescription.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Waktu Pelayanan 06/03/2026',
                                style: AppTheme.serviceDescription.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    // Print button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPrinting ? null : _printTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: _isPrinting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Cetak Kertas',
                                style: AppTheme.serviceTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Back to menu button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // Navigate back to home screen
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          'Kembali ke Menu Utama',
                          style: AppTheme.serviceTitle.copyWith(
                            color: AppColors.primary,
                            fontSize: 16,
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

  String _getQueueTypeLabel() {
    String patientType = (widget.serviceType == 'bpjs') ? 'BPJS' : 'Umum';
    String serviceTypeText = (widget.serviceCategory == 'pharmacy') ? 'Farmasi' : 'Konsultasi';
    return 'Antrian $serviceTypeText $patientType';
  }
}

// Custom paint untuk wavy design
class WaveClipper extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    // Create wavy line
    for (double x = 0; x <= size.width; x++) {
      double y = 20 * (Math.sin(x / size.width * 3.14159 * 2).toDouble());
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WaveClipper oldDelegate) => false;
}

// Helper untuk Math.sin
extension on double {
  double get sin => Math.sin(this);
}

class Math {
  static double sin(double radians) {
    return _sin(radians);
  }

  static double _sin(double x) {
    // Normalize to [-pi, pi]
    const double pi = 3.141592653589793;
    const double twoPi = 2 * pi;
    x = x % twoPi;
    if (x > pi) {
      x -= twoPi;
    }
    if (x < -pi) {
      x += twoPi;
    }

    // Taylor series
    double result = 0;
    double term = x;
    for (int i = 1; i < 20; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }
}
