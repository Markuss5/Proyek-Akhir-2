import 'package:flutter/material.dart';

import 'package:giliran_ku/core/models/ticketModel.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nomor Antrian ${_mainQueueLabel()}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (ticket.admissionNumber != null)
              _row(
                'Nomor Antrian Admisi',
                ticket.admissionNumber.toString(),
              ),
            if (ticket.poliQueueCode != null)
              _row('Nomor Antrian Anda', ticket.poliQueueCode!),
            if (ticket.poliQueueCode == null)
              _row('Nomor Antrian', ticket.queueNumber.toString()),
            _row('Jenis', ticket.type),
            if (ticket.poliName != null) _row('Poli', ticket.poliName!),
            if (ticket.doctorName != null) _row('Dokter', ticket.doctorName!),
            if (ticket.patientName != null) _row('Pasien', ticket.patientName!),
            if (ticket.patientNik != null) _row('NIK', ticket.patientNik!),
            if (ticket.bookingCode != null)
              _row('Kode Booking', ticket.bookingCode!),
            _row('Waktu', _formatDate(ticket.createdAt)),
            _row('Tiket ID', ticket.id),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  String _mainQueueLabel() {
    return ticket.poliQueueCode ?? ticket.queueNumber.toString();
  }
}
