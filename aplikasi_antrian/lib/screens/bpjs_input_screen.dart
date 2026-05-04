import 'package:flutter/material.dart';
import '../services/validation_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'polis_selection_screen.dart';

class BpjsInputScreen extends StatefulWidget {
  final String serviceCategory; // 'consultation' atau 'pharmacy'
  final String patientType; // 'bpjs' atau 'umum'

  const BpjsInputScreen({
    super.key,
    required this.serviceCategory,
    required this.patientType,
  });

  @override
  State<BpjsInputScreen> createState() => _BpjsInputScreenState();
}

class _BpjsInputScreenState extends State<BpjsInputScreen> {
  late TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _addNumber(String number) {
    setState(() {
      _inputController.text += number;
    });
  }

  void _deleteNumber() {
    if (_inputController.text.isNotEmpty) {
      setState(() {
        _inputController.text =
            _inputController.text.substring(0, _inputController.text.length - 1);
      });
    }
  }

  Future<void> _verifyAndPrint() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan NIK / Nomor BPJS terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Remove non-digits for validation
    final cleanedInput = input.replaceAll(RegExp(r'\D'), '');

    // Validate format: either 16-digit NIK or 13-digit BPJS
    if (!RegExp(r'^\d{16}$').hasMatch(cleanedInput) && 
        !RegExp(r'^\d{13}$').hasMatch(cleanedInput)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIK harus 16 digit atau BPJS harus 13 digit'),
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

    final validationResult = await ValidationService.validateBpjsOrNik(cleanedInput);

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

    if (!mounted) return;

    // Navigate to polis selection screen with patient data
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PolisSelectionScreen(
          serviceCategory: widget.serviceCategory,
          patientType: 'bpjs',
          patientNik: cleanedInput,
          patientName: validationResult.patientName ?? 'Pasien BPJS',
          patientDate: '',
          patientPhone: '',
        ),
      ),
    );
  }

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
                              'Masukkan NIK / No. BPJS',
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

                    // Title
                    Text(
                      'NIK / No. BPJS',
                      style: AppTheme.serviceTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Field
                    TextField(
                      controller: _inputController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Masukkan NIK / Nomor BPJS Disini',
                        hintStyle: AppTheme.serviceDescription.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.textPrimary,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.textPrimary,
                            width: 2,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: const BorderSide(
                            color: AppColors.textPrimary,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: AppTheme.serviceTitle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Number Pad
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                      children: List.generate(9, (index) {
                        int number = index + 1;
                        return _buildNumberButton(number.toString());
                      }),
                    ),
                    const SizedBox(height: 12),

                    // Zero button and Delete button row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberButton('0'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _deleteNumber,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                border: Border.all(
                                  color: AppColors.textPrimary,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Center(
                                child: Text(
                                  'HAPUS',
                                  style: AppTheme.serviceTitle.copyWith(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyAndPrint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          'Verifikasi dan Cetak Kertas',
                          style: AppTheme.serviceTitle.copyWith(
                            color: Colors.white,
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

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _addNumber(number),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textPrimary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            number,
            style: AppTheme.serviceTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
