import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class PrintService {
  /// Auto-pull PDF dari emulator ke Windows menggunakan ADB
  static Future<Map<String, dynamic>> _autoPullPdfToWindows(
    String fileName,
    String emulatorPath,
  ) async {
    try {
      print('[PrintService] Starting auto-pull to Windows...');
      print('[PrintService] Source: $emulatorPath');
      print('[PrintService] Filename: $fileName');
      
      // Windows Downloads folder (hardcoded - terbukti bekerja)
      final downloadsPath = 'C:\\Users\\ASUS\\Downloads';
      
      print('[PrintService] Target: $downloadsPath');
      print('[PrintService] Running: adb pull $emulatorPath $downloadsPath');

      // Execute adb pull - simple approach
      final result = await Process.run(
        'adb',
        ['pull', emulatorPath, downloadsPath],
      );

      print('[PrintService] ADB Exit Code: ${result.exitCode}');
      
      if (result.exitCode == 0) {
        final fullPath = '$downloadsPath\\$fileName';
        print('[PrintService] ✅ Auto-pull SUCCESS: $fullPath');
        return {
          'success': true,
          'message': '✅ PDF berhasil di-download!\n📁 C:\\Users\\ASUS\\Downloads\\$fileName',
          'filePath': fullPath,
        };
      } else {
        print('[PrintService] ❌ ADB Pull failed with exit code ${result.exitCode}');
        print('[PrintService] Stderr: ${result.stderr}');
        
        return {
          'success': false,
          'message': '⚠️ Auto-pull gagal\nSilakan jalankan: pull_pdf.bat',
          'error': 'ADB exit code: ${result.exitCode}',
        };
      }
    } catch (e) {
      print('[PrintService] ❌ Auto-pull exception: $e');
      
      return {
        'success': false,
        'message': '⚠️ Auto-pull error\nSilakan jalankan: pull_pdf.bat',
        'error': e.toString(),
      };
    }
  }
  static Future<Map<String, dynamic>> printOrExportQueueTicket({
    required String queueNumber,
    required String patientName,
    required String clinicName,
    required String doctorName,
    required String scheduleInfo,
    String? queueCode,
    String? rmNumber = "449985",
    String? admissionNumber = "107",
    String? source = "KIOSK",
  }) async {
    try {
      final pdf = pw.Document();
      
      // Get current date/time formatted (simple approach)
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().substring(2)}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final fullDateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header - Date/Time
                pw.Align(
                  alignment: pw.Alignment.topLeft,
                  child: pw.Text(
                    dateStr,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Hospital Name - RSUD Porsea
                pw.Text(
                  'RSUD Porsea',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 30),

                // Section 1: Nomor Antrian Admisi
                pw.Text(
                  'Nomor Antrian Admisi :',
                  style: pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                
                // Divider line
                pw.Container(
                  width: 200,
                  height: 1,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 12),

                // Big Admission Number
                pw.Text(
                  admissionNumber ?? '107',
                  style: pw.TextStyle(
                    fontSize: 60,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 12),

                // Info text
                pw.Text(
                  'Mohon menuju ruang tungggu\nadmisi/pendaftaran',
                  style: pw.TextStyle(fontSize: 11),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 30),

                // Section 2: Nomor Antrian Anda
                pw.Text(
                  'Nomor Antrian Anda :',
                  style: pw.TextStyle(fontSize: 12),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),

                // Divider line
                pw.Container(
                  width: 200,
                  height: 1,
                  color: PdfColors.black,
                ),
                pw.SizedBox(height: 12),

                // Big Queue Code/Number
                pw.Text(
                  queueCode ?? queueNumber,
                  style: pw.TextStyle(
                    fontSize: 50,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 20),

                // Detail Information
                pw.Container(
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        queueCode ?? queueNumber,
                        style: pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        clinicName,
                        style: pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'Tanggal cetak : $fullDateStr',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'Asal : $source',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'No RM : $rmNumber',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        'Nama : $patientName',
                        style: pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // QR Code Placeholder (visual separator)
                pw.Container(
                  width: 80,
                  height: 80,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '[QR]',
                      style: pw.TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Footer message
                pw.Text(
                  'semoga lekas sembuh',
                  style: pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      print('[PrintService] PDF document created successfully with new design');

      // Step 1: Try to detect printer
      print('[PrintService] Checking for available printers...');
      List<Printer> availablePrinters = [];
      try {
        availablePrinters = await Printing.listPrinters();
        print('[PrintService] Found ${availablePrinters.length} printer(s)');
      } catch (e) {
        print('[PrintService] Printer detection failed: $e');
        print('[PrintService] Proceeding with PDF export...');
      }

      // Step 2: If printer available, print directly
      if (availablePrinters.isNotEmpty) {
        print('[PrintService] Showing print dialog...');
        try {
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdf.save(),
          );
          print('[PrintService] Print completed successfully');
          return {
            'success': true,
            'message': 'Nomor antrian berhasil dicetak ke printer',
            'method': 'print',
          };
        } catch (e) {
          print('[PrintService] Print failed: $e, falling back to export...');
        }
      }

      // Step 3: Export to PDF (if no printer or print failed)
      print('[PrintService] Exporting to PDF file...');
      try {
        final extDir = await getExternalStorageDirectory();
        
        if (extDir == null) {
          // Fallback to app documents if external storage not available
          final directory = await getApplicationDocumentsDirectory();
          final fileName =
              'Antrian_${queueCode ?? queueNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(await pdf.save());

          print('[PrintService] PDF exported to app documents: ${file.path}');
          
          return {
            'success': true,
            'message': '''✅ PDF BERHASIL DIBUAT!

📁 Lokasi: App Documents
${file.path}

📥 DOWNLOAD ke WINDOWS:
Jalankan pull_pdf.bat di folder project untuk copy PDF ke Windows Downloads.''',
            'method': 'export',
            'filePath': file.path,
            'needsManualPull': true,
          };
        }

        final fileName =
            'Antrian_${queueCode ?? queueNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final downloadDir = Directory('${extDir.path}/Download');
        
        // Create Download folder if it doesn't exist
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final file = File('${downloadDir.path}/$fileName');
        await file.writeAsBytes(await pdf.save());

        print('[PrintService] PDF exported successfully: ${file.path}');
        
        return {
          'success': true,
          'message': '''✅ PDF BERHASIL DIBUAT!

📁 Lokasi Emulator:
${file.path}

📥 AUTO PULL ke WINDOWS:
Jika belum menjalankan watcher, buka PowerShell di folder project:
→ .\auto_pull_watcher.ps1

Kemudian biarkan berjalan di background. PDF akan otomatis
tersimpan ke queue_pdfs\\ saat Anda tekan CETAK.

Tekan Ctrl+C di watcher untuk stop.''',
          'method': 'export',
          'filePath': file.path,
          'needsWatcher': true,
        };
      } catch (e) {
        print('[PrintService] Export failed: $e');
        print('[PrintService] Error type: ${e.runtimeType}');
        throw e;
      }
    } catch (e) {
      print('[PrintService] Error: $e');
      print('[PrintService] Error type: ${e.runtimeType}');
      return {
        'success': false,
        'message': 'Error saat print/export: ${e.toString()}',
        'method': 'error',
      };
    }
  }
}
