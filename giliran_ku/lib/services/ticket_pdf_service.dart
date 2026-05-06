import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../config/api_config.dart';
import '../data/models/ticket.dart';

class TicketPdfService {
  static const String _windowsOutputDir =
      r'D:\Folder Semester 4\Pengembangan Aplikasi Mobile\Week 14\Praktikum\giliran_ku\queue_pdfs';

  Future<String> exportTicket(Ticket ticket) async {
    final pdf = pw.Document();
    if (ticket.type == 'farmasi') {
      pdf.addPage(_buildPharmacyPage(ticket));
    } else {
      pdf.addPage(_buildTicketPage(ticket));
    }
    final bytes = await pdf.save();

    if (Platform.isAndroid) {
      return _uploadToBackend(ticket, bytes);
    }

    final outputDir = await _resolveOutputDirectory();
    final fileName = _safeFileName(ticket);
    final filePath =
        '${outputDir.path}${Platform.pathSeparator}$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    return file.path;
  }

  pw.Page _buildTicketPage(Ticket ticket) {
    final admissionNumber = ticket.admissionNumber?.toString() ?? '-';
    final poliQueue = ticket.poliQueueCode ?? ticket.queueNumber.toString();
    final poliName = ticket.poliName ?? '-';
    final doctorName = ticket.doctorName ?? '-';
    final patientName = ticket.patientName ?? '-';
    final patientNik = ticket.patientNik ?? '-';
    final ticketId = ticket.id;
    final printedAt = _formatDateTime(ticket.createdAt);

    return pw.Page(
      pageFormat: PdfPageFormat.a6,
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey700, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  printedAt,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'RSUD Porsea',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Nomor Antrian Admisi'),
              pw.Divider(),
              pw.Text(
                admissionNumber,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Mohon menuju ruang tunggu admisi/pendaftaran',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Nomor Antrian Anda'),
              pw.Divider(),
              pw.Text(
                poliQueue,
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(ticketId, style: const pw.TextStyle(fontSize: 9)),
              pw.Text(poliName, style: const pw.TextStyle(fontSize: 10)),
              pw.Text('Dokter: $doctorName',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Tanggal cetak: $printedAt',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Nama: $patientName',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('NIK: $patientNik',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.SizedBox(height: 12),
              pw.BarcodeWidget(
                barcode: Barcode.qrCode(),
                data: ticketId,
                width: 80,
                height: 80,
              ),
              pw.SizedBox(height: 8),
              pw.Text('semoga lekas sembuh',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        );
      },
    );
  }

  pw.Page _buildPharmacyPage(Ticket ticket) {
    final queueCode = _formatPharmacyQueue(ticket.queueNumber);
    final patientName =
        ticket.patientName ?? ticket.queueNumber.toString();
    final printedDate = _formatDateOnly(ticket.createdAt);

    return pw.Page(
      pageFormat: PdfPageFormat.a6,
      build: (context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey700, width: 1),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'RSUD Porsea',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Antrian Farmasi',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Nomor Antrian Bapak / Ibu :'),
              pw.Divider(),
              pw.Text(
                queueCode,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Nama : $patientName',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 14),
              pw.Text(
                'Farmasi RSUD Porsea',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'semoga lekas sembuh',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                printedDate,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Directory> _resolveOutputDirectory() async {
    if (Platform.isWindows) {
      final directory = Directory(_windowsOutputDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    }

    final baseDir = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${baseDir.path}${Platform.pathSeparator}queue_pdfs',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _safeFileName(Ticket ticket) {
    final safeId = ticket.id.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'ticket_$safeId.pdf';
  }

  String _formatDateTime(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }

  String _formatDateOnly(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  String _formatPharmacyQueue(int number) {
    return 'N${number.toString().padLeft(3, '0')}';
  }

  Future<String> _uploadToBackend(Ticket ticket, Uint8List bytes) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/tickets/pdf');
    final request = http.MultipartRequest('POST', uri)
      ..fields['ticket_id'] = ticket.id
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: _safeFileName(ticket),
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload gagal: $body');
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['path'] is String) {
        return decoded['path'] as String;
      }
    } catch (_) {}

    return 'PDF berhasil diupload.';
  }
}
