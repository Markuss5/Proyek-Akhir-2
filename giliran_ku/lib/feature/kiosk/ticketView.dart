import 'package:flutter/material.dart';

import 'package:giliran_ku/core/models/ticketModel.dart';
import 'package:giliran_ku/core/services/thermalPrinterService.dart';
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
  bool _printing = false;
  bool _printed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _printTicket());
  }

  Future<void> _printTicket() async {
    setState(() {
      _printing = true;
      _error = null;
    });
    try {
      await ThermalPrinterService.printTicket(widget.ticket);
      if (!mounted) return;
      setState(() {
        _printing = false;
        _printed = true;
      });
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _printing = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
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

            if (_printing)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Mencetak tiket...'),
                ],
              )
            else if (_printed)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF54D9B4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Color(0xFF25A699)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tiket berhasil dicetak.',
                        style: TextStyle(color: Color(0xFF0A3D2E)),
                      ),
                    ),
                  ],
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _printTicket,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Cetak Ulang Tiket'),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_rounded),
                label: const Text('Kembali ke Halaman Utama'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}