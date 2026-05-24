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

  Future<void> _printTicket() async {
    setState(() => _exporting = true);
    try {
      await _pdfService.printTicketDirectly(widget.ticket);
      
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
                onPressed: _exporting ? null : _printTicket,
                icon: const Icon(Icons.print),
                label: Text(_exporting ? 'Mencetak...' : 'Cetak Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}