import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

import 'package:giliran_ku/core/models/ticketModel.dart';

class ThermalPrinterService {
  static const String _rawBtPackage = 'ru.a402d.rawbtprinter';

  static Future<void> printTicket(Ticket ticket) async {
    if (!Platform.isAndroid) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final receiptText = _buildReceiptText(ticket);
    await _sendToRawBT(receiptText);
  }

  static Future<void> _sendToRawBT(String text) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      type: 'text/plain',
      package: _rawBtPackage,
      arguments: <String, dynamic>{
        'android.intent.extra.TEXT': text,
      },
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );

    await intent.launch();
  }

  static String _buildReceiptText(Ticket ticket) {
    if (ticket.type == 'farmasi') {
      return _buildFarmasiReceipt(ticket);
    } else {
      return _buildKonsultasiReceipt(ticket);
    }
  }

  static String _buildFarmasiReceipt(Ticket ticket) {
    final now = DateTime.now();
    final queueCode = 'N${ticket.queueNumber.toString().padLeft(3, '0')}';
    final patientName = ticket.patientName ?? '-';
    
    final sb = StringBuffer();
    final divider = '-' * 48;

    sb.writeln(_centerText('RSUD Porsea'));
    sb.writeln('');
    sb.writeln(_centerText('Antrian Farmasi'));
    sb.writeln(divider);
    sb.writeln(_centerText('Nomor Antrian Bapak / Ibu :'));
    sb.writeln(divider);
    sb.writeln('');
    sb.writeln('<center><hw>$queueCode</hw></center>');
    sb.writeln('');
    sb.writeln(_centerText('Nama : $patientName'));
    sb.writeln('');
    sb.writeln(_centerText('Farmasi RSUD Porsea'));
    sb.writeln('');
    sb.writeln(_centerText('semoga lekas sembuh'));
    sb.writeln(_centerText(_fmtDateOnly(now)));
    sb.writeln('');
    sb.writeln('');
    sb.writeln('');

    return sb.toString();
  }

  static String _buildKonsultasiReceipt(Ticket ticket) {
    final now = DateTime.now();
    final admissionNumber = ticket.admissionNumber?.toString() ?? '-';
    final poliQueue = ticket.poliQueueCode ?? ticket.queueNumber.toString();
    final poliName = ticket.poliName ?? '-';
    final doctorName = ticket.doctorName ?? '-';

    final sb = StringBuffer();
    final divider = '-' * 48;

    sb.writeln(_fmtDateTime(now));
    sb.writeln('');
    sb.writeln(_centerText('RSUD Porsea'));
    sb.writeln('');
    sb.writeln(_centerText('Nomor Antrian Admisi :'));
    sb.writeln(divider);
    sb.writeln('');
    sb.writeln('<center><hw>$admissionNumber</hw></center>');
    sb.writeln('');
    sb.writeln(_centerText('Mohon menuju ruang tunggu'));
    sb.writeln(_centerText('admisi/pendaftaran'));
    sb.writeln('');
    sb.writeln(_centerText('Nomor Antrian Anda :'));
    sb.writeln(divider);
    sb.writeln('');
    sb.writeln('<center><hw>$poliQueue</hw></center>');
    sb.writeln('');
    if (ticket.bookingCode != null) {
      sb.writeln(_centerText(ticket.bookingCode!));
    }
    sb.writeln(_centerText(poliName));
    sb.writeln(_centerText('($doctorName)'));
    sb.writeln('');
    if (ticket.patientName != null) {
      sb.writeln(_centerText('Nama : ${ticket.patientName}'));
    }
    if (ticket.patientNik != null) {
      sb.writeln(_centerText('NIK : ${ticket.patientNik}'));
    }
    sb.writeln('');
    sb.writeln(_centerText('semoga lekas sembuh'));
    sb.writeln(_centerText(_fmtDateOnly(now)));
    sb.writeln('');
    sb.writeln('');
    sb.writeln('');

    return sb.toString();
  }

  static String _centerText(String text, {int width = 48}) {
    if (text.length >= width) return text;
    final leftPadding = ((width - text.length) / 2).floor();
    return text.padLeft(leftPadding + text.length, ' ');
  }

  static String _fmtDateOnly(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(dt.day)}/${p(dt.month)}/${dt.year}';
  }

  static String _fmtDateTime(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(dt.day)}/${p(dt.month)}/${dt.year}, ${p(dt.hour)}:${p(dt.minute)}';
  }
}