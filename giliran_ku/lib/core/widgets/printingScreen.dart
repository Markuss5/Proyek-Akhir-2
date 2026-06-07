import 'package:flutter/material.dart';

import 'package:giliran_ku/core/models/ticketModel.dart';
import 'package:giliran_ku/core/services/thermalPrinterService.dart';

class PrintingScreen extends StatefulWidget {
  final Ticket ticket;

  const PrintingScreen({super.key, required this.ticket});

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  _Status _status = _Status.printing;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _doPrint());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _doPrint() async {
    try {
      await ThermalPrinterService.printTicket(widget.ticket);
      if (!mounted) return;
      setState(() => _status = _Status.success);
      Future.delayed(const Duration(seconds: 4), _goHome);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _Status.error;
        _errorMsg = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3D2E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _status == _Status.printing
                ? _buildPrinting()
                : _status == _Status.success
                    ? _buildSuccess()
                    : _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildPrinting() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnim,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1A5E42),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.print_rounded,
              size: 64,
              color: Color(0xFF54D9B4),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Mencetak Tiket...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mohon tunggu, tiket Anda sedang dicetak.\nJangan cabut kertas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFAAD5C5),
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: Color(0xFF54D9B4),
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    final ticket = widget.ticket;
    final noAntrian =
        ticket.poliQueueCode ?? ticket.queueNumber.toString();
    final isFarmasi = ticket.type == 'farmasi';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1A5E42),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 72,
            color: Color(0xFF54D9B4),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Tiket Berhasil Dicetak!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A5E42),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                isFarmasi ? 'Nomor Antrian Farmasi' : 'Nomor Antrian Anda',
                style: const TextStyle(
                  color: Color(0xFFAAD5C5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFarmasi
                    ? 'N${ticket.queueNumber.toString().padLeft(3, '0')}'
                    : noAntrian,
                style: const TextStyle(
                  color: Color(0xFF54D9B4),
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              if (ticket.poliName != null) ...[
                const SizedBox(height: 4),
                Text(
                  ticket.poliName!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          isFarmasi
              ? 'Ambil tiket dari mesin, lalu tunggu di ruang farmasi.'
              : 'Ambil tiket dari mesin, lalu tunggu di ruang tunggu ${ticket.poliName ?? "poli"}.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFAAD5C5),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Halaman akan kembali otomatis...',
          style: TextStyle(color: Color(0xFF5D9A84), fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _goHome,
          icon: const Icon(Icons.home_rounded, color: Color(0xFF54D9B4)),
          label: const Text(
            'Kembali ke Halaman Utama',
            style: TextStyle(color: Color(0xFF54D9B4)),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF4A1A1A),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Icon(
            Icons.print_disabled_rounded,
            size: 64,
            color: Color(0xFFFF7070),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Gagal Mencetak Tiket',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3A1A1A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _errorMsg ?? 'Terjadi kesalahan tidak diketahui.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFAAAA),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Periksa koneksi USB printer dan pastikan printer menyala.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFAAD5C5), fontSize: 13),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _status = _Status.printing;
                  _errorMsg = null;
                });
                _doPrint();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF54D9B4)),
                foregroundColor: const Color(0xFF54D9B4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _goHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A5E42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Halaman Utama'),
            ),
          ],
        ),
      ],
    );
  }
}

enum _Status { printing, success, error }