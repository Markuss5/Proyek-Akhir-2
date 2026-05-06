import 'package:flutter/material.dart';

import 'package:giliran_ku/core/models/ticketModel.dart';
import 'package:giliran_ku/core/services/ticketPdfService.dart';
import 'package:giliran_ku/core/widgets/ticketCard.dart';

class TicketView extends StatefulWidget {
  final Ticket ticket;

  const TicketView({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketView> createState() => _TicketViewState();
}

class _TicketViewState extends State<TicketView> {
  final TicketPdfService _pdfService = TicketPdfService();
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final filePath = await _pdfService.exportTicket(widget.ticket);
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
        title: const Text('Tiket Antrian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TicketCard(ticket: widget.ticket),
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
        ),
      ),
    );
  }
}
