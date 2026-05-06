import 'package:flutter/material.dart';

import '../../data/api/api_exception.dart';
import '../../data/models/patient.dart';
import '../../logic/consultation/consultation_controller.dart';
import 'consultation_general_select_view.dart';

class ConsultationGeneralView extends StatefulWidget {
  const ConsultationGeneralView({super.key});

  @override
  State<ConsultationGeneralView> createState() => _ConsultationGeneralViewState();
}

class _ConsultationGeneralViewState extends State<ConsultationGeneralView> {
  final _nikController = TextEditingController();
  final ConsultationController _controller = ConsultationController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _checkNik() async {
    final nik = _nikController.text.trim();
    if (nik.isEmpty) {
      setState(() => _error = 'Masukkan NIK');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final patient = await _controller.validateNik(nik);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConsultationGeneralSelectView(patient: patient),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = _readError(error));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _readError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Terjadi kesalahan. Coba lagi.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasien Umum'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF0FBF7),
              Color(0xFFE6F7F0),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Pasien Umum',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0A3D2E),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan NIK untuk melanjutkan pilihan poli dan dokter.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF577A6D),
                  ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7EFE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F4ED),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF2FAE86),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Identitas Pasien',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nikController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'NIK',
                      hintText: 'Contoh: 1203010101010001',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      errorText: _error,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loading ? null : _checkNik,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(_loading ? 'Memproses...' : 'Lanjut Pilih Poli'),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF7F1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD3EEE3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2FAE86),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan NIK valid agar daftar poli dan dokter tersedia.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF4E6E62),
                          ),
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
}
