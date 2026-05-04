import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/print_service.dart';
import '../widgets/footer_widget.dart';

class QueueVerificationSuccessScreen extends StatefulWidget {
  final String queueCode;
  final String? queueNumber;
  final String? patientName;
  final String? clinicName;
  final String? doctorName;
  final String? scheduleInfo;
  final DateTime? createdAt;

  const QueueVerificationSuccessScreen({
    super.key,
    required this.queueCode,
    this.queueNumber,
    this.patientName,
    this.clinicName,
    this.doctorName,
    this.scheduleInfo,
    this.createdAt,
  });

  @override
  State<QueueVerificationSuccessScreen> createState() =>
      _QueueVerificationSuccessScreenState();
}

class _QueueVerificationSuccessScreenState
    extends State<QueueVerificationSuccessScreen> {
  bool _isPrinting = false;

  Future<void> _printTicket() async {
    setState(() => _isPrinting = true);

    try {
      final result = await PrintService.printOrExportQueueTicket(
        queueNumber: widget.queueNumber ?? '106',
        patientName: widget.patientName ?? 'Pasien',
        clinicName: widget.clinicName ?? 'POLI UMUM',
        doctorName: widget.doctorName ?? 'Dr. Umum',
        scheduleInfo: widget.scheduleInfo ?? 'Jadwal Layanan',
        queueCode: widget.queueCode,
        rmNumber: '449985',
        admissionNumber: widget.queueNumber ?? '107',
        source: 'KIOSK',
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
              duration: const Duration(seconds: 3),
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
            duration: const Duration(seconds: 3),
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header dengan design melengkung
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              children: [
                // Icon checkmark dalam badge
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verifikasi Berhasil',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Kartu informasi
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Label tanggal dan jam
                          Text(
                            _formatCreatedAt(widget.createdAt),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                          const SizedBox(height: 16),

                          // Nama rumah sakit
                          Center(
                            child: Text(
                              'RSUD Porsea',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Kode: ${widget.queueCode}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Nomor Antrian Tervalidasi',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Container(
                            height: 2,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),

                          // Nomor antrian utama
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  _safeText(widget.queueNumber, '106'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _safeText(
                                    widget.patientName,
                                    'Data pasien belum tersedia',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nomor antrian poli
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Nomor Antrian Poli',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'E015',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${_safeText(widget.clinicName, 'POLI BEDAH')}\n(${_safeText(widget.doctorName, 'dr. Reynold Sianturi SpB')})\n${_safeText(widget.scheduleInfo, 'Pelayanan 19/04/2026')}(',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol aksi
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isPrinting ? null : _printTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isPrinting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Cetak/Export PDF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/',
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Kembali ke Menu Utama',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const FooterWidget(),
        ],
      ),
    );
  }

  String _safeText(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value.trim();
  }

  String _formatCreatedAt(DateTime? timestamp) {
    final date = timestamp ?? DateTime.now();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '($day/$month/$year, $hour:$minute)';
  }
}
