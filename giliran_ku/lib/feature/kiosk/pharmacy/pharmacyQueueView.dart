import 'package:flutter/material.dart';

import 'package:giliran_ku/core/datasources/apiException.dart';
import 'package:giliran_ku/feature/kiosk/pharmacy/pharmacyController.dart';
import 'package:giliran_ku/core/widgets/printingScreen.dart';

class PharmacyQueueView extends StatefulWidget {
  const PharmacyQueueView({super.key});

  @override
  State<PharmacyQueueView> createState() => _PharmacyQueueViewState();
}

class _PharmacyQueueViewState extends State<PharmacyQueueView> {
  final PharmacyController _controller = PharmacyController();

  bool _loading = false;
  String? _error;

  Future<void> _takeAndPrint() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.takeNumber();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PrintingScreen(ticket: ticket)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _readError(error);
        _loading = false;
      });
    }
  }

  String _readError(Object error) {
    if (error is ApiException) return error.message;
    return 'Terjadi kesalahan. Coba lagi.';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrian Farmasi'),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD7EFE6)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A0F8C6D),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F4ED),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 44,
                      color: Color(0xFF25A699),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Antrian Farmasi',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          color: const Color(0xFF0A3D2E),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol di bawah untuk mengambil nomor antrian.\nTiket akan langsung tercetak.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF577A6D),
                        ),
                  ),
                  const SizedBox(height: 28),
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _takeAndPrint,
                      icon: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.receipt_long_rounded),
                      label: Text(
                        _loading ? 'Memproses...' : 'Ambil & Cetak Tiket',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: const Color(0xFF25A699),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}