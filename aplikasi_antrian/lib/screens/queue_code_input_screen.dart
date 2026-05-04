import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/validation_service.dart';
import '../services/print_service.dart';
import '../utils/constants.dart';
import '../widgets/header_widget.dart';
import '../widgets/footer_widget.dart';

class QueueCodeInputScreen extends StatefulWidget {
  const QueueCodeInputScreen({super.key});

  @override
  State<QueueCodeInputScreen> createState() => _QueueCodeInputScreenState();
}

class _QueueCodeInputScreenState extends State<QueueCodeInputScreen> {
  late TextEditingController _codeController;
  String _displayedCode = '';

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_displayedCode.length < 12) {
      setState(() {
        _displayedCode += digit;
        _codeController.text = _displayedCode;
      });
    }
  }

  void _deleteDigit() {
    if (_displayedCode.isNotEmpty) {
      setState(() {
        _displayedCode = _displayedCode.substring(0, _displayedCode.length - 1);
        _codeController.text = _displayedCode;
      });
    }
  }

  Future<void> _verify() async {
    if (_displayedCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode antrian terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_displayedCode.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode antrian harus terdiri dari 12 karakter'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate format: alphanumeric uppercase
    if (!RegExp(r'^\d{12}$').hasMatch(_displayedCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode antrian hanya boleh berisi angka (0-9)'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    final validationResult =
        await ValidationService.validateQueueCode(_displayedCode);

    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    if (!validationResult.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationResult.message),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final data = validationResult.data;

    // Print the queue ticket
    try {
      final printResult = await PrintService.printOrExportQueueTicket(
        queueNumber: data?.queueNumber ?? '-',
        patientName: data?.patientName ?? 'Pasien',
        clinicName: data?.clinicName ?? 'POLI',
        doctorName: data?.doctorName ?? 'Dr. Dokter',
        scheduleInfo: data?.scheduleInfo ?? 'Jadwal Layanan',
      );

      if (!mounted) return;

      if (!(printResult['success'] as bool)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(printResult['message'] ?? 'Gagal print/export'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(printResult['message'] ?? 'Nomor antrian berhasil dicetak'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error print: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    // Navigate to verification success screen
    Navigator.of(context).pushNamed(
      '/queue_verification_success',
      arguments: {
        'queueCode': data?.queueCode ?? _displayedCode,
        'queueNumber': data?.queueNumber,
        'patientName': data?.patientName,
        'clinicName': data?.clinicName,
        'doctorName': data?.doctorName,
        'scheduleInfo': data?.scheduleInfo,
        'createdAt': data?.createdAt.toIso8601String(),
      },
    );
  }

  String _formatDisplayCode() {
    if (_displayedCode.isEmpty) {
      return 'XXXX-XXXX-XXXX';
    }

    // Format: XXXX-XXXX-XXXX
    String padded = _displayedCode.padRight(12, 'X');
    return '${padded.substring(0, 4)}-${padded.substring(4, 8)}-${padded.substring(8, 12)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const HeaderWidget(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      'Masukkan Kode Antrian',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Code input field
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: _codeController,
                        readOnly: false,
                        textAlign: TextAlign.center,
                        maxLength: 12,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _displayedCode = value.toUpperCase();
                          });
                        },
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.black,
                              letterSpacing: 2,
                            ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16),
                          hintText: 'XXXX-XXXX-XXXX',
                          counterText: '',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.grey[300],
                                letterSpacing: 2,
                              ),
                        ),

                      ),
                    ),

                    // Display formatted code below input
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _formatDisplayCode(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  letterSpacing: 2,
                                  fontFamily: 'monospace',
                                ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '*Kode antrian didapat melalui pesan konfirmasi yang Anda terima melalui aplikasi',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Number pad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left column - numbers 1-7
                        Expanded(
                          child: Column(
                            children: [
                              for (int i = 1; i <= 7; i += 3)
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildNumberButton(
                                          i.toString(),
                                          () => _addDigit(i.toString()),
                                        ),
                                        _buildNumberButton(
                                          (i + 1).toString(),
                                          () => _addDigit((i + 1).toString()),
                                        ),
                                        _buildNumberButton(
                                          (i + 2).toString(),
                                          () => _addDigit((i + 2).toString()),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              // 0 button
                              Center(
                                child: _buildNumberButton(
                                  '0',
                                  () => _addDigit('0'),
                                  width: 80,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right column - Delete button
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _deleteDigit,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'HAPUS',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Verification and print button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _verify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Verifikasi dan Cetak Kertas',
                          style: TextStyle(
                            color: Colors.white,
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

  Widget _buildNumberButton(
    String label,
    VoidCallback onPressed, {
    double width = 80,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
        ),
      ),
    );
  }
}
