import 'package:flutter/material.dart';

import '../../data/api/api_exception.dart';
import '../../logic/booking/booking_controller.dart';
import '../ticket_view.dart';

class BookingLookupView extends StatefulWidget {
  const BookingLookupView({super.key});

  @override
  State<BookingLookupView> createState() => _BookingLookupViewState();
}

class _BookingLookupViewState extends State<BookingLookupView> {
  final _codeController = TextEditingController();
  final BookingController _controller = BookingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Masukkan kode booking');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ticket = await _controller.getTicketByCode(code);
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
        title: const Text('Cetak Antrian'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Kode Booking',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Memproses...' : 'Cari Tiket'),
            ),
            const SizedBox(height: 8),
            const Text('Contoh kode: BK001 atau BK002'),
          ],
        ),
      ),
    );
  }
}
