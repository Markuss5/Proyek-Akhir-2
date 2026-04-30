import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giliranku/core/datasources/apiDataSource.dart';
import 'package:giliranku/core/widgets/header.dart';
import 'package:giliranku/feature/patient/antrian/antrianUmumView.dart';
import 'package:giliranku/feature/patient/antrian/karcis_view.dart';
import 'package:iconsax/iconsax.dart';

class AntrianBpjsView extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  const AntrianBpjsView({super.key, this.patientData});

  @override
  State<AntrianBpjsView> createState() => _AntrianBpjsViewState();
}

class _AntrianBpjsViewState extends State<AntrianBpjsView>
    with SingleTickerProviderStateMixin {
  final _api = ApiDataSource();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _isLoading = false;

  final _nikCtrl     = TextEditingController();
  final _rujukanCtrl = TextEditingController();

  String? _nikError;
  String? _rujukanError;

  bool get _isLoggedIn =>
      widget.patientData != null &&
      widget.patientData!.containsKey('nik');

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    if (_isLoggedIn) {
      _nikCtrl.text = widget.patientData!['nik'] ?? '';
    }

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nikCtrl.dispose();
    _rujukanCtrl.dispose();
    super.dispose();
  }

  Future<void> _daftarAntrian() async {
    setState(() {
      _nikError     = null;
      _rujukanError = null;
    });

    bool valid = true;
    if (_nikCtrl.text.trim().length < 10) {
      setState(() => _nikError = 'NIK/No. BPJS tidak valid');
      valid = false;
    }
    if (_rujukanCtrl.text.trim().isEmpty) {
      setState(() => _rujukanError = 'No. rujukan tidak boleh kosong');
      valid = false;
    }
    if (!valid) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final res = await _api.createAntrian({
        'nik'        : _nikCtrl.text.trim(),
        'no_rujukan' : _rujukanCtrl.text.trim(),
        'tipe'       : 'bpjs',
      });

      final data   = res['data'] as Map<String, dynamic>? ?? {};
      final result = AntrianResult.fromJson(data);

      if (mounted) {
        setState(() => _isLoading = false);
        _goToKarcis(result);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Gagal mendaftar: $e');
    }
  }

  void _goToKarcis(AntrianResult result) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, __) => KarcisView(result: result),
      transitionsBuilder: (_, a, __, child) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 400),
    ));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF0D9B86),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              mode: HeaderMode.page,
              title: 'Antrian BPJS',
              subtitle: 'RSUD Porsea',
              pageIcon: Iconsax.shield_tick,
            ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (_isLoggedIn) ...[
                          _buildLoggedInBanner(),
                          const SizedBox(height: 16),
                        ],
                        _buildInfoBpjs(),
                        const SizedBox(height: 16),
                        _buildFormCard(),
                        const SizedBox(height: 28),
                        _buildDaftarButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInBanner() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFE6F7F4),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF0D9B86),
          size: 22,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'NIK otomatis dari akun.\nUbah jika ingin menggunakan NIK lain.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF065F46),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ); // ← ini yang tadi kurang
}

  Widget _buildInfoBpjs() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              color: Color(0xFF3B82F6), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pastikan Anda sudah mendaftar rujukan dari Faskes tingkat 1 (Puskesmas/Klinik) sebelum mendaftar.',
              style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.w500,
                  height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Data Kepesertaan BPJS'),
          const SizedBox(height: 16),
          _field(
            ctrl: _nikCtrl,
            label: 'NIK / No. BPJS',
            hint: 'Masukkan NIK atau No. BPJS',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            maxLength: 16,
            errorText: _nikError,
            readOnly: _isLoggedIn,
            formatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          _field(
            ctrl: _rujukanCtrl,
            label: 'No. Rujukan',
            hint: 'Masukkan nomor surat rujukan',
            icon: Iconsax.document_text,
            errorText: _rujukanError,
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF374151),
          letterSpacing: 0.3));

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? errorText,
    bool readOnly = false,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: formatters,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly
                ? const Color(0xFF6B7280)
                : const Color(0xFF111827),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFFBFC5CF), fontSize: 14),
            prefixIcon:
                Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            suffixIcon: readOnly
                ? const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFFD1D5DB), size: 16)
                : null,
            counterText: '',
            errorText: errorText,
            filled: true,
            fillColor: readOnly
                ? const Color(0xFFF3F4F6)
                : const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB), width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF0D9B86), width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFFEF4444), width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDaftarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _daftarAntrian,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D9B86),
          disabledBackgroundColor:
              const Color(0xFF0D9B86).withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Daftar Sekarang',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }
}