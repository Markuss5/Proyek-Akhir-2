import 'package:flutter/material.dart';

import 'package:giliran_ku/core/datasources/apiException.dart';
import 'package:giliran_ku/core/models/ticketModel.dart';
import 'package:giliran_ku/feature/kiosk/pharmacy/pharmacyController.dart';
import 'package:giliran_ku/core/services/ticketPdfService.dart';
import 'package:giliran_ku/core/widgets/ticketCard.dart';

class PharmacyQueueView extends StatefulWidget {
  const PharmacyQueueView({super.key});

  @override
  State<PharmacyQueueView> createState() => _PharmacyQueueViewState();
}

class _PharmacyQueueViewState extends State<PharmacyQueueView> {
  final PharmacyController _controller = PharmacyController();
  final TicketPdfService _pdfService = TicketPdfService();

  bool _loading = false;
  bool _exporting = false;
  String? _error;
  Ticket? _ticket;

  Future<void> _takeNumber() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.takeNumber();
      if (!mounted) return;
      setState(() => _ticket = ticket);
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

  Future<void> _printTicket() async {
    final ticket = _ticket;
    if (ticket == null) {
      setState(() => _error = 'Ambil nomor terlebih dahulu');
      return;
    }

    setState(() => _exporting = true);
    try {
      await _pdfService.printTicketDirectly(ticket);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('tiket berhasil di print')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal print tiket: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Antrian Farmasi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF0A3D2E),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Silakan ambil nomor antrian untuk layanan farmasi / apotek.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF577A6D),
                  ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD7EFE6)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.local_pharmacy,
                    size: 48,
                    color: Color(0xFF25A699),
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading || _ticket != null ? null : _takeNumber,
                      icon: const Icon(Icons.add_to_queue),
                      label: Text(_loading ? 'Memproses...' : 'Ambil Nomor Antrian'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (_ticket != null) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    TicketCard(ticket: _ticket!),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _exporting ? null : _printTicket,
                        icon: const Icon(Icons.print),
                        label: Text(_exporting ? 'Mencetak...' : 'Cetak Antrian'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}