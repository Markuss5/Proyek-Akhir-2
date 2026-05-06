import 'package:flutter/material.dart';

import '../../data/api/api_exception.dart';
import '../../logic/consultation/consultation_controller.dart';
import '../ticket_view.dart';

class ConsultationBpjsView extends StatefulWidget {
  const ConsultationBpjsView({super.key});

  @override
  State<ConsultationBpjsView> createState() => _ConsultationBpjsViewState();
}

class _ConsultationBpjsViewState extends State<ConsultationBpjsView> {
  final _inputController = TextEditingController();
  final ConsultationController _controller = ConsultationController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'Masukkan NIK atau No BPJS');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.createTicketForBpjs(input);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TicketView(ticket: ticket),
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
        title: const Text('Pasien BPJS'),
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
              'Pasien BPJS',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0A3D2E),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan NIK atau No BPJS untuk mencetak tiket antrian.',
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
                          Icons.health_and_safety_outlined,
                          color: Color(0xFF2FAE86),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Identitas BPJS',
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
                    controller: _inputController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'NIK atau No BPJS',
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
              onPressed: _loading ? null : _submit,
              icon: const Icon(Icons.local_printshop_outlined),
              label: Text(
                _loading ? 'Memproses...' : 'Cetak Tiket BPJS',
              ),
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
                      'Pastikan rujukan BPJS tersedia agar poli dan dokter bisa dipilih otomatis.',
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
