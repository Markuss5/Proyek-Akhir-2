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

  Future<void> _exportPdf() async {
    final ticket = _ticket;
    if (ticket == null) {
      setState(() => _error = 'Ambil nomor terlebih dahulu');
      return;
    }

    setState(() => _exporting = true);
    try {
      final filePath = await _pdfService.exportTicket(ticket);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF disimpan di: $filePath')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal export PDF: $error')),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _takeNumber,
              child: Text(_loading ? 'Memproses...' : 'Ambil Nomor'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            if (_ticket != null) TicketCard(ticket: _ticket!),
            if (_ticket == null)
              const Text('Nomor antrian akan muncul di sini.'),
            if (_ticket != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _exporting ? null : _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(_exporting ? 'Mengekspor...' : 'Export PDF'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
