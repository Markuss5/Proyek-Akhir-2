import 'package:flutter/material.dart';
import '../services/validation_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import 'polis_selection_screen.dart';

class GeneralPatientInputScreen extends StatefulWidget {
  final String serviceCategory; // 'consultation' atau 'pharmacy'

  const GeneralPatientInputScreen({
    super.key,
    required this.serviceCategory,
  });

  @override
  State<GeneralPatientInputScreen> createState() =>
      _GeneralPatientInputScreenState();
}

class _GeneralPatientInputScreenState extends State<GeneralPatientInputScreen> {
  late TextEditingController _nikController;
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController();
    _nameController = TextEditingController();
    _dateController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Future<void> _verifyAndContinue() async {
    final nik = _nikController.text.trim();
    final name = _nameController.text.trim();
    final date = _dateController.text.trim();
    final phone = _phoneController.text.trim();

    if (nik.isEmpty || name.isEmpty || date.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data terlebih dahulu'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final normalizedNik = nik.replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{16}$').hasMatch(normalizedNik)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIK harus terdiri dari 16 digit angka'),
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

    final nikValidation = await ValidationService.validateNik(normalizedNik);

    if (!mounted) {
      return;
    }

    Navigator.of(context, rootNavigator: true).pop();

    if (!nikValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nikValidation.message),
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
          patientType: 'umum',
          patientNik: normalizedNik,
          patientName: name,
          patientDate: date,
          patientPhone: phone,
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
                              'Silahkan Masukkan Data Diri',
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

                    // Form Fields Grid - 2 columns
                    Column(
                      children: [
                        // Row 1: NIK and Full Name
                        Row(
                          children: [
                            // NIK
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NIK',
                                    style: AppTheme.serviceTitle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _nikController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'masukkan NIK Anda disini',
                                      hintStyle: AppTheme.serviceDescription
                                          .copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Full Name
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nama Lengkap',
                                    style: AppTheme.serviceTitle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      hintText: 'masukkan nama lengkap Anda',
                                      hintStyle: AppTheme.serviceDescription
                                          .copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 2: Date of Birth and Phone Number
                        Row(
                          children: [
                            // Date of Birth
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Lahir',
                                    style: AppTheme.serviceTitle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    decoration: InputDecoration(
                                      hintText: 'DD/MM/YYYY',
                                      hintStyle: AppTheme.serviceDescription
                                          .copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                        color: AppColors.primary,
                                        size: 18,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Phone Number
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No. Telepon',
                                    style: AppTheme.serviceTitle.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      hintText: 'masukkan nomor telepon',
                                      hintStyle: AppTheme.serviceDescription
                                          .copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.md),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Verification Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _verifyAndContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Text(
                          'Verifikasi Data dan Lanjut\nPilih Poli dan Dokter',
                          textAlign: TextAlign.center,
                          style: AppTheme.serviceTitle.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
